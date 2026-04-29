"""
Auth Router
-----------
Handles user registration, login, password reset (OTP-based),
and customer OTP verification.

All SMS dispatch is handled by app.services.sms_service.
All OTP persistence / verification is handled by app.services.otp_service.
"""

import logging
from types import SimpleNamespace

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    get_current_user,
    hash_password,
    verify_password,
)
from app.database import get_db
from app.models.customer import Customer
from app.models.user import User
from app.schemas.auth import (
    SendOTPRequest,
    SendOTPResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
)
from app.core.otp_service import create_otp, verify_otp
from app.core.sms_service import send_otp_sms

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth", tags=["Auth"])


# ---------------------------------------------------------------------------
# Request / Response schemas (local — only used in this file)
# ---------------------------------------------------------------------------

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


class VerifyResetOTPRequest(BaseModel):
    phone: str
    otp: str


class ResetPasswordRequest(BaseModel):
    phone: str
    new_password: str


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@router.post("/register")
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.phone == data.phone).first()
    if existing:
        raise HTTPException(status_code=400, detail="Phone number is already registered")

    user = User(
        name=data.name,
        phone=data.phone,
        email=data.email,
        password_hash=hash_password(data.password),
        role="customer",
        profile_completed=False,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return {"message": "User registered successfully"}


@router.post("/login")
def login(data: LoginRequest, db: Session = Depends(get_db)):
    if not data.phone or not data.password:
        raise HTTPException(status_code=400, detail="phone and password are required")

    logger.info("Login attempt for phone: %s", data.phone)

    try:
        user = db.query(User).filter(User.phone == data.phone).first()
    except ProgrammingError:
        # Schema migration may have added columns that the ORM expects but the DB
        # doesn't have yet. Fall back to a minimal raw query.
        logger.warning("ORM query failed; falling back to raw SQL for login.")
        try:
            db.rollback()
        except Exception:
            pass
        res = db.execute(
            text(
                "SELECT id, name, phone, password_hash, role, NULL AS profile_completed "
                "FROM users WHERE phone = :phone LIMIT 1"
            ),
            {"phone": data.phone},
        )
        row = res.fetchone()
        user = (
            SimpleNamespace(
                id=row[0],
                name=row[1],
                phone=row[2],
                password_hash=row[3],
                role=row[4],
                profile_completed=False,
            )
            if row
            else None
        )

    if not user:
        raise HTTPException(status_code=400, detail="Invalid credentials")

    if not verify_password(data.password, user.password_hash):
        raise HTTPException(status_code=400, detail="Invalid credentials")

    token = create_access_token(
        {"user_id": user.id, "phone": user.phone, "role": user.role}
    )

    logger.info("Login successful for phone: %s", data.phone)
    return {
        "token": token,
        "role": user.role,
        "profile_exists": bool(getattr(user, "profile_completed", False)),
    }


# ---------------------------------------------------------------------------
# Password reset flow  (forgot → verify OTP → reset)
# ---------------------------------------------------------------------------

@router.post("/forgot-password")
async def forgot_password(data: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user:
        # Return a generic message to avoid leaking whether a phone is registered
        return {"message": "If this number is registered, an OTP will be sent shortly."}

    otp = create_otp(db, phone=data.phone, purpose="reset_password")

    sms_sent = await send_otp_sms(phone=data.phone, otp=otp)
    if not sms_sent:
        logger.error("Failed to send reset-password OTP SMS to %s", data.phone)
        # Do not expose internal errors to the client; OTP is still valid in DB
        return {"message": "OTP generated. SMS delivery may be delayed — please retry if not received."}

    return {"message": "OTP sent successfully"}


@router.post("/verify-reset-otp")
def verify_reset_otp(data: VerifyResetOTPRequest, db: Session = Depends(get_db)):
    """Verify the password-reset OTP. Raises 400 on invalid / expired OTP."""
    verify_otp(db, phone=data.phone, otp=data.otp, purpose="reset_password")
    return {"message": "OTP verified successfully"}


@router.post("/reset-password")
def reset_password(data: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password_hash = hash_password(data.new_password)
    db.add(user)
    db.commit()
    db.refresh(user)

    logger.info("Password reset for phone: %s", data.phone)
    return {"message": "Password reset successfully"}


# ---------------------------------------------------------------------------
# Customer OTP flow  (send → verify)
# ---------------------------------------------------------------------------

@router.post("/send-otp", response_model=SendOTPResponse)
async def send_otp_endpoint(request: SendOTPRequest, db: Session = Depends(get_db)):
    try:
        customer = db.query(Customer).filter(Customer.id == int(request.customer_id)).first()
        if not customer:
            return SendOTPResponse(success=False, message="Customer not found")
        phone = customer.mobile_number
    except Exception:
        return SendOTPResponse(success=False, message="Invalid customer ID")

    otp = create_otp(db, phone=phone, purpose="customer_verification")

    sms_sent = await send_otp_sms(phone=phone, otp=otp)
    if not sms_sent:
        logger.error("Failed to send customer-verification OTP SMS to %s", phone)
        return SendOTPResponse(
            success=True,
            message="OTP generated. SMS delivery may be delayed — please retry if not received.",
        )

    return SendOTPResponse(success=True, message="OTP sent successfully")


@router.post("/verify-otp", response_model=VerifyOTPResponse)
def verify_otp_endpoint(request: VerifyOTPRequest, db: Session = Depends(get_db)):
    try:
        customer = db.query(Customer).filter(Customer.id == int(request.customer_id)).first()
        if not customer:
            return VerifyOTPResponse(success=False, message="Customer not found")
        phone = customer.mobile_number
    except Exception:
        return VerifyOTPResponse(success=False, message="Invalid customer ID")

    try:
        verify_otp(db, phone=phone, otp=request.otp, purpose="customer_verification")
    except HTTPException as exc:
        return VerifyOTPResponse(success=False, message=exc.detail)

    return VerifyOTPResponse(success=True, message="OTP verified successfully")


# ---------------------------------------------------------------------------
# Current user
# ---------------------------------------------------------------------------

@router.get("/me")
def get_current_user_info(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    user_id = current_user.get("user_id")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user.id,
        "name": user.name,
        "phone": user.phone,
        "email": user.email,
        "role": user.role,
        "profile_completed": user.profile_completed,
    }