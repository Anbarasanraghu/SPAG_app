from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base   

class ProductRequest(Base):
    __tablename__ = "product_requests"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"))
    purifier_model_id = Column(Integer, ForeignKey("purifier_models.id"))
    status = Column(String, default="pending")
    assigned_technician_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    customer = relationship("Customer")
    purifier_model = relationship("PurifierModel")