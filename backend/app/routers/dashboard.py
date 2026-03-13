import logging
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.security import get_current_user
from app.database import SessionLocal
from app.models.customer import Customer
from app.models.user import User
from app.models.installation import Installation
from app.models.purifier_model import PurifierModel
from app.models.service_history import ServiceHistory
from app.schemas.dashboard import CustomerDashboardResponse, ServiceItem

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])
logger = logging.getLogger(__name__)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# 🔹 PUBLIC ENDPOINT (By Customer ID)
@router.get("/customer/{customer_id}", response_model=CustomerDashboardResponse)
def get_customer_dashboard_by_id(
    customer_id: int,
    db: Session = Depends(get_db)
):
    customer = db.query(Customer).filter(
        Customer.id == customer_id
    ).first()

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    installation = db.query(Installation).filter(
        Installation.customer_id == customer_id
    ).first()

    if not installation:
        raise HTTPException(status_code=404, detail="Installation not found")

    purifier_model = db.query(PurifierModel).filter(
        PurifierModel.id == installation.purifier_model_id
    ).first()

    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.installation_id == installation.id)
        .order_by(ServiceHistory.service_number)
        .all()
    )

    next_service = next(
        (s.service_date for s in services if s.status == "UPCOMING"),
        None
    )

    return CustomerDashboardResponse(
        customer_id=customer.id,
        purifier_model=purifier_model.name if purifier_model else "Unknown",
        install_date=installation.install_date,
        next_service_date=next_service,
        services=[
            ServiceItem(
                service_number=s.service_number,
                service_date=s.service_date,
                status=s.status
            )
            for s in services
        ]
    )


# 🔹 AUTHENTICATED CUSTOMER DASHBOARD
@router.get("/customer")
def get_customer_dashboard(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    # Extract user id safely from JWT dict
    user_id = (
        user.get("id")
        or user.get("user_id")
        or user.get("sub")
    )
    print(f"DEBUG: user_id extracted: {user_id}")
    logger.info(f"DEBUG: user_id extracted: {user_id}")

    auth_user = db.query(User).filter(User.id == user_id).first()
    if not auth_user:
        raise HTTPException(status_code=404, detail="User not found")
    print(f"DEBUG: auth_user found: {auth_user.id}")
    logger.info(f"DEBUG: auth_user found: {auth_user.id}")

    if not getattr(auth_user, "profile_completed", False):
        return {"profile_completed": False, "message": "Installation pending"}

    # profile completed -> return full dashboard
    customer = db.query(Customer).filter(
        Customer.user_id == user_id
    ).first()
    print(f"DEBUG: customer query - user_id: {user_id}, customer found: {customer.id if customer else None}")
    logger.info(f"DEBUG: customer query - user_id: {user_id}, customer found: {customer.id if customer else None}")

    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    print(f"DEBUG: looking for installation with customer_id: {customer.id}")
    logger.info(f"DEBUG: looking for installation with customer_id: {customer.id}")
    installation = db.query(Installation).filter(
        Installation.customer_id == customer.id
    ).first()
    print(f"DEBUG: installation query result: {installation}")
    logger.info(f"DEBUG: installation query result: {installation}")
    if installation:
        print(f"DEBUG: installation found - id: {installation.id}, customer_id: {installation.customer_id}")
        logger.info(f"DEBUG: installation found - id: {installation.id}, customer_id: {installation.customer_id}")

    if not installation:
        raise HTTPException(status_code=404, detail="Installation not found")

    purifier_model = db.query(PurifierModel).filter(
        PurifierModel.id == installation.purifier_model_id
    ).first()

    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.installation_id == installation.id)
        .order_by(ServiceHistory.service_number)
        .all()
    )

    next_service = next(
        (s.service_date for s in services if s.status == "UPCOMING"),
        None
    )

    return CustomerDashboardResponse(
        customer_id=customer.id,
        purifier_model=purifier_model.name if purifier_model else "Unknown",
        install_date=installation.install_date,
        next_service_date=next_service,
        services=[
            ServiceItem(
                service_number=s.service_number,
                service_date=s.service_date,
                status=s.status
            )
            for s in services
        ]
    )
