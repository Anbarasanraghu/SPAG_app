from sqlalchemy import Column, Integer, String, Float, Text
from app.database import Base

class PurifierModel(Base):
    __tablename__ = "purifier_models"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    service_interval_days = Column(Integer, nullable=False)
    free_services = Column(Integer, nullable=False)
    colours = Column(String, nullable=True)  # Comma-separated colours
    price = Column(Float, nullable=True)
    features = Column(Text, nullable=True)  # JSON string or comma-separated
    image_url = Column(String, nullable=True)
    category = Column(String, nullable=True)
    capacity = Column(String, nullable=True)  # e.g., "10L"
    descriptions = Column(Text, nullable=True)
