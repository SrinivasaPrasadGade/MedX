#!/bin/bash

# MedX Deployment Script
# Automates building and deploying all microservices to Google Cloud Run.

set -e # Exit on error

# Ensure gcloud is in PATH
export PATH=$PATH:/Users/srinivasaprasad/Documents/MedX/google-cloud-sdk/bin

# Load Environment Variables from Clinical Service .env
if [ -f backend/clinical-service/.env ]; then
  export $(cat backend/clinical-service/.env | grep -v '#' | xargs)
  echo "✅ Loaded GEMINI_API_KEY from .env"
else
  echo "⚠️ Warning: backend/clinical-service/.env not found"
fi

# 0. Setup
echo "🔹 Initializing Deployment..."
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"

if [ -z "$PROJECT_ID" ]; then
  echo "❌ Error: No Google Cloud Project set. Run 'gcloud config set project <PROJECT_ID>' first."
  exit 1
fi

echo "✅ Project ID: $PROJECT_ID"
echo "✅ Region: $REGION"
echo ""

# Function to deploy a service
deploy_service() {
  SERVICE_NAME=$1
  DIR=$2
  PORT=$3
  
  echo "🚀 Deploying $SERVICE_NAME..."
  
  # 1. Build Container
  echo "   Building container image..."
  gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME $DIR --quiet
  
  # 2. Deploy to Cloud Run
  echo "   Deploying to Cloud Run..."
  gcloud run deploy $SERVICE_NAME \
    --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
    --platform managed \
    --region $REGION \
    --port $PORT \
    --allow-unauthenticated \
    --set-env-vars GOOGLE_CLOUD_PROJECT=$PROJECT_ID,PROJECT_ID=$PROJECT_ID,GEMINI_API_KEY=${GEMINI_API_KEY} \
    --quiet
    
  echo "✅ $SERVICE_NAME deployed successfully!"
  echo ""
}

# 1. Backend Services
deploy_service "auth-service" "backend/auth-service" 8000
deploy_service "clinical-service" "backend/clinical-service" 8002
deploy_service "medication-service" "backend/medication-service" 8001
deploy_service "analytics-service" "backend/analytics-service" 8003
deploy_service "notification-service" "backend/notification-service" 8004
deploy_service "appointment-service" "backend/appointment-service" 8005

# 2. API Gateway
# Note: In a real prod env, Gateway would point to Cloud Run URLs, not localhost.
# For this MVP, we might need to manually update Gateway config after deployment or use Cloud Run service discovery.
# For now, we deploy it as is.
deploy_service "api-gateway" "backend/api-gateway" 8080

# 3. Frontend
echo "🚀 Deploying Patient App (Frontend)..."
# Build Docker image for frontend
gcloud builds submit --tag gcr.io/$PROJECT_ID/patient-app frontend/patient_app --quiet

# Deploy Frontend
gcloud run deploy patient-app \
  --image gcr.io/$PROJECT_ID/patient-app \
  --platform managed \
  --region $REGION \
  --port 80 \
  --allow-unauthenticated \
  --quiet

echo "✅ Patient App deployed successfully!"
echo ""

# 4. Provider Portal
echo "🚀 Deploying Provider Portal..."
# Build Docker image for provider portal
gcloud builds submit --tag gcr.io/$PROJECT_ID/provider-portal frontend/provider-portal --quiet

# Deploy Provider Portal
gcloud run deploy provider-portal \
  --image gcr.io/$PROJECT_ID/provider-portal \
  --platform managed \
  --region $REGION \
  --port 3000 \
  --allow-unauthenticated \
  --quiet

echo "✅ Provider Portal deployed successfully!"
echo ""

echo "🎉 Deployment Complete!"
echo "You can access your services via the URLs listed above."
