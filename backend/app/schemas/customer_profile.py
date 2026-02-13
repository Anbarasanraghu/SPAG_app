from pydantic import BaseModel
from typing import Optional

class CustomerProfileCreate(BaseModel):
    full_name: str
    mobile_number: str
    email: Optional[str] = None
    address_line1: str
    address_line2: Optional[str] = None
    city: str
    state: str
    pincode: str
    landmark: Optional[str] = None
