from pydantic import BaseModel

class ServiceUpdateRequest(BaseModel):
    service_id: int
    customer_id: int
    status: str  # COMPLETED
