from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from types import SimpleNamespace
from pydantic import BaseModel

import random
from datetime import datetime, timedelta
from twilio.rest import Client
from fastapi import HTTPException
from app.core.security import hash_password, get_current_user

from app.database import get_db
from app.models.user import User
from app.models.customer import Customer
from app.models.otp import OTPRequest
from app.core.security import create_access_token, hash_password, verify_password
from app.schemas.auth import SendOTPRequest, SendOTPResponse, VerifyOTPRequest, VerifyOTPResponse

# Helper function for OTP generation
def generate_otp() -> str:
    """Generate a secure 6-digit OTP."""
    return str(random.randint(100000, 999999))

router = APIRouter(prefix="/auth", tags=["Auth"])


class RegisterRequest(BaseModel):
    name: str
    phone: str
    email: str
    password: str


class LoginRequest(BaseModel):
    phone: str
    password: str

class ForgotPasswordRequest(BaseModel):
    phone: str


class ResetPasswordRequest(BaseModel):
    phone: str
    new_password: str


@router.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone == data.phone).first()

    if existing:
        raise HTTPException(status_code=400, detail="Phone already registered")

    user = User(
        name=data.name,
        phone=data.phone,
        email=data.email,
        password_hash=hash_password(data.password),
        role="customer",
        profile_completed=False
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully"}


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    import logging
    logger = logging.getLogger(__name__)
    
    try:
        # Validate required fields
        if not data.phone or not data.password:
            logger.error("Missing phone or password in login request")
            raise HTTPException(status_code=400, detail="phone and password are required")
        
        logger.info(f"Login attempt for phone: {data.phone}")
        
        try:
            user = db.query(User).filter(User.phone == data.phone).first()
        except ProgrammingError as e:
            logger.error(f"ProgrammingError in login: {e}")
            # ORM query failed due to missing columns; rollback the session and run a minimal raw query
            try:
                db.rollback()
            except Exception:
                pass
            # fallback: DB may be missing newly-added columns (email/profile_completed).
            # Query minimal columns directly and construct a lightweight object.
            res = db.execute(text("SELECT id, name, phone, password_hash, role, NULL as profile_completed FROM users WHERE phone = :phone LIMIT 1"), {"phone": data.phone})
            row = res.fetchone()
            if row:
                user = SimpleNamespace(id=row[0], name=row[1], phone=row[2], password_hash=row[3], role=row[4], profile_completed=False)
            else:
                user = None

        if not user:
            logger.error(f"User not found for phone: {data.phone}")
            raise HTTPException(status_code=400, detail="Invalid credentials")
        
        if not verify_password(data.password, user.password_hash):
            logger.error(f"Password verification failed for phone: {data.phone}")
            raise HTTPException(status_code=400, detail="Invalid credentials")

        token = create_access_token({
            "user_id": user.id,
            "phone": user.phone,
            "role": user.role
        })

        logger.info(f"Login successful for phone: {data.phone}")
        
        # 🔥 CHECK PROFILE (use profile_completed flag)
        return {
            "token": token,
            "role": user.role,
            "profile_exists": bool(getattr(user, "profile_completed", False))
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.exception(f"Unexpected error in login: {e}")
        raise HTTPException(status_code=500, detail=f"Login error: {str(e)}")


@router.post("/forgot-password")
async def forgot_password(
    data: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    import httpx

    phone = data.phone

    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    otp = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=5)

    otp_entry = OTPRequest(
        mobile_number=phone,
        otp=otp,
        purpose="reset_password",
        expires_at=expires_at
    )

    db.add(otp_entry)
    db.commit()

    # Send SMS via MSG91 Transactional SMS API
    url = "https://control.msg91.com/api/v5/sms"
    message = "THIS IS OTP FOR RESET PASSWORD {#numeric#}, AND THANKS FOR REACHING SPAG EAGLE GLOBAL PRIVATE LIMITED".replace("{#numeric#}", otp)
    payload = {
        "authkey": "493513A7e0g1DCcK69df481fP1",
        "mobiles": phone,  # Remove 91 prefix - MSG91 adds it automatically for Indian numbers
        "message": message,
        "sender": "SPAGGL",
        "country": "91",
        "DLT_TE_ID": "1107177607188322509"
    }
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, data=payload)
            print(f"SMS response for {phone}: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Failed to send SMS: {e}")
        # Continue anyway - OTP is stored in DB

    print(f"RESET OTP for {phone}: {otp}")

    return {"message": "OTP sent successfully"}

@router.post("/verify-reset-otp")
def verify_reset_otp(phone: str, otp: str, db: Session = Depends(get_db)):

    otp_record = db.query(OTPRequest).filter(
        OTPRequest.phone == phone,
        OTPRequest.otp == otp,
        OTPRequest.purpose == "reset_password",
        OTPRequest.is_verified == False
    ).order_by(OTPRequest.created_at.desc()).first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_record.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    otp_record.is_verified = True
    db.commit()

    return {"message": "OTP verified successfully"}


@router.post("/reset-password")
def reset_password(
    data: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    print("Reset request for:", data.phone)

    user = db.query(User).filter(User.phone == data.phone).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    print("Old hash:", user.password_hash)

    new_hash = hash_password(data.new_password)
    user.password_hash = new_hash

    db.add(user)
    db.commit()
    db.refresh(user)

    print("New hash:", user.password_hash)

    return {"message": "Password reset successfully"}


@router.post("/send-otp", response_model=SendOTPResponse)
async def send_otp_endpoint(request: SendOTPRequest, db: Session = Depends(get_db)):
    import httpx

    # Look up customer mobile number
    try:
        customer = db.query(Customer).filter(Customer.id == int(request.customer_id)).first()
        if not customer:
            return SendOTPResponse(success=False, message="Customer not found")
        phone = customer.mobile_number
    except Exception as e:
        return SendOTPResponse(success=False, message="Invalid customer ID")

    # Generate OTP
    otp = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=5)

    # Store in database (same as forgot-password)
    otp_entry = OTPRequest(
        mobile_number=phone,
        otp=otp,
        purpose="customer_verification",
        expires_at=expires_at
    )

    db.add(otp_entry)
    db.commit()

    # Send SMS via MSG91 Transactional SMS API
    url = "https://control.msg91.com/api/v5/sms"
    message = "THIS IS OTP FOR RESET PASSWORD {#numeric#}, AND THANKS FOR REACHING SPAG EAGLE GLOBAL PRIVATE LIMITED".replace("{#numeric#}", otp)
    payload = {
        "authkey": "493513A7e0g1DCcK69df481fP1",
        "mobiles": phone,
        "message": message,
        "sender": "SPAGGL",
        "country": "91",
        "DLT_TE_ID": "1107177607188322509"
    }

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(url, data=payload)
            print(f"SMS response for customer {request.customer_id} ({phone}): {response.status_code} - {response.text}")
    except Exception as e:
        print(f"Failed to send SMS: {e}")

    print(f"CUSTOMER OTP for {phone}: {otp}")

    return SendOTPResponse(success=True, message="OTP sent successfully")


@router.post("/verify-otp", response_model=VerifyOTPResponse)
def verify_otp_endpoint(request: VerifyOTPRequest, db: Session = Depends(get_db)):
    # Look up customer mobile number
    try:
        customer = db.query(Customer).filter(Customer.id == int(request.customer_id)).first()
        if not customer:
            return VerifyOTPResponse(success=False, message="Customer not found")
        phone = customer.mobile_number
    except Exception as e:
        return VerifyOTPResponse(success=False, message="Invalid customer ID")

    # Verify OTP using database (same as verify-reset-otp)
    otp_record = db.query(OTPRequest).filter(
        OTPRequest.mobile_number == phone,
        OTPRequest.otp == request.otp,
        OTPRequest.purpose == "customer_verification",
        OTPRequest.is_verified == False
    ).order_by(OTPRequest.created_at.desc()).first()

    if not otp_record:
        return VerifyOTPResponse(success=False, message="Invalid OTP")

    if otp_record.expires_at < datetime.utcnow():
        return VerifyOTPResponse(success=False, message="OTP expired")

    otp_record.is_verified = True
    db.commit()

    return VerifyOTPResponse(success=True, message="OTP verified successfully")


@router.get("/me")
def get_current_user_info(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get current authenticated user's information"""
    user_id = current_user.get("user_id")
    
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        
        return {
            "id": user.id,
            "name": user.name,
            "phone": user.phone,
            "email": user.email,
            "role": user.role,
            "profile_completed": user.profile_completed
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching user info: {str(e)}")