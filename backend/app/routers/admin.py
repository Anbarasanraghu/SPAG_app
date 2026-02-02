from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.models.customer import Customer
from app.core.security import require_admin
from app.database import SessionLocal, get_db
from app.models.user import User
from app.models.service_history import ServiceHistory

router = APIRouter(tags=["Admin"])

@router.get("/admin/users")
def get_all_users(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    return db.query(User).all()


@router.put("/admin/users/{user_id}/role")
def update_role(
    user_id: int,
    role: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    user = db.query(User).get(user_id)
    user.role = role
    db.commit()
    return {"message": "Role updated"}


@router.get("/admin/services/pending")
def pending_services(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    return db.query(ServiceHistory).filter(
        ServiceHistory.status == "UPCOMING"
    ).all()

@router.put("/admin/services/{service_id}/assign")
def assign_technician(
    service_id: int,
    technician_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    service = db.query(ServiceHistory).get(service_id)
    service.technician_id = technician_id
    service.status = "ASSIGNED"
    db.commit()

    return {"message": "Technician assigned"}


@router.get("/admin/customers")
def all_customers(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    return db.query(Customer).all()


@router.get("/admin/technician/services")
def technician_logs(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    return (
        db.query(ServiceHistory, User)
        .join(User, ServiceHistory.technician_id == User.id)
        .all()
    )