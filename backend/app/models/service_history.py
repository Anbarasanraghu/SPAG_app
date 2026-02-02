from sqlalchemy import Column, Integer, Date, ForeignKey, String
from app.database import Base

class ServiceHistory(Base):
    __tablename__ = "service_history"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"))
    installation_id = Column(Integer, ForeignKey("installations.id"))
    service_date = Column(Date)
    service_number = Column(Integer)
    technician_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    status = Column(String)  # UPCOMING / COMPLETED
