from sqlalchemy import Column, Integer, String
from app.database import Base

class PurifierModel(Base):
    __tablename__ = "purifier_models"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    service_interval_days = Column(Integer, nullable=False)
    free_services = Column(Integer, nullable=False)
