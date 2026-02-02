from sqlalchemy import Column, Integer, Date, ForeignKey, String
from sqlalchemy.orm import relationship
from app.database import Base

class Installation(Base):
    __tablename__ = "installations"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("customers.id"))
    purifier_model_id = Column(Integer, ForeignKey("purifier_models.id"))
    install_date = Column(Date)
    status = Column(String)  # INSTALLED / PENDING

    customer = relationship("Customer")
    purifier_model = relationship("PurifierModel")
