from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session , aliased
from app.models.product_request import ProductRequest
from app.models.installation import Installation
from app.models.purifier_model import PurifierModel
from app.models.customer import Customer
from app.models.service_status_log import ServiceStatusLog
from app.models.technician_activity_log import TechnicianActivityLog
from app.core.security import require_admin , require_technician 
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
    user=Depends(require_admin),
):
    service = db.query(ServiceHistory).filter(
        ServiceHistory.id == service_id
    ).first()

    if not service:
        raise HTTPException(404, "Service not found")

    old_status = service.status

    service.technician_id = technician_id
    service.status = "ASSIGNED"

    # 🔹 Status log
    status_log = ServiceStatusLog(
        service_id=service.id,
        old_status=old_status,
        new_status="ASSIGNED",
        changed_by=user['user_id'],
    )

    # 🔹 Technician activity
    tech_log = TechnicianActivityLog(
        technician_id=technician_id,
        service_id=service.id,
        action="ASSIGNED",
    )

    db.add(status_log)
    db.add(tech_log)
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
            "customer": {
                "address": {
                    "line1": customer.address_line1,
                    "line2": customer.address_line2,
                    "city": customer.city,
                    "state": customer.state,
                    "pincode": customer.pincode,
                    "landmark": customer.landmark,
                },},
            "installations": installations_count,
        })

    return response


@router.get("/technician/services")
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

# 🔹 NEW ENDPOINT: Service Status Logs
@router.get("/services/{service_id}/status-logs")
def get_service_status_logs(
    service_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get all status changes for a service"""
    logs = db.query(ServiceStatusLog).filter(
        ServiceStatusLog.service_id == service_id
    ).order_by(ServiceStatusLog.id).all()
    
    return [{
        "id": log.id,
        "service_id": log.service_id,
        "old_status": log.old_status,
        "new_status": log.new_status,
        "changed_at": log.changed_at,
        "changed_by": log.changed_by,
        # "changed_by_role": log.changed_by_role,
    } for log in logs]


# Optional endpoint: accept no ID (or a query param) so UI doesn't have to prompt for a specific service id
@router.get("/services/status-logs")
def get_service_status_logs_optional(
    service_id: int | None = None,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get service status logs. If `service_id` query param is provided, filter by it; otherwise return all logs."""
    query = db.query(ServiceStatusLog).order_by(ServiceStatusLog.id.desc())
    if service_id is not None:
        query = query.filter(ServiceStatusLog.service_id == service_id)

    logs = query.all()
    return [{
        "id": log.id,
        "service_id": log.service_id,
        "old_status": log.old_status,
        "new_status": log.new_status,
        "changed_at": log.changed_at,
        "changed_by": log.changed_by,
        # "changed_by_role": log.changed_by_role,
    } for log in logs]


@router.get("/admin/services/status-logs")
def get_all_service_status_logs(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get all service status logs"""
    logs = db.query(ServiceStatusLog).order_by(ServiceStatusLog.id.desc()).all()
    return [{
        "id": log.id,
        "service_id": log.service_id,
        "old_status": log.old_status,
        "new_status": log.new_status,
        "changed_at": log.changed_at,
        "changed_by": log.changed_by,
        # "changed_by_role": log.changed_by_role,
    } for log in logs]


# 🔹 NEW ENDPOINT: Technician Activity Logs
@router.get("/technicians/{technician_id}/activity-logs")
def get_technician_activity_logs(
    technician_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get all activities for a technician"""
    logs = db.query(TechnicianActivityLog).filter(
        TechnicianActivityLog.technician_id == technician_id
    ).order_by(TechnicianActivityLog.id.desc()).all()
    
    return [{
        "id": log.id,
        "technician_id": log.technician_id,
        "service_id": log.service_id,
        "action": log.action,
        "created_at": log.created_at,
    } for log in logs]


@router.get("/admin/technicians/activity-logs")
def get_all_technician_activity_logs(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get all technician activity logs"""
    logs = db.query(TechnicianActivityLog).order_by(TechnicianActivityLog.id.desc()).all()
    return [{
        "id": log.id,
        "technician_id": log.technician_id,
        "service_id": log.service_id,
        "action": log.action,
        "created_at": log.created_at,
    } for log in logs]

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

@router.put("/technician/services/{service_id}/status")
def update_service_status(
    service_id: int,
    status: str,  # IN_PROGRESS / COMPLETED
    db: Session = Depends(get_db),
    user=Depends(require_technician),
):
    service = db.query(ServiceHistory).filter(
        ServiceHistory.id == service_id,
        ServiceHistory.technician_id == user.id,
    ).first()

    if not service:
        raise HTTPException(404, "Service not found")

    old_status = service.status
    service.status = status

    # 🔹 Status log
    db.add(ServiceStatusLog(
        service_id=service.id,
        old_status=old_status,
        new_status=status,
        changed_by=user.id,
        changed_by_role="technician",
    ))

    # 🔹 Technician activity
    db.add(TechnicianActivityLog(
        technician_id=user.id,
        service_id=service.id,
        action=status,
    ))

    db.commit()

    return {"message": "Service updated"}


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
                "address": {
                    "line1": customer.address_line1,
                    "line2": customer.address_line2,
                    "city": customer.city,
                    "state": customer.state,
                    "pincode": customer.pincode,
                    "landmark": customer.landmark,
                },
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

@router.get("/technician/services")
def technician_services(
    db: Session = Depends(get_db),
    user=Depends(require_technician),
):
    return db.query(ServiceHistory).filter(
        ServiceHistory.technician_id == user.id,
        ServiceHistory.status.in_(["ASSIGNED", "IN_PROGRESS"])
    ).all()