import google.generativeai as genai
import os
import re
import time
import json
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from dotenv import load_dotenv

load_dotenv()

# Configure Gemini
# User must run: GEMINI_API_KEY=xyz uvicorn main:app ...
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

app = FastAPI(title="MedX Clinical Intelligence Service")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Models ---
class InteractionCheckRequest(BaseModel):
    new_med: str
    current_meds: List[str]

class InteractionResponse(BaseModel):
    warning: Optional[str] = None
    severity: Optional[str] = None # LOW, MEDIUM, HIGH, CONTRAINDICATED

# --- Knowledge Base (Mock Rule Engine) ---
# In production, this would query a graph DB or external API (e.g. RxNorm)
INTERACTION_RULES = {
    # NSAID + NSAID = Ulcer Risk
    frozenset(["aspirin", "ibuprofen"]): {
        "warning": "Taking multiple NSAIDs increases risk of stomach bleeding.",
        "severity": "MEDIUM"
    },
    frozenset(["advil", "aspirin"]): {
        "warning": "Taking multiple NSAIDs increases risk of stomach bleeding.",
        "severity": "MEDIUM"
    },
    # Warfarin Interactions (High Risk)
    frozenset(["warfarin", "aspirin"]): {
        "warning": "High risk of bleeding! Aspirin enhances the effect of Warfarin.",
        "severity": "HIGH"
    },
    frozenset(["warfarin", "ibuprofen"]): {
        "warning": "High risk of bleeding! Ibuprofen interferes with Warfarin.",
        "severity": "HIGH"
    },
    # ACE Inhibitor + Potassium Sparing
    frozenset(["lisinopril", "spironolactone"]): {
        "warning": "Risk of Hyperkalemia (High Potassium). Monitor blood levels.",
        "severity": "MEDIUM"
    }
}

# --- Logic ---
def check_for_interactions(new_med_name: str, current_med_names: List[str]) -> InteractionResponse:
    new_med = new_med_name.lower().strip()
    
    # 1. Fast Rule Check
    for med in current_med_names:
        current = med.lower().strip()
        pair = frozenset([new_med, current])
        
        if pair in INTERACTION_RULES:
            rule = INTERACTION_RULES[pair]
            return InteractionResponse(
                warning=f"Interaction detected with {current.title()}: {rule['warning']}",
                severity=rule['severity']
            )
            
    # 2. AI Fallback (Gemini)
    if not os.getenv("GEMINI_API_KEY"):
         return InteractionResponse(warning=None, severity=None)
         
    try:
        model = genai.GenerativeModel("gemini-2.5-flash-preview-09-2025")
        current_list = ", ".join(current_med_names)
        
        prompt = f"""
        Act as a Clinical Pharmacist. Check for interactions between the new medication: "{new_med_name}" 
        and these current medications: "{current_list}".
        
        If there is a MODERATE, HIGH, or CONTRAINDICATED interaction, return a JSON object:
        {{
            "warning": "Brief clinical explanation of the risk.",
            "severity": "HIGH" or "MEDIUM"
        }}
        
        If there are NO significant interactions or only MILD ones, return:
        {{
            "warning": null,
            "severity": null
        }}
        
        Return ONLY valid JSON. No markdown.
        """
        
        response = model.generate_content(prompt)
        text = response.text.replace('```json', '').replace('```', '').strip()
        
        data = json.loads(text)
        
        return InteractionResponse(
            warning=data.get('warning'),
            severity=data.get('severity')
        )
        
    except Exception as e:
        print(f"AI Safety Check Failed: {e}")
        # Fail safe - allow if AI check fails, but log it
        return InteractionResponse(warning=None, severity=None)

class ExtractionRequest(BaseModel):
    text: str

class ExtractionResponse(BaseModel):
    name: Optional[str] = None
    dosage: Optional[str] = None
    time: Optional[str] = None

# --- NLP Logic ---

def _extract_regex_fallback(text: str) -> ExtractionResponse:
    """Fallback using Regex if AI fails"""
    text_clean = text.strip()
    text_lower = text_clean.lower()
    
    # 1. Extract Dosage (e.g. 50mg, 100 mg, 5ml)
    dosage_pattern = r"(\d+(\.\d+)?\s*(mg|g|mcg|ml|units|tablet|pill|cap))"
    dosage_match = re.search(dosage_pattern, text_lower)
    dosage = dosage_match.group(0) if dosage_match else None
    
    # 2. Extract Time
    # Semantic mapping
    time = None
    if "morning" in text_lower:
        time = "8:00 AM"
    elif "night" in text_lower or "bed" in text_lower:
        time = "9:00 PM"
    elif "lunch" in text_lower or "noon" in text_lower:
        time = "1:00 PM"
    else:
        # Regex for HH:MM AM/PM or HH AM/PM (e.g. 4pm, 4:00pm, 4 PM)
        time_pattern = r"(\d{1,2}(:\d{2})?\s*(AM|PM|am|pm))"
        time_match = re.search(time_pattern, text_clean, re.IGNORECASE) 
        if time_match:
            time = time_match.group(0).upper()
            # Normalize 4pm -> 4:00 PM
            if ":" not in time:
                parts = re.split(r"(AM|PM)", time)
                if len(parts) > 1:
                    time = f"{parts[0].strip()}:00 {parts[1]}"

    # 3. Extract Name
    
    # Remove dosage/time from considerations
    removable_parts = []
    if dosage: removable_parts.append(dosage)
    if time and 'time_match' in locals() and time_match: removable_parts.append(time_match.group(0))
    
    temp_text = text_clean
    for part in removable_parts:
        temp_text = temp_text.replace(part, "")
        
    # Stop Words (Verbs, Prepositions)
    STOP_WORDS = {"take", "give", "eat", "drink", "use", "apply", "medication", "medicine", "pill", "tablet", "capsule", "every", "at", "daily", "the", "a", "an", "for", "with", "in"}
    
    known_drugs = ["Lisinopril", "Metformin", "Atorvastatin", "Aspirin", "Ibuprofen", "Warfarin", "Advil", "Tylenol", "Amoxicillin", "Paracetamol"]
    name = None
    
    # Check Known List
    for drug in known_drugs:
        if drug.lower() in text_lower:
            name = drug
            break
            
    if not name:
        # Fallback: Find first capitalized word that is NOT a stop word
        words = temp_text.split()
        for w in words:
            clean_w = w.strip(".,!?").lower()
            if clean_w not in STOP_WORDS and len(clean_w) > 2 and w[0].isupper():
                name = w.strip(".,!?")
                break
        
        # If still no name, try non-capitalized words that aren't stop words
        if not name:
             for w in words:
                clean_w = w.strip(".,!?").lower()
                if clean_w not in STOP_WORDS and len(clean_w) > 3 and not any(char.isdigit() for char in w):
                     name = w.strip(".,!?").capitalize()
                     break

    return ExtractionResponse(name=name, dosage=dosage, time=time)

def extract_med_info(text: str) -> ExtractionResponse:
    """
    Extracts medication info using Gemini 2.0, falling back to regex.
    """
    if not os.getenv("GEMINI_API_KEY"):
        return _extract_regex_fallback(text)
        
    try:
        model = genai.GenerativeModel("gemini-2.5-flash-preview-09-2025")
        
        prompt = f"""
        Extract structured medication data from this text: "{text}"
        
        Return a valid JSON object with these keys:
        - name: (string, e.g. "Metformin")
        - dosage: (string, e.g. "500mg")
        - time: (string, normalized to HH:MM AM/PM format if possible, e.g. "08:00 AM". If vague like "morning", map to 08:00 AM, "night" to 09:00 PM)
        
        If a field is missing, use null.
        Example Output: {{"name": "Aspirin", "dosage": "81mg", "time": "08:00 AM"}}
        """
        
        response = model.generate_content(prompt)
        raw_text = response.text.replace('```json', '').replace('```', '').strip()
        data = json.loads(raw_text)
        
        return ExtractionResponse(
            name=data.get('name'),
            dosage=data.get('dosage'),
            time=data.get('time')
        )
        
    except Exception as e:
        print(f"Gemini NLP Extraction Failed: {e}")
        return _extract_regex_fallback(text)

# --- FHIR Logic ---
def _map_to_fhir(extraction: ExtractionResponse) -> dict:
    """
    Maps extraction result to a simplified FHIR R4 MedicationRequest.
    """
    # Generate a random ID for the resource
    import uuid
    resource_id = str(uuid.uuid4())
    
    # Current timestamp
    import datetime
    authored_on = datetime.datetime.utcnow().isoformat() + "Z"
    
    fhir_resource = {
        "resourceType": "MedicationRequest",
        "id": resource_id,
        "status": "active",
        "intent": "order",
        "authoredOn": authored_on,
        "medicationCodeableConcept": {
            "text": extraction.name or "Unknown Medication",
            "coding": [
                {
                    "system": "http://hl7.org/fhir/sid/icd-10", # Mocking system
                    "display": extraction.name or "Unknown"
                }
            ]
        },
        "dosageInstruction": [
            {
                "text": f"{extraction.dosage or ''} {extraction.time or ''}".strip(),
                "timing": {
                    "code": {
                        "text": extraction.time or "As needed"
                    }
                },
                "doseAndRate": [
                    {
                        "type": {
                            "coding": [
                                {
                                    "system": "http://terminology.hl7.org/CodeSystem/dose-rate-type",
                                    "code": "ordered",
                                    "display": "Ordered"
                                }
                            ]
                        },
                        "doseQuantity": {
                            "value": None, # Parsing dosage quantity is complex (e.g. "500mg" -> 500, "mg")
                            "unit": extraction.dosage
                        }
                    }
                ]
            }
        ]
    }
    return fhir_resource

# --- De-identification Logic ---
def _scrub_phi(text: str) -> str:
    """
    Basic Regex-based PHI scrubber.
    Removes Emails, Phone Numbers, and SSN-like patterns.
    """
    # 1. Emails
    text = re.sub(r'[\w\.-]+@[\w\.-]+\.\w+', '[EMAIL]', text)
    
    # 2. Phone Numbers (Simple: 3 digits - 3 digits - 4 digits)
    text = re.sub(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b', '[PHONE]', text)
    
    # 3. SSN / ID patterns (Simple: 3-2-4)
    text = re.sub(r'\b\d{3}-\d{2}-\d{4}\b', '[ID]', text)
    
    return text

# --- Endpoints ---
@app.get("/")
def root():
    return {"status": "Clinical Intelligence Service Running"}

@app.post("/interactions/check", response_model=InteractionResponse)
def check_interactions(request: InteractionCheckRequest):
    return check_for_interactions(request.new_med, request.current_meds)

@app.post("/nlp/extract", response_model=ExtractionResponse)
def nlp_extract(request: ExtractionRequest):
    return extract_med_info(request.text)

@app.post("/fhir/convert")
def fhir_convert(request: ExtractionRequest):
    """
    Extracts info and converts to FHIR.
    """
    extraction = extract_med_info(request.text)
    return _map_to_fhir(extraction)

@app.post("/nlp/deidentify")
def deidentify_text(request: ExtractionRequest):
    """
    Removes potential PHI from text.
    """
    clean_text = _scrub_phi(request.text)
    return {"original_length": len(request.text), "clean_text": clean_text}

# --- Document Analysis (Gemini) ---
@app.post("/documents/analyze")
async def analyze_document(file: UploadFile = File(...)):
    try:
        content = await file.read()
        
        # User requested 2.0+ models only
        models_to_try = [
            "gemini-2.5-flash-preview-09-2025", 
            "gemini-2.5-flash-image"
        ]
        
        last_error = None
        result_text = None

        prompt = """
        Analyze this medical document image. 
        Extract key clinical data such as:
        - Patient Name
        - Test Names and Results (Value + Unit)
        - Medication Names and Dosages
        - Date of Report
        
        Return the result as a clean, structured JSON object. 
        Example format:
        {
          "patient_name": "...",
          "date": "...",
          "tests": [{"name": "Hemoglobin", "value": "13.5", "unit": "g/dL"}],
          "medications": [...]
        }
        Only return the JSON. No markdown formatting.
        """

        for model_name in models_to_try:
            # Retry logic for Rate Limits (429)
            for attempt in range(3):
                try:
                    print(f"Attempting analysis with model: {model_name} (Try {attempt+1})")
                    model = genai.GenerativeModel(model_name)
                    response = model.generate_content([
                        {'mime_type': file.content_type, 'data': content},
                        prompt
                    ])
                    result_text = response.text
                    print(f"Success with {model_name}")
                    # Audit Log (Scrubbed)
                    print(f"Audit Log: {_scrub_phi(result_text)}")
                    break # Break retry loop
                except Exception as e:
                    print(f"Failed with {model_name}: {e}")
                    last_error = e
                    if "429" in str(e):
                        time.sleep(4) # Wait 4 seconds before retrying
                        continue
                    else:
                        break # Don't retry for non-429 errors (e.g. 404)
            
            if result_text:
                break # Break model loop if we have a result
        
        if result_text is None:
            raise last_error or Exception("All 2.0+ models failed. Please check Quota.")

        # Clean up JSON (remove markdowns)
        text = result_text.replace('```json', '').replace('```', '').strip()
        if text.startswith("```json"):
            text = text[7:-3].strip()
        if text.startswith("```"): 
            text = text[3:-3].strip()
            
        return {"status": "success", "data": text}
        
    except Exception as e:
        print(f"Gemini Analysis Failed: {e}")
        return {
            "status": "error", 
            "note": f"AI Analysis Failed: {str(e)}",
            "data": None
        }
