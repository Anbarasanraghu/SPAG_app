from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.auth_utils import extract_user_id
from app.database import SessionLocal, get_db
from app.models.service_history import ServiceHistory
from app.schemas.service_history import ServiceHistoryResponse
from app.schemas.service_update import ServiceUpdateRequest
from app.core.security import get_current_user 
from app.models.service_status_log import ServiceStatusLog
from sqlalchemy import inspect
from app.models.technician_activity_log import TechnicianActivityLog


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
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
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

    old_status = service.status
    service.status = data.status

    # 🔹 Create a status log entry — only include `changed_by_role` if the column exists in DB
    changed_by_val = user.get("id") or user.get("user_id") or user.get("sub")
    include_role = False
    try:
        inspector = inspect(db.bind)
        cols = [c["name"] for c in inspector.get_columns("service_status_logs")]
        include_role = "changed_by_role" in cols
    except Exception:
        # If inspection fails, default to not including the role to avoid insert errors
        include_role = False

    if include_role:
        status_log = ServiceStatusLog(
            service_id=service.id,
            old_status=old_status,
            new_status=data.status,
            changed_by=changed_by_val,
            changed_by_role=user.get("role"),
        )
    else:
        status_log = ServiceStatusLog(
            service_id=service.id,
            old_status=old_status,
            new_status=data.status,
            changed_by=changed_by_val,
        )

    db.add(status_log)

    # 🔹 If there's a technician assigned, log technician activity as well
    if service.technician_id:
        tech_log = TechnicianActivityLog(
            technician_id=service.technician_id,
            service_id=service.id,
            action=data.status,
        )
        db.add(tech_log)

    db.commit()
    db.refresh(service)

    return {
        "message": "Service updated successfully",
        "service_id": service.id,
        "customer_id": service.customer_id,
        "status": service.status
    }

@router.get("/upcoming")
def get_upcoming_services(
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    technician_id = extract_user_id(user)

    return db.query(ServiceHistory).filter(
        ServiceHistory.technician_id == technician_id,
        ServiceHistory.status.in_(["ASSIGNED", "IN_PROGRESS"])
    ).all()