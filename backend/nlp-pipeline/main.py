import functions_framework
from google.cloud import storage
import json

@functions_framework.cloud_event
def ingest_document(cloud_event):
    """
    Triggered by a change to a Cloud Storage bucket.
    Ingests the document and triggers the NLP extraction.
    """
    data = cloud_event.data

    bucket_name = data["bucket"]
    file_name = data["name"]
    content_type = data["contentType"]
    
    print(f"Processing file: {file_name} from bucket: {bucket_name}")

    if "pdf" in content_type or "image" in content_type:
        print("Detected clinical document. Initiating OCR & NLP analysis...")
        # TODO: Call Cloud Vision API for OCR
        # TODO: Publish message to Pub/Sub 'nlp-processing-queue'
        
    elif "text" in content_type:
        print("Detected text file. Initiating NLP analysis...")
        # TODO: Publish message to Pub/Sub 'nlp-processing-queue'
        
    else:
        print(f"Unsupported file type: {content_type}")
