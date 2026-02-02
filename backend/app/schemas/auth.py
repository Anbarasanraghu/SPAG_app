from pydantic import BaseModel

class SendOTP(BaseModel):
    mobile_number: str

class VerifyOTP(BaseModel):
    mobile_number: str
    otp: str
