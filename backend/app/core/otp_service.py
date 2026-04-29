"""
OTP Service — generation, persistence, and verification.
Keeps all OTP business logic out of route handlers.
"""

import logging
import random
from datetime import datetime, timedelta

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.otp import OTPRequest

logger = logging.getLogger(__name__)

OTP_EXPIRY_MINUTES = 5


def generate_otp() -> str:
    """Generate a cryptographically adequate 6-digit OTP."""
    # secrets.randbelow gives a uniform distribution; random.randint is fine for
    # 6-digit OTPs but swap to secrets if your security policy demands it.
    return str(random.randint(100000, 999999))


def create_otp(db: Session, phone: str, purpose: str) -> str:
    """
    Generate a new OTP, persist it, and return the plaintext value.

    Args:
        db:      SQLAlchemy session.
        phone:   10-digit mobile number (no country code).
        purpose: Logical label, e.g. "reset_password" or "customer_verification".

    Returns:
        The generated OTP string (caller passes it to the SMS service).
    """
    otp = generate_otp()
    expires_at = datetime.utcnow() + timedelta(minutes=OTP_EXPIRY_MINUTES)

    otp_entry = OTPRequest(
        mobile_number=phone,
        otp=otp,
        purpose=purpose,
        expires_at=expires_at,
        is_verified=False,
    )
    db.add(otp_entry)
    db.commit()

    logger.info("OTP created for phone=%s purpose=%s", phone, purpose)
    return otp


def verify_otp(db: Session, phone: str, otp: str, purpose: str) -> OTPRequest:
    """
    Verify an OTP against the database.

    Raises HTTPException (400) on invalid / expired OTP.
    Marks the record as verified and commits on success.

    Returns:
        The verified OTPRequest row.
    """
    otp_record = (
        db.query(OTPRequest)
        .filter(
            OTPRequest.mobile_number == phone,   # ← correct column name
            OTPRequest.otp == otp,
            OTPRequest.purpose == purpose,
            OTPRequest.is_verified == False,     # noqa: E712
        )
        .order_by(OTPRequest.created_at.desc())
        .first()
    )

    if not otp_record:
        logger.warning("Invalid OTP attempt for phone=%s purpose=%s", phone, purpose)
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_record.expires_at < datetime.utcnow():
        logger.warning("Expired OTP attempt for phone=%s purpose=%s", phone, purpose)
        raise HTTPException(status_code=400, detail="OTP has expired. Please request a new one.")

    otp_record.is_verified = True
    db.commit()

    logger.info("OTP verified for phone=%s purpose=%s", phone, purpose)
    return otp_record