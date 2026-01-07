import os
import json
from flask import Flask, request
from google.cloud import healthcare_v1
import uuid

app = Flask(__name__)

@app.route("/map-to-fhir", methods=["POST"])
def map_to_fhir():
    """
    Input: JSON list of entities (e.g., {"name": "Aspirin", "type": "MEDICINE_NAME"})
    Output: FHIR Bundle containing MedicationStatement, Condition, etc.
    """
    data = request.get_json()
    if not data or "entities" not in data:
        return "Bad Request: No entities provided", 400
        
    entities = data["entities"]
    patient_id = data.get('patientId', 'unknown')
    resources = []
    
    # Generate UUID for the Bundle
    bundle_id = str(uuid.uuid4())
    
    for entity in entities:
        print(f"Mapping entity: {entity['name']} ({entity['type']})")
        
        if entity['type'] == 'MEDICINE_NAME':
            # Create MedicationStatement resource
            resource = {
                "resourceType": "MedicationStatement",
                "id": str(uuid.uuid4()),
                "status": "active",
                "subject": {"reference": f"Patient/{patient_id}"},
                "medicationCodeableConcept": {
                    "text": entity['name']
                },
                "dateAsserted": "2024-01-01T00:00:00Z" 
            }
            resources.append(resource)
            
        elif entity['type'] == 'DIAGNOSIS':
             # Create Condition resource
            resource = {
                "resourceType": "Condition",
                "id": str(uuid.uuid4()),
                "clinicalStatus": {
                    "coding": [{"system": "http://terminology.hl7.org/CodeSystem/condition-clinical", "code": "active"}]
                },
                "code": {
                    "text": entity['name']
                },
                "subject": {"reference": f"Patient/{patient_id}"}
            }
            resources.append(resource)

    # Wrap in Transaction Bundle
    fhir_bundle = {
        "resourceType": "Bundle",
        "id": bundle_id,
        "type": "transaction",
        "entry": [{"resource": r, "request": {"method": "POST", "url": r["resourceType"]}} for r in resources]
    }
    
    return json.dumps(fhir_bundle), 200

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
