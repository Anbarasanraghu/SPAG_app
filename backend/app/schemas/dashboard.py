from pydantic import BaseModel
from datetime import date
from typing import List, Optional

class ServiceItem(BaseModel):
    service_number: int
    service_date: date
    status: str

class CustomerDashboardResponse(BaseModel):
    customer_id: int
    purifier_model: str
    install_date: date
    next_service_date: Optional[date]
    services: List[ServiceItem]

    class Config:
        from_attributes = True
