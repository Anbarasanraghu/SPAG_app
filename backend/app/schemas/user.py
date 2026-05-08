from pydantic import BaseModel
from typing import Optional


class UserCreate(BaseModel):
    """Schema for creating a new user"""
    name: str
    phone: str
    email: Optional[str] = None
    password: str
    role: str = "customer"  # customer, technician, admin


class UserUpdate(BaseModel):
    """Schema for updating user details"""
    name: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    role: Optional[str] = None


class UserResponse(BaseModel):
    """Schema for user response"""
    id: int
    name: Optional[str]
    phone: str
    email: Optional[str]
    role: str
    profile_completed: bool

    class Config:
        from_attributes = True


class UserDetailResponse(BaseModel):
    """Detailed user response"""
    id: int
    name: Optional[str]
    phone: str
    email: Optional[str]
    role: str
    profile_completed: bool
    message: Optional[str] = None

    class Config:
        from_attributes = True
