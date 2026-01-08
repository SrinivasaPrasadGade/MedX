from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import os
from google.cloud import firestore

app = FastAPI(title="MedX Appointment Service")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database
try:
    db = firestore.Client()
    print("✅ Firestore Client Initialized")
except Exception as e:
    print(f"❌ Firestore Init Failed: {e}")
    db = None

# Models
class Availability(BaseModel):
    doctor_id: str
    day_of_week: str # e.g., "Monday"
    start_time: str # "09:00"
    end_time: str # "17:00"

class AppointmentCreate(BaseModel):
    doctor_id: str
    patient_id: str
    datetime: str # ISO format
    notes: Optional[str] = None

class Appointment(AppointmentCreate):
    id: str
    status: str = "scheduled" # scheduled, completed, cancelled

# Endpoints

@app.get("/")
def root():
    return {"status": "Appointment Service Running"}

@app.post("/availability")
async def set_availability(avail: Availability):
    """Set availability for a doctor on a specific day"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    try:
        # Store in a subcollection or root collection
        # Let's use root collection 'availabilities' for simple querying
        doc_ref = db.collection("availabilities").document(f"{avail.doctor_id}_{avail.day_of_week}")
        doc_ref.set(avail.dict())
        return {"message": "Availability set successfully"}
    except Exception as e:
        print(f"Error setting availability: {e}")
        raise HTTPException(status_code=500, detail="Failed to set availability")

@app.get("/availability/{doctor_id}")
async def get_availability(doctor_id: str):
    """Get weekly availability for a doctor"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
        
    try:
        docs = db.collection("availabilities").where("doctor_id", "==", doctor_id).stream()
        return [doc.to_dict() for doc in docs]
    except Exception as e:
        print(f"Error fetching availability: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch availability")

@app.post("/appointments", response_model=Appointment)
async def book_appointment(appt: AppointmentCreate):
    """Book a new appointment"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
        
    try:
        doc_ref = db.collection("appointments").document()
        new_appt = appt.dict()
        new_appt["id"] = doc_ref.id
        new_appt["status"] = "scheduled"
        
        doc_ref.set(new_appt)
        return new_appt
    except Exception as e:
        print(f"Error booking appointment: {e}")
        raise HTTPException(status_code=500, detail="Failed to book appointment")

@app.get("/appointments")
async def list_appointments(doctor_id: Optional[str] = None, patient_id: Optional[str] = None):
    """List appointments filterable by doctor or patient"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
        
    try:
        ref = db.collection("appointments")
        if doctor_id:
            ref = ref.where("doctor_id", "==", doctor_id)
        if patient_id:
            ref = ref.where("patient_id", "==", patient_id)
            
        docs = ref.stream()
        return [doc.to_dict() for doc in docs]
    except Exception as e:
        print(f"Error listing appointments: {e}")
        raise HTTPException(status_code=500, detail="Failed to list appointments")
