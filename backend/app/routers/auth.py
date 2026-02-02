import random
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.models.user import User
from app.core.security import create_access_token

from app.database import get_db
from app.schemas.auth import SendOTP, VerifyOTP
from app.models.otp import OTPRequest

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)

@router.post("/send-otp")
def send_otp(data: SendOTP, db: Session = Depends(get_db)):
    otp = str(random.randint(100000, 999999))
    expires_at = datetime.utcnow() + timedelta(minutes=5)

    otp_entry = OTPRequest(
        mobile_number=data.mobile_number,
        otp=otp,
        expires_at=expires_at
    )

    db.add(otp_entry)
    db.commit()

    # TEMP SMS (replace later)
    print(f"OTP for {data.mobile_number} is {otp}")

    return {"message": "OTP sent successfully"}

@router.post("/verify-otp")
def verify_otp(data: VerifyOTP, db: Session = Depends(get_db)):
    otp_record = db.query(OTPRequest)\
        .filter(
            OTPRequest.mobile_number == data.mobile_number,
            OTPRequest.otp == data.otp,
            OTPRequest.is_verified == False
        )\
        .order_by(OTPRequest.created_at.desc())\
        .first()

    if not otp_record:
        raise HTTPException(status_code=400, detail="Invalid OTP")

    if otp_record.expires_at < datetime.utcnow():
        raise HTTPException(status_code=400, detail="OTP expired")

    otp_record.is_verified = True

    # 🔍 CHECK USER
    user = db.query(User).filter(User.phone == data.mobile_number).first()

    is_new_user = False
    if not user:
        user = User(phone=data.mobile_number)
        db.add(user)
        db.commit()
        db.refresh(user)
        is_new_user = True

    token = create_access_token({
        "user_id": user.id,
        "phone": user.phone,
        "role": user.role
    })

    db.commit()

    return {
        "token": token,
        "role": user.role,
        "is_new_user": is_new_user
    }