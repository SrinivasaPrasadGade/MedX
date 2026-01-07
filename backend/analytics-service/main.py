from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from google.cloud import bigquery
from pydantic import BaseModel
from typing import List, Dict, Any
import os
import datetime

# --- App Initialization ---
app = FastAPI(title="MedX Analytics Service")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Configuration ---
# Project and Dataset should ideally come from env vars, hardcoding for MVP based on Terraform output
PROJECT_ID = "medx-health-platform" 
DATASET_ID = "medx_analytics"
TABLE_ID = "medication_events"

# --- BigQuery Client ---
# Using Application Default Credentials (ADC)
client = bigquery.Client(project=PROJECT_ID)

# --- Routes ---

@app.get("/")
async def root():
    return {"status": "Analytics Service Running", "project": PROJECT_ID}

@app.get("/weekly-adherence")
async def get_weekly_adherence():
    """
    Calculates medication adherence for the last 7 days.
    Returns a list of objects: {"day": "Mon", "value": 85.0}
    """
    try:
        # Query BigQuery to get counts of TAKEN vs TOTAL scheduled
        # Note: accurate total requires scheduling info. 
        # For this MVP, we will count 'TAKEN' events and assume a fixed schedule or 
        # estimate based on missed events if we logged them.
        # Alternatively, simpler metric: Count 'TAKEN' events per day.
        
        query = f"""
            SELECT
                FORMAT_DATE('%a', DATE(timestamp)) as day_name,
                COUNT(*) as taken_count
            FROM
                `{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}`
            WHERE
                DATE(timestamp) >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 DAY)
            GROUP BY
                day_name
            ORDER BY
                MIN(timestamp)
        """
        
        query_job = client.query(query)
        results = query_job.result()
        
        stats = []
        for row in results:
            # Simple heuristic: Assume 3 meds/day = 100%
            # If count is 3, value is 100. If 1, 33.
            val = min((row.taken_count / 3) * 100, 100)
            stats.append({
                "day": row.day_name,
                "value": round(val, 1)
            })
            
        return stats

    except Exception as e:
        print(f"BigQuery Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
