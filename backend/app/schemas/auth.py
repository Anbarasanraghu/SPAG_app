from pydantic import BaseModel
from typing import Dict, Any

class SendOTP(BaseModel):
    mobile_number: str

class VerifyOTP(BaseModel):
    mobile_number: str
    otp: str

class SendOTPRequest(BaseModel):
    customer_id: str  # Changed from phone to customer_id

class SendOTPResponse(BaseModel):
    success: bool
    message: str
    msg91_response: Dict[str, Any] = None

class VerifyOTPRequest(BaseModel):
    customer_id: str  # Changed from phone to customer_id
    otp: str

class VerifyOTPResponse(BaseModel):
    success: bool
    message: str
