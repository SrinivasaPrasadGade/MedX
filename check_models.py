import google.generativeai as genai
import os
from dotenv import load_dotenv

load_dotenv("backend/clinical-service/.env")
api_key = os.getenv("GEMINI_API_KEY")
print(f"Key found: {bool(api_key)}")

genai.configure(api_key=api_key)

print("Listing models...")
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)
