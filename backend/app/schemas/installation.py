from pydantic import BaseModel
from datetime import date

class InstallationCreate(BaseModel):
    customer_id: int
    purifier_model_id: int
    install_date: date

class InstallationResponse(BaseModel):
    id: int
    customer_id: int
    purifier_model_id: int
    install_date: date
    status: str

    class Config:
        from_attributes = True
