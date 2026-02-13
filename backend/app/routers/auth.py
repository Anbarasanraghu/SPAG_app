from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel

import random
from datetime import datetime, timedelta
from twilio.rest import Client
from fastapi import HTTPException
from app.core.security import hash_password

from app.database import get_db
from app.models.user import User
from app.models.customer import Customer
from app.models.otp import OTPRequest
from app.core.security import create_access_token, hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["Auth"])


class RegisterRequest(BaseModel):
    name: str
    phone: str
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
        password_hash=hash_password(data.password),
        role="customer"
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully"}


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.phone == data.phone).first()

    if not user or not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    token = create_access_token({
        "user_id": user.id,
        "phone": user.phone,
        "role": user.role
    })

    # 🔥 CHECK PROFILE
    profile = db.query(Customer)\
        .filter(Customer.user_id == user.id)\
        .first()

    return {
        "token": token,
        "role": user.role,
        "profile_exists": profile is not None
    }


@router.post("/forgot-password")
def forgot_password(
    data: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    phone = data.phone

    user = db.query(User).filter(User.phone == phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    otp = str(random.randint(100000, 999999))
    expires_at = datetime.utcnow() + timedelta(minutes=5)

    otp_entry = OTPRequest(
        mobile_number=phone,
        otp=otp,
        purpose="reset_password",
        expires_at=expires_at
    )

    db.add(otp_entry)
    db.commit()

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