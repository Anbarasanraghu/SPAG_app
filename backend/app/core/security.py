from datetime import datetime, timedelta
from fastapi.security import HTTPBearer, OAuth2PasswordBearer, HTTPAuthorizationCredentials
from fastapi import Depends, HTTPException, status
import jwt
from passlib.context import CryptContext


security = HTTPBearer()

SECRET_KEY = "spag_super_secure_secret_key_2026_admin_panel"
ALGORITHM = "HS256"

def create_access_token(data: dict):
    to_encode = data.copy()
    to_encode["exp"] = datetime.utcnow() + timedelta(days=30)
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)



pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str):
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str):
    if not hashed_password:
        return False

    # bcrypt hashes are ~60 chars
    if len(hashed_password) < 50:
        return False

    return pwd_context.verify(plain_password, hashed_password)

# oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/verify-otp")

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload  # returns dict {user_id, phone}
    except jwt.PyJWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
    
def require_admin(user=Depends(get_current_user)):
    if user["role"] != "admin":
        raise HTTPException(status_code=403)
    return user

def require_technician(user=Depends(get_current_user)):
    if user["role"] != "technician":
        raise HTTPException(status_code=403)
    return user

