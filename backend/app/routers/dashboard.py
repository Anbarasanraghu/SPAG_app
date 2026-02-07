from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.security import get_current_user

from app.database import SessionLocal
from app.models.customer import Customer
from app.models.installation import Installation
from app.models.purifier_model import PurifierModel
from app.models.service_history import ServiceHistory
from app.core.service_generator import generate_services
from app.schemas.dashboard import CustomerDashboardResponse, ServiceItem

router = APIRouter(prefix="/dashboard", tags=["Dashboard"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/customer/{customer_id}", response_model=CustomerDashboardResponse)
def customer_dashboard(customer_id: int, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    installation = (
        db.query(Installation)
        .filter(Installation.customer_id == customer_id)
        .first()
    )
    if not installation:
        raise HTTPException(status_code=404, detail="Installation not found")

    purifier_model = (
        db.query(PurifierModel)
        .filter(PurifierModel.id == installation.purifier_model_id)
        .first()
    )

    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.installation_id == installation.id)
        .order_by(ServiceHistory.service_number)
        .all()
    )

    # If no services were generated previously, generate them on-demand
    if not services:
        print(f"No service_history for installation {installation.id}, generating services")
        model = db.query(PurifierModel).filter(PurifierModel.id == installation.purifier_model_id).first()
        if model and model.free_services > 0:
            generate_services(db, installation, model)
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
        customer_id=customer_id,
        purifier_model=purifier_model.name,
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



@router.get("/customer")
def my_dashboard(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    customer = db.query(Customer).filter(
        Customer.user_id == current_user["user_id"]
    ).first()

    # ✅ USER EXISTS BUT NOT YET A CUSTOMER
    if not customer:
        return {
            "installations": [],
            "services": []
        }

    return customer_dashboard(customer.id, db)