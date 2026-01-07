from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta
from jose import JWTError, jwt
import bcrypt
import os
from google.cloud import firestore

# --- Configuration ---
SECRET_KEY = os.getenv("SECRET_KEY", "YOUR_SUPER_SECRET_KEY_CHANGE_THIS_IN_PROD") 
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
COLLECTION_NAME = "users"

# --- App Initialization ---
app = FastAPI(title="MedX Auth Service")

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- Database Client ---
try:
    db = firestore.Client()
    print("✅ Firestore Client Initialized")
except Exception as e:
    print(f"❌ Firestore Init Failed: {e}")
    db = None

# --- Security ---
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# --- Models ---
class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None
    role: str = "patient" # patient | provider

class UserCreate(UserBase):
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

# --- Helper Functions ---
def verify_password(plain_password, hashed_password):
    return bcrypt.checkpw(
        plain_password.encode('utf-8'), 
        hashed_password.encode('utf-8')
    )

def get_password_hash(password):
    hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    return hashed.decode('utf-8')

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- Endpoints ---

@app.get("/")
async def root():
    return {"status": "Auth Service Running (Firestore)"}

@app.post("/register", response_model=Token)
async def register(user: UserCreate):
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    try:
        # 1. Check if user exists (Use email as Document ID)
        doc_ref = db.collection(COLLECTION_NAME).document(user.email)
        if doc_ref.get().exists:
             raise HTTPException(
                status_code=400, 
                detail="Email already registered"
            )

        # 2. Hash Password
        hashed_password = get_password_hash(user.password)

        # 3. Create User in Firestore
        user_data = {
            "email": user.email,
            "full_name": user.full_name,
            "role": user.role,
            "hashed_password": hashed_password,
            "created_at": datetime.utcnow()
        }
        doc_ref.set(user_data)
        
        # 4. Generate Token
        access_token = create_access_token(
            data={"sub": user.email, "role": user.role}
        )
        return {"access_token": access_token, "token_type": "bearer"}
    
    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Firestore Error: {e}")
        raise HTTPException(status_code=500, detail="Registration failed")

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    try:
        # 1. Fetch user from Firestore
        doc_ref = db.collection(COLLECTION_NAME).document(form_data.username)
        doc = doc_ref.get()
        
        if not doc.exists:
             raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        user_data = doc.to_dict()

        # 2. Verify Password
        if not verify_password(form_data.password, user_data['hashed_password']):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
            
        # 3. Generate Token
        access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user_data['email'], "role": user_data['role']}, 
            expires_delta=access_token_expires
        )
        return {"access_token": access_token, "token_type": "bearer"}

    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=500, detail="Login failed")
