from datetime import datetime, timedelta
from fastapi.security import HTTPBearer, OAuth2PasswordBearer, HTTPAuthorizationCredentials
from fastapi import Depends, HTTPException, status
import jwt


security = HTTPBearer()

SECRET_KEY = "spag_super_secure_secret_key_2026_admin_panel"
ALGORITHM = "HS256"

def create_access_token(data: dict):
    to_encode = data.copy()
    to_encode["exp"] = datetime.utcnow() + timedelta(days=30)
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


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

