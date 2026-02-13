from sqlalchemy import Column, Integer, String, Boolean, DateTime
from datetime import datetime
from app.database import Base

class OTPRequest(Base):
    __tablename__ = "otp_requests"

    id = Column(Integer, primary_key=True, index=True)
    mobile_number = Column(String(15), index=True)
    otp = Column(String(6))
    purpose = Column(String)  # "reset_password"
    is_verified = Column(Boolean, default=False)
    expires_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
