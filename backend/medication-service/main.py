from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid
import os
from google.cloud import bigquery
from google.cloud import firestore

# --- Configurations ---
PROJECT_ID = os.getenv("GOOGLE_CLOUD_PROJECT", "medx-health-platform")
DATASET_ID = "medx_analytics"
TABLE_ID = "medication_events"
COLLECTION_NAME = "medications"

# --- App Initialization ---
app = FastAPI(title="MedX Medication Service")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Database Clients ---
# Firestore
try:
    db = firestore.Client()
    print("✅ Firestore Client Initialized")
except Exception as e:
    print(f"❌ Firestore Init Failed: {e}")
    db = None

# BigQuery
try:
    bq_client = bigquery.Client()
    print("✅ BigQuery Client Initialized")
except Exception as e:
    print(f"❌ BigQuery Init Failed: {e}")
    bq_client = None

@app.on_event("startup")
async def startup_event():
    # Ensure BigQuery Table Exists
    if bq_client:
        try:
            dataset_ref = bq_client.dataset(DATASET_ID)
            table_ref = dataset_ref.table(TABLE_ID)
            try:
                bq_client.get_table(table_ref)
            except Exception:
                schema = [
                    bigquery.SchemaField("event_id", "STRING", mode="REQUIRED"),
                    bigquery.SchemaField("med_id", "STRING", mode="REQUIRED"),
                    bigquery.SchemaField("event_type", "STRING", mode="REQUIRED"),
                    bigquery.SchemaField("status", "STRING", mode="NULLABLE"),
                    bigquery.SchemaField("timestamp", "TIMESTAMP", mode="REQUIRED"),
                    bigquery.SchemaField("details", "STRING", mode="NULLABLE"),
                ]
                table = bigquery.Table(table_ref, schema=schema)
                bq_client.create_table(table)
                print(f"Created BigQuery table: {TABLE_ID}")
        except Exception as e:
            print(f"BigQuery Setup Failed: {e}")

# --- Models ---
class Medication(BaseModel):
    id: Optional[str] = None
    name: str
    dosage: str
    time: str
    isTaken: bool = False

class MedicationCreate(BaseModel):
    name: str
    dosage: str
    time: str

# --- Endpoints ---

@app.get("/")
async def root():
    return {"status": "Medication Service Running (Firestore)"}

@app.get("/medications", response_model=List[Medication])
async def get_medications():
    """Fetch all medications from Firestore."""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    try:
        meds_ref = db.collection(COLLECTION_NAME)
        docs = meds_ref.stream()
        
        results = []
        for doc in docs:
            data = doc.to_dict()
            data['id'] = doc.id
            results.append(Medication(**data))
        return results
    except Exception as e:
        print(f"Firestore Read Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/medications", response_model=Medication)
async def add_medication(med: MedicationCreate):
    """Add a new medication to Firestore."""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    try:
        doc_ref = db.collection(COLLECTION_NAME).document()
        new_med_data = {
            "name": med.name,
            "dosage": med.dosage,
            "time": med.time,
            "isTaken": False
        }
        doc_ref.set(new_med_data)
        
        # Log to BigQuery
        if bq_client:
            row = {
                "event_id": str(uuid.uuid4()),
                "med_id": doc_ref.id,
                "event_type": "MEDICATION_ADDED",
                "status": "SCHEDULED",
                "timestamp": datetime.utcnow().isoformat(),
                "details": f"Added {med.name}"
            }
            bq_client.insert_rows_json(bq_client.dataset(DATASET_ID).table(TABLE_ID), [row])
        
        return Medication(id=doc_ref.id, **new_med_data)
    except Exception as e:
        print(f"Firestore Write Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.patch("/medications/{med_id}/toggle", response_model=Medication)
async def toggle_medication(med_id: str):
    """Toggle isTaken status in Firestore."""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    try:
        doc_ref = db.collection(COLLECTION_NAME).document(med_id)
        doc = doc_ref.get()
        
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Medication not found")
            
        current_data = doc.to_dict()
        new_status = not current_data.get("isTaken", False)
        
        doc_ref.update({"isTaken": new_status})
        
        # Log to BigQuery
        if bq_client:
            row = {
                "event_id": str(uuid.uuid4()),
                "med_id": med_id,
                "event_type": "MEDICATION_TOGGLED", 
                "status": "TAKEN" if new_status else "SKIPPED",
                "timestamp": datetime.utcnow().isoformat(),
                "details": str(new_status)
            }
            bq_client.insert_rows_json(bq_client.dataset(DATASET_ID).table(TABLE_ID), [row])
            print(f"✅ Logged to BigQuery: {row}")
            
        current_data['isTaken'] = new_status
        current_data['id'] = med_id
        return Medication(**current_data)
        
    except Exception as e:
        print(f"Firestore Update Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
