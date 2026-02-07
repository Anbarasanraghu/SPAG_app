from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session , aliased
from app.models.product_request import ProductRequest
from app.models.installation import Installation
from app.models.purifier_model import PurifierModel
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
    Technician = aliased(User)
    CustomerUser = aliased(User)

    services = (
        db.query(ServiceHistory, Customer, CustomerUser, Technician)
        .join(Customer, ServiceHistory.customer_id == Customer.id)
        .join(CustomerUser, Customer.user_id == CustomerUser.id)
        .outerjoin(Technician, ServiceHistory.technician_id == Technician.id)
        .filter(ServiceHistory.status.in_(["UPCOMING", "ASSIGNED"]))
        .all()
    )

    response = []
    for service, customer, customer_user, technician in services:
        response.append({
            "service_id": service.id,
            "service_date": service.service_date,
            "service_number": service.service_number,
            "status": service.status,
            "customer_name": customer_user.name,
            "technician_id": technician.id if technician else None,
            "technician_name": technician.name if technician else None,
        })

    return response


@router.put("/admin/services/{service_id}/assign")
def assign_technician(
    service_id: int,
    technician_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    service = db.query(ServiceHistory).get(service_id)

    if not service:
        raise HTTPException(status_code=404, detail="Service not found")

    service.technician_id = technician_id
    service.status = "ASSIGNED"
    db.commit()

    return {"message": "Technician assigned"}


@router.get("/admin/customers")
def all_customers(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    UserAlias = aliased(User)

    results = (
        db.query(Customer, UserAlias)
        .join(UserAlias, Customer.user_id == UserAlias.id)
        .all()
    )

    response = []
    for customer, user in results:
        installations_count = (
            db.query(Installation)
            .filter(Installation.customer_id == customer.id)
            .count()
        )

        response.append({
            "customer_id": customer.id,
            "name": user.name,
            "phone": user.phone,
            "address": customer.address,
            "installations": installations_count,
        })

    return response


@router.get("/admin/technician/services")
def technician_logs(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    Technician = aliased(User)
    CustomerUser = aliased(User)

    results = (
        db.query(ServiceHistory, Technician, CustomerUser)
        .join(Customer, ServiceHistory.customer_id == Customer.id)
        .join(CustomerUser, Customer.user_id == CustomerUser.id)
        .outerjoin(Technician, ServiceHistory.technician_id == Technician.id)
        .all()
    )

    logs = []
    for service, technician, customer_user in results:
        logs.append({
            "service_id": service.id,
            "service_date": service.service_date,
            "status": service.status,
            "customer_id": service.customer_id,
            "customer_name": customer_user.name,
            "technician_id": technician.id if technician else None,
            "technician_name": technician.name if technician else None,
        })

    return logs

@router.get("/admin/product-requests")
def get_requests(db: Session = Depends(get_db)):
    return db.query(ProductRequest).all()

@router.put("/admin/product-requests/{id}/assign")
def assign_tech(id: int, technician_id: int, db: Session = Depends(get_db)):
    req = db.query(ProductRequest).get(id)
    req.assigned_technician_id = technician_id
    req.status = "assigned"
    db.commit()
    return {"message": "Assigned"}

@router.put("/admin/services/{service_id}/status")
def update_service_status(
    service_id: int,
    status: str,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    service = db.query(ServiceHistory).get(service_id)

    if not service:
        raise HTTPException(status_code=404, detail="Service not found")

    # 🔒 Enforce valid transitions
    allowed_transitions = {
        "UPCOMING": ["ASSIGNED"],
        "ASSIGNED": ["COMPLETED"],
    }

    current = service.status
    if status not in allowed_transitions.get(current, []):
        raise HTTPException(
            status_code=400,
            detail=f"Cannot change status from {current} to {status}"
        )

    service.status = status
    db.commit()

    return {
        "message": "Status updated",
        "service_id": service.id,
        "status": service.status,
    }


@router.get("/admin/services/{service_id}/details")
def service_details(
    service_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    Technician = aliased(User)
    CustomerUser = aliased(User)

    result = (
        db.query(
            ServiceHistory,
            Customer,
            CustomerUser,
            Installation,
            PurifierModel,
            Technician
        )
        .join(Customer, ServiceHistory.customer_id == Customer.id)
        .join(CustomerUser, Customer.user_id == CustomerUser.id)
        .join(Installation, ServiceHistory.installation_id == Installation.id)
        .join(PurifierModel, Installation.purifier_model_id == PurifierModel.id)
        .outerjoin(Technician, ServiceHistory.technician_id == Technician.id)
        .filter(ServiceHistory.id == service_id)
        .first()
    )

    if not result:
        raise HTTPException(status_code=404, detail="Service not found")

    service, customer, customer_user, installation, model, technician = result

    return {
        "service": {
            "id": service.id,
            "date": service.service_date,
            "number": service.service_number,
            "status": service.status,
        },
        "customer": {
            "id": customer.id,
            "name": customer_user.name,
            "phone": customer_user.phone,
            "address": customer.address,
        },
        "product": {
            "installation_id": installation.id,
            "model_name": model.name,
        },
        "technician": {
            "id": technician.id if technician else None,
            "name": technician.name if technician else None,
            "phone": technician.phone if technician else None,
        }
    }