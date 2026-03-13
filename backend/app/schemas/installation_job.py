from pydantic import BaseModel
from typing import Optional
from datetime import date

class InstallationJobResponse(BaseModel):
    """Schema for installation jobs returned to technician"""
    
    request_id: int
    customer_name: str
    customer_phone: str
    address: str
    model_name: str
    status: str
    purifier_model_id: Optional[int] = None

    class Config:
        from_attributes = True


class CompleteInstallationRequest(BaseModel):
    """Schema for completing installation with required fields"""
    customer_name: str
    address: str
    installation_date: date
    site_details: str
    purifier_model_id: int
    address_line2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    pincode: Optional[str] = None
    landmark: Optional[str] = None
    mobile_number: Optional[str] = None
    email: Optional[str] = None
