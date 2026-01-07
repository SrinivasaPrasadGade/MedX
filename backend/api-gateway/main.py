from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware
import httpx

app = FastAPI(title="MedX API Gateway")

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, replace with frontend URL (http://localhost:5200)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Service URLs (Cloud Run)
AUTH_SERVICE_URL = "https://auth-service-zxsaiaxzjq-uc.a.run.app"
CLINICAL_SERVICE_URL = "https://clinical-service-zxsaiaxzjq-uc.a.run.app"
MEDICATION_SERVICE_URL = "https://medication-service-zxsaiaxzjq-uc.a.run.app"
ANALYTICS_SERVICE_URL = "https://analytics-service-zxsaiaxzjq-uc.a.run.app"
NOTIFICATION_SERVICE_URL = "https://notification-service-zxsaiaxzjq-uc.a.run.app"

# Service Mappings
SERVICES = {
    "auth": AUTH_SERVICE_URL,
    "medications": MEDICATION_SERVICE_URL,
    "clinical": CLINICAL_SERVICE_URL,
    "analytics": ANALYTICS_SERVICE_URL,
    "notifications": NOTIFICATION_SERVICE_URL
}

client = httpx.AsyncClient(timeout=60.0)

async def forward_request(service_url: str, path: str, request: Request):
    url = f"{service_url}/{path}"
    
    # Forward headers, excluding host
    headers = dict(request.headers)
    headers.pop("host", None)
    headers.pop("content-length", None) # Let httpx handle this

    try:
        req = client.build_request(
            request.method,
            url,
            headers=headers,
            content=request.stream(),
            cookies=request.cookies,
            params=request.query_params
        )
        
        r = await client.send(req, stream=True)
        
        return StreamingResponse(
            r.aiter_raw(),
            status_code=r.status_code,
            headers=dict(r.headers),
            background=None
        )
    except httpx.ConnectError:
        raise HTTPException(status_code=503, detail="Service Unavailable")
    except Exception as e:
        import traceback
        return StreamingResponse(
            iter([traceback.format_exc().encode()]),
            status_code=500
        )

@app.on_event("shutdown")
async def shutdown_event():
    await client.aclose()

# Routes

# Auth Service
@app.api_route("/auth/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def auth_proxy(path: str, request: Request):
    return await forward_request(SERVICES["auth"], path, request)

# Medication Service
@app.api_route("/medications/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def medication_proxy(path: str, request: Request):
    # Note: The medication service likely expects paths starting with /medications or root.
    # If the service endpoint is /medications, and we strip it, it might fail.
    # Adjusting based on standard pattern: usually standard is Gateway /service/path -> Service /path
    return await forward_request(SERVICES["medications"], path, request)

# Clinical Service
@app.api_route("/clinical/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def clinical_proxy(path: str, request: Request):
    # Important: Documents upload (multipart) needs streaming which `forward_request` handles
    # But path mapping needs to be accurate. 
    # Current Clinical endpoints: /nlp/extract, /interactions/check, /documents/analyze
    # So if frontend calls /clinical/nlp/extract, we forward to 8002/nlp/extract.
    return await forward_request(SERVICES["clinical"], path, request)

# Analytics Service
@app.api_route("/analytics/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def analytics_proxy(path: str, request: Request):
    return await forward_request(SERVICES["analytics"], path, request)

# Notification Service
@app.api_route("/notifications/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def notifications_proxy(path: str, request: Request):
    return await forward_request(SERVICES["notifications"], path, request)

@app.get("/")
def root():
    return {"status": "MedX Gateway Running", "services": SERVICES}
