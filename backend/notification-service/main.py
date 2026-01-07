from fastapi import FastAPI, HTTPException, Body
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import firebase_admin
from firebase_admin import credentials, messaging
import os

# --- App Initialization ---
app = FastAPI(title="MedX Notification Service")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Firebase Init (Mockable) ---
# Check for credentials file, else mock
CRED_PATH = "serviceAccountKey.json"
if os.path.exists(CRED_PATH):
    cred = credentials.Certificate(CRED_PATH)
    firebase_admin.initialize_app(cred)
    FIREBASE_ENABLED = True
else:
    print("Warning: serviceAccountKey.json not found. Notifications will be mocked.")
    FIREBASE_ENABLED = False

# --- Models ---
class NotificationRequest(BaseModel):
    user_id: str # Ideally would map to FCM token in DB
    fcm_token: Optional[str] = None # Direct token for testing
    title: str
    body: str
    data: Optional[dict] = None

# --- Routes ---

@app.get("/")
async def root():
    return {
        "status": "Notification Service Running", 
        "mode": "Live" if FIREBASE_ENABLED else "Mocked"
    }

@app.post("/send")
async def send_notification(notification: NotificationRequest):
    """
    Sends a push notification to a user via FCM.
    """
    print(f"Received Notification Request: {notification}")

    if not FIREBASE_ENABLED:
        # Mock success
        return {"status": "success", "message": "Notification mocked (FCM not configured)", "id": "mock-id-123"}
    
    # 1. Get Token (Simulated logic: in production, fetch from DB using user_id)
    target_token = notification.fcm_token
    if not target_token:
        # Mock lookup
        # target_token = db.get_token(notification.user_id)
        raise HTTPException(status_code=400, detail="FCM Token required (User ID lookup not implemented yet)")

    # 2. Construct Message
    message = messaging.Message(
        notification=messaging.Notification(
            title=notification.title,
            body=notification.body,
        ),
        data=notification.data,
        token=target_token,
    )

    try:
        # 3. Send
        response = messaging.send(message)
        return {"status": "success", "message": "Notification sent", "id": response}
    except Exception as e:
        print(f"FCM Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
