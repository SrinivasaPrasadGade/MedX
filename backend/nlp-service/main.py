import os
import json
from flask import Flask, request
from google.cloud import language_v1
from google.cloud import healthcare_v1

app = Flask(__name__)

# Initialize Healthcare API Client
client = language_v1.LanguageServiceClient()

@app.route("/", methods=["POST"])
def process_document():
    """
    Receives Pub/Sub message with document details.
    Calls Healthcare NLP API to extract entities.
    """
    envelope = request.get_json()
    if not envelope:
        return "Bad Request: No Pub/Sub message received", 400

    pubsub_message = envelope.get("message")
    if not pubsub_message:
        return "Bad Request: Invalid Pub/Sub message", 400
    
    # Decode message data
    import base64
    data_str = base64.b64decode(pubsub_message["data"]).decode("utf-8")
    data = json.loads(data_str)
    
    text_content = data.get("text")
    if not text_content:
        return "Error: No text content provided", 400
        
    print(f"Processing NLP for document...")
    
    # Call Healthcare Natural Language API
    document = language_v1.Document(
        content=text_content, 
        type_=language_v1.Document.Type.PLAIN_TEXT,
        language="en"
    )
    
    # Analyze Entities using standard Cloud Natural Language (as proxy for Healthcare NLP)
    response = client.analyze_entities(document=document)
    
    entities = []
    for entity in response.entities:
        entities.append({
            "name": entity.name,
            "type": language_v1.Entity.Type(entity.type_).name,
            "salience": entity.salience
        })
        
    print(f"Extracted {len(entities)} entities.")
    
    # TODO: Transform to FHIR Resources
    # TODO: Store in FHIR Store
    
    return "OK", 200

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
