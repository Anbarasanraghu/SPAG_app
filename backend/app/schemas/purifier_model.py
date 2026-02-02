from pydantic import BaseModel

class PurifierModelCreate(BaseModel):
    name: str
    service_interval_days: int
    free_services: int

class PurifierModelResponse(PurifierModelCreate):
    id: int

    class Config:
        from_attributes = True
