from sqlalchemy import Column, Integer, String, Boolean
from app.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    phone = Column(String, unique=True, index=True)
    email = Column(String)
    password_hash = Column(String)
    role = Column(String, default="customer")  
    profile_completed = Column(Boolean, default=False)
    # customer | technician | admin
