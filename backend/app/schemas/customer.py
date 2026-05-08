from pydantic import BaseModel
from typing import Optional

class CustomerCreate(BaseModel):
    name: str
    phone: str
    address: str

class CustomerResponse(BaseModel):
    id: int
    name: str
    phone: str
    address: str

    class Config:
        from_attributes = True


class AdminCreateCustomerRequest(BaseModel):
    """Schema for admin to create a new customer with full details"""
    # User details
    name: str
    phone: str
    email: Optional[str] = None
    password: str
    
    # Customer profile details
    full_name: str
    mobile_number: str
    address_line1: str
    address_line2: Optional[str] = None
    city: str
    state: str
    pincode: str
    landmark: Optional[str] = None


class AdminCreateCustomerResponse(BaseModel):
    """Response when admin creates a customer"""
    user_id: int
    customer_id: int
    name: str
    phone: str
    email: Optional[str]
    message: str

    class Config:
        from_attributes = True
