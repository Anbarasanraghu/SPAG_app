from pydantic import BaseModel
from typing import Optional

class PurifierModelCreate(BaseModel):
    name: str
    service_interval_days: int
    free_services: int

class PurifierModelResponse(PurifierModelCreate):
    id: int

    class Config:
        from_attributes = True

class ProductRequestCreate(BaseModel):
    purifier_model_id: int
    mobile_number: Optional[str] = None
    gmail: Optional[str] = None
    password: Optional[str] = None

class ProductRequestResponse(BaseModel):
    """Schema for customer's product request response"""
    id: int
    purifier_model_id: int
    model_name: str
    status: str  # "requested", "assigned", or "completed"
    created_at: Optional[str] = None

    class Config:
        from_attributes = True