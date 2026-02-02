from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.service_history import ServiceHistory
from app.schemas.service_history import ServiceHistoryResponse
from app.schemas.service_update import ServiceUpdateRequest 


router = APIRouter(prefix="/services", tags=["Service History"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/customer/{customer_id}", response_model=list[ServiceHistoryResponse])
def get_services_by_customer(customer_id: int, db: Session = Depends(get_db)):
    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.customer_id == customer_id)
        .order_by(ServiceHistory.service_number)
        .all()
    )

    if not services:
        raise HTTPException(status_code=404, detail="No services found")

    return services


@router.get("/installation/{installation_id}", response_model=list[ServiceHistoryResponse])
def get_services_by_installation(installation_id: int, db: Session = Depends(get_db)):
    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.installation_id == installation_id)
        .order_by(ServiceHistory.service_number)
        .all()
    )

    if not services:
        raise HTTPException(status_code=404, detail="No services found")

    return services


@router.put("/update")
def update_service_status(
    data: ServiceUpdateRequest,
    db: Session = Depends(get_db)
):
    service = (
        db.query(ServiceHistory)
        .filter(
            ServiceHistory.id == data.service_id,
            ServiceHistory.customer_id == data.customer_id
        )
        .first()
    )

    if not service:
        raise HTTPException(
            status_code=404,
            detail="Service not found for this customer"
        )

    service.status = data.status
    db.commit()
    db.refresh(service)

    return {
        "message": "Service updated successfully",
        "service_id": service.id,
        "customer_id": service.customer_id,
        "status": service.status
    }

@router.get("/upcoming")
def get_upcoming_services(db: Session = Depends(get_db)):
    services = (
        db.query(ServiceHistory)
        .filter(ServiceHistory.status == "UPCOMING")
        .order_by(ServiceHistory.service_date)
        .all()
    )

    return [
        {
            "service_id": s.id,
            "customer_id": s.customer_id,
            "installation_id": s.installation_id,
            "service_number": s.service_number,
            "service_date": s.service_date
        }
        for s in services
    ]