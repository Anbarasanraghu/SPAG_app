from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base


class Customer(Base):
    __tablename__ = "customers"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
        unique=True,
    )
    
    # Relationship to User
    user = relationship("User", foreign_keys=[user_id])

    # 🔹 Profile details
    full_name = Column(String, nullable=False)
    mobile_number = Column(String, nullable=False)
    email = Column(String, nullable=True)

    address_line1 = Column(String, nullable=False)
    address_line2 = Column(String, nullable=True)
    city = Column(String, nullable=False)
    state = Column(String, nullable=False)
    pincode = Column(String, nullable=False)
    landmark = Column(String, nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
