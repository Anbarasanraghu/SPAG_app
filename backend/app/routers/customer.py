from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.user import User
from app.models.customer import Customer
from app.schemas.customer import CustomerCreate, CustomerResponse

router = APIRouter(prefix="/customers", tags=["Customers"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=CustomerResponse)
def create_customer(data: CustomerCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    user = db.query(User).filter(User.phone == data.phone).first()

    if not user:
        user = User(
            name=data.name,
            phone=data.phone,
            role="CUSTOMER"
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    customer = Customer(
        user_id=user.id,
        address=data.address
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)

    return CustomerResponse(
        id=customer.id,
        name=user.name,
        phone=user.phone,
        address=customer.address
    )

@router.get("/{customer_id}")
def get_customer(customer_id: int, db: Session = Depends(get_db)):
    customer = (
        db.query(Customer)
        .join(User, Customer.user_id == User.id)
        .filter(Customer.id == customer_id)
        .first()
    )

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    return {
        "customer_id": customer.id,
        "name": customer.user.name,
        "phone": customer.user.phone,
        "address": customer.address
    }