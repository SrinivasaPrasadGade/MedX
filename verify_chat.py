import requests
import json
import uuid

# Base URL (Gateway)
# URL from your deployment log
BASE_URL = "https://api-gateway-1070962557424.us-central1.run.app" 

# Use the clinical proxy path
CHAT_URL = f"{BASE_URL}/clinical/chat"

def test_chat():
    session_id = str(uuid.uuid4())
    print(f"🔹 Starting Chat Session: {session_id}")

    # 1. First Turn: Establish Context
    msg1 = "I have been prescribed Warfarin for my heart condition."
    print(f"\nUser: {msg1}")
    
    try:
        r1 = requests.post(CHAT_URL, json={"session_id": session_id, "message": msg1})
        if r1.status_code == 200:
            print(f"AI: {r1.json()['response']}")
        else:
            print(f"❌ Error: {r1.text}")
            return
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        return

    # 2. Second Turn: Test Memory
    msg2 = "Is it safe for me to take Ibuprofen for a headache?"
    print(f"\nUser: {msg2}")
    
    try:
        r2 = requests.post(CHAT_URL, json={"session_id": session_id, "message": msg2})
        if r2.status_code == 200:
            print(f"AI: {r2.json()['response']}")
            
            # Validation
            reply = r2.json()['response'].lower()
            if "warfarin" in reply or "bleeding" in reply or "interaction" in reply:
                print("\n✅ SUCCESS: AI remembered the context and warned about interaction.")
            else:
                print("\n⚠️ WARNING: AI might have forgotten context.")
        else:
            print(f"❌ Error: {r2.text}")
    except Exception as e:
        print(f"❌ Connection Failed: {e}")
        return

test_chat()
