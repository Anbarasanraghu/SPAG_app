from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.customer_profile import CustomerProfileCreate
from app.models.customer import Customer
from app.core.security import get_current_user

router = APIRouter(prefix="/customer/profile", tags=["Customer Profile"])

@router.get("/exists")
def profile_exists(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    user_id = (
        user.get("id")
        or user.get("user_id")
        or user.get("sub")
    )

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user token")

    customer = db.query(Customer).filter(
        Customer.user_id == user_id
    ).first()

    return {"exists": customer is not None}

@router.post("")
def create_profile(
    data: CustomerProfileCreate,
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    user_id = (
        user.get("id")
        or user.get("user_id")
        or user.get("sub")
    )

    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid user token")

    existing = db.query(Customer).filter(
        Customer.user_id == user_id
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Profile already exists",
        )

    customer = Customer(
        user_id=user_id,
        full_name=data.full_name,
        mobile_number=data.mobile_number,
        email=data.email,
        address_line1=data.address_line1,
        address_line2=data.address_line2,
        city=data.city,
        state=data.state,
        pincode=data.pincode,
        landmark=data.landmark,
    )

    db.add(customer)
    db.commit()
    db.refresh(customer)

    return {"message": "Profile created successfully"}
