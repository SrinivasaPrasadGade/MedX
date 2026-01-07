# 🏥 MedX Health Platform

**MedX** is an advanced, AI-powered healthcare platform designed to bridge the gap between patients and their medication management. By leveraging **Google Gemini 2.0**, **Cloud Run**, and a modern **Flutter** interface, MedX provides intelligent insights, automated adherence tracking, and a seamless conversation experience for patients.

---

## 🚀 Features

### 🧠 AI & Clinical Intelligence
-   **Smart Chat Assistant**: A context-aware chatbot (powered by Gemini 2.5) that remembers conversation history and answers health queries.
-   **Drug Interaction Checks**: Real-time warnings about potential conflicts between medications (e.g., Warfarin vs. Ibuprofen).
-   **Smart Prescription Parsing**: Extract medication details (Name, Dosage, Frequency) from natural language text using NLP.
-   **Document Analysis**: Analyze uploaded medical reports or images to extract structured clinical data.
-   **PHI Scrubbing**: Automated sanitization of Protected Health Information (PHI) before processing.

### 📱 Patient App (Frontend)
-   **Dashboard**: Visual daily medication schedule and weekly adherence tracking chart.
-   **Medication Management**: Add, edit, and track medications. "Smart Add" feature uses AI to parse details.
-   **Profile Management**: Manage personal and insurance details.
-   **Responsive Design**: Built with Flutter for seamless use on Mobile and Web.

### ⚙️ Backend Services
-   **Microservices Architecture**: Decoupled services for Auth, Clinical, Medication, Analytics, and Notifications.
-   **API Gateway**: Unified entry point for all client requests.
-   **Real-time Analytics**: Tracks user adherence trends using **BigQuery**.

---

## 🛠️ Tech Stack & Technologies

### Frontend
-   **Framework**: Flutter (Dart)
-   **State Management**: Riverpod
-   **Navigation**: GoRouter
-   **Networking**: Dio
-   **UI Components**: Google Fonts, Fl_Chart (for analytics)

### Backend
-   **Language**: Python 3.11
-   **Framework**: FastAPI
-   **Server**: Uvicorn
-   **Architecture**: Microservices (REST)

### Cloud & Infrastructure
-   **Platform**: Google Cloud Platform (GCP)
-   **Compute**: Cloud Run (Serverless Container Deployment)
-   **CI/CD**: Cloud Build (Automated via `cloudbuild.yaml`)
-   **Database**: 
    -   **Firestore** (NoSQL for operational data & chat history)
    -   **BigQuery** (Data Warehouse for analytics)
-   **AI Models**: Google Gemini 2.5 Flash (via Vertex AI / Studio)

---

## 🔌 APIs & External Services

| Service | Endpoint Prefix | Purpose |
| :--- | :--- | :--- |
| **API Gateway** | `https://api-gateway-*.run.app` | Central ingress routing requests to appropriate services. |
| **Auth Service** | `/auth` | User registration (`/register`), Login (`/login`), Token validation. |
| **Clinical Service** | `/clinical` | AI Logic: `/chat`, `/interactions/check`, `/nlp/extract`, `/documents/analyze`. |
| **Medication Service** | `/medications` | CRUD operations for meds, adherence toggling. |
| **Analytics Service** | `/analytics` | Fetches weekly adherence stats from BigQuery. |
| **Notification Service** | `/notifications` | Sends reminders (currently mock/log based). |

---

## 📦 Dependencies & Packages

### Backend (Python/Pip)
-   `fastapi`, `uvicorn`: Web framework and server.
-   `google-generativeai`: SDK for Gemini models.
-   `google-cloud-firestore`: Database access.
-   `google-cloud-bigquery`: Analytics data access.
-   `python-multipart`: For file uploads.
-   `pydantic`: Data validation.
-   `python-dotenv`: Environment variable management.

### Frontend (Flutter/Pub)
-   `flutter_riverpod`: State management.
-   `go_router`: Routing.
-   `dio`: HTTP client.
-   `fl_chart`: Visualization.
-   `uuid`: Unique ID generation.
-   `firebase_core`: Firebase initialization.

---

## 🏗️ Installation & Setup

### Prerequisites
-   **Python 3.9+**
-   **Flutter SDK** (Latest Stable)
-   **Google Cloud SDK** (`gcloud`) CLI installed and authenticated.
-   **Git**

### 1. Clone the Repository
```bash
git clone https://github.com/SrinivasaPrasadGade/MedX.git
cd MedX
```

### 2. Backward Setup (Local)
Each service can be run locally. Example for `clinical-service`:
```bash
cd backend/clinical-service
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create .env file with your GEMINI_API_KEY
python3 main.py
```
*Repeat for other services on different ports (8001, 8002, 8003, etc).*

### 3. Frontend Setup
```bash
cd frontend/patient_app
flutter pub get
flutter run -d chrome
```

---

## 🚀 Deployment

The project is configured for **Automated Deployment** using Google Cloud Build.

### Auto-Deploy
Every push to the `main` branch triggers `cloudbuild.yaml`, which:
1.  Builds Docker images for all 6 services + Frontend.
2.  Deploys them to **Cloud Run**.

### Manual Deploy
You can also use the included script:
```bash
./deploy.sh
```

---

## 📝 Important Notes

-   **Authentication**: The deployed services are currently allowing unauthenticated access (`--allow-unauthenticated`) for the MVP phase. In production, this should be locked down.
-   **Browser Compatibility**: The Flutter Web app is optimized for Chrome/Edge.
-   **Data Privacy**: All AI analysis is stateless or scrubbed for PHI before logging. Chat history is stored securely in Firestore.

---

## 📂 Project Structure

```
MedX/
├── backend/
│   ├── api-gateway/         # Central Entry Point
│   ├── auth-service/        # Identity Provider
│   ├── clinical-service/    # AI & Gemini Logic
│   ├── medication-service/  # Core CRUD Logic
│   ├── analytics-service/   # BigQuery Stats
│   └── notification-service/# Email/Push Logic
├── frontend/
│   └── patient_app/         # Flutter Web/Mobile App
├── infrastructure/          # Terraform (IaC)
├── cloudbuild.yaml          # CI/CD Pipeline
├── deploy.sh                # Manual Deployment Script
└── README.md                # Project Documentation
```