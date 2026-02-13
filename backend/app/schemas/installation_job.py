from pydantic import BaseModel

class InstallationJobResponse(BaseModel):
    """Schema for installation jobs returned to technician"""
    
    request_id: int
    customer_name: str
    customer_phone: str
    address: str
    model_name: str
    status: str

    class Config:
        from_attributes = True
