from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.database import Base
from datetime import datetime


class ProductRequest(Base):
    __tablename__ = "product_requests"

    id = Column(Integer, primary_key=True, index=True)
    # user_id references the auth user who made the request
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    # customer_id will be created later by technician on installation completion
    customer_id = Column(Integer, ForeignKey("customers.id"), nullable=True)
    purifier_model_id = Column(Integer, ForeignKey("purifier_models.id"))
    status = Column(String, default="requested")
    assigned_technician_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", foreign_keys=[user_id])
    customer = relationship("Customer", foreign_keys=[customer_id])
    purifier_model = relationship("PurifierModel")