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
    role: str = "patient" # patient | provider | organization_admin | doctor
    organization_id: Optional[str] = None
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class UserCreate(UserBase):
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class UserResponse(UserBase):
    pass

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
        expire = datetime.utcnow() + timedelta(minutes=60) # Increased to 60m
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    doc_ref = db.collection(COLLECTION_NAME).document(email)
    doc = doc_ref.get()
    
    if not doc.exists:
        raise credentials_exception
        
    return doc.to_dict()

# --- Endpoints ---

@app.get("/")
async def root():
    return {"status": "Auth Service Running (Firestore)"}

@app.get("/me", response_model=UserResponse)
async def read_users_me(current_user: dict = Depends(get_current_user)):
    """Get current logged in user profile"""
    return current_user

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
        user_data = user.dict()
        user_data["hashed_password"] = hashed_password
        user_data["created_at"] = datetime.utcnow().isoformat()
        del user_data["password"] # Don't store plain password
        
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

    except Exception as e:
        print(f"Login Error: {e}")
        raise HTTPException(status_code=500, detail="Login failed")

@app.get("/users/doctors", response_model=list[UserResponse])
async def get_doctors(organization_id: str, current_user: dict = Depends(get_current_user)):
    """Get all doctors for a specific organization"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")
        
    try:
        users_ref = db.collection(COLLECTION_NAME)
        query = users_ref.where("organization_id", "==", organization_id).where("role", "==", "doctor")
        docs = query.stream()
        
        doctors = []
        for doc in docs:
            doctors.append(doc.to_dict())
            
        return doctors
    except Exception as e:
        print(f"Error fetching doctors: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch doctors")

class OrganizationRegister(BaseModel):
    org_name: str
    org_address: str
    admin_email: str
    admin_password: str
    admin_name: str

@app.post("/register-org")
async def register_organization(org: OrganizationRegister):
    """Register a new organization and its admin user"""
    if not db:
        raise HTTPException(status_code=503, detail="Database unavailable")

    try:
        # 1. Check if admin email exists
        user_ref = db.collection(COLLECTION_NAME).document(org.admin_email)
        if user_ref.get().exists:
             raise HTTPException(status_code=400, detail="Admin email already registered")

        # 2. Create Organization
        org_ref = db.collection("organizations").document()
        org_data = {
            "id": org_ref.id,
            "name": org.org_name,
            "address": org.org_address,
            "verified": False, # Requires manual verification
            "created_at": datetime.utcnow().isoformat()
        }
        org_ref.set(org_data)

        # 3. Create Admin User
        hashed_password = get_password_hash(org.admin_password)
        admin_user_data = {
            "email": org.admin_email,
            "full_name": org.admin_name,
            "hashed_password": hashed_password,
            "role": "organization_admin",
            "organization_id": org_ref.id,
            "created_at": datetime.utcnow().isoformat()
        }
        user_ref.set(admin_user_data)
        
        return {"message": "Organization registered successfully. Pending verification.", "org_id": org_ref.id}
    
    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Org Registration Error: {e}")
        raise HTTPException(status_code=500, detail="Registration failed")
