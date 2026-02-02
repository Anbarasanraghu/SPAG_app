from pydantic import BaseModel
from datetime import date

class ServiceHistoryResponse(BaseModel):
    id: int
    customer_id: int
    installation_id: int
    service_number: int
    service_date: date
    status: str

    class Config:
        from_attributes = True
