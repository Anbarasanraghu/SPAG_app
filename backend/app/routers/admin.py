from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session , aliased
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from app.models.product_request import ProductRequest
from app.models.installation import Installation
from app.models.purifier_model import PurifierModel
from app.models.customer import Customer
from app.models.service_status_log import ServiceStatusLog
from app.models.technician_activity_log import TechnicianActivityLog
from app.core.security import require_admin , require_technician, hash_password
from app.database import SessionLocal, get_db
from app.models.user import User
from app.models.service_history import ServiceHistory
from app.schemas.customer import AdminCreateCustomerRequest, AdminCreateCustomerResponse
from app.schemas.user import UserCreate, UserUpdate, UserResponse, UserDetailResponse

router = APIRouter(tags=["Admin"])

@router.get("/admin/users")
def get_all_users(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    return db.query(User).all()


@router.post("/admin/users", response_model=UserDetailResponse)
def create_user(
    data: UserCreate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Create a new user"""
    # Check if phone already exists
    existing_user = db.query(User).filter(User.phone == data.phone).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Phone number is already registered")
    
    try:
        user = User(
            name=data.name,
            phone=data.phone,
            email=data.email,
            password_hash=hash_password(data.password),
            role=data.role,
            profile_completed=False,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        
        return UserDetailResponse(
            id=user.id,
            name=user.name,
            phone=user.phone,
            email=user.email,
            role=user.role,
            profile_completed=user.profile_completed,
            message=f"User created successfully with ID {user.id}"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating user: {str(e)}")


@router.get("/admin/users/{user_id}", response_model=UserDetailResponse)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get a specific user by ID"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserDetailResponse(
        id=user.id,
        name=user.name,
        phone=user.phone,
        email=user.email,
        role=user.role,
        profile_completed=user.profile_completed,
    )


@router.put("/admin/users/{user_id}", response_model=UserDetailResponse)
def update_user(
    user_id: int,
    data: UserUpdate,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Update user details"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    try:
        # Update fields if provided
        if data.name is not None:
            user.name = data.name
        if data.email is not None:
            user.email = data.email
        if data.role is not None:
            user.role = data.role
        if data.phone is not None:
            # Check if new phone is already taken by another user
            existing = db.query(User).filter(
                User.phone == data.phone,
                User.id != user_id
            ).first()
            if existing:
                raise HTTPException(status_code=400, detail="Phone number is already registered")
            user.phone = data.phone
        
        db.commit()
        db.refresh(user)
        
        return UserDetailResponse(
            id=user.id,
            name=user.name,
            phone=user.phone,
            email=user.email,
            role=user.role,
            profile_completed=user.profile_completed,
            message=f"User {user_id} updated successfully"
        )
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating user: {str(e)}")


@router.delete("/admin/users/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Delete a user"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    try:
        # Check if user is linked to customer profile
        customer = db.query(Customer).filter(Customer.user_id == user_id).first()
        if customer:
            # Delete customer profile first
            db.delete(customer)
        
        # Delete user
        db.delete(user)
        db.commit()
        
        return {
            "message": f"User {user_id} and associated data deleted successfully",
            "deleted_user_id": user_id
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting user: {str(e)}")


@router.post("/admin/users/create-customer", response_model=AdminCreateCustomerResponse)
def create_customer_by_admin(
    data: AdminCreateCustomerRequest,
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Admin endpoint to create a new customer with full profile details"""
    # Check if phone already exists
    existing_user = db.query(User).filter(User.phone == data.phone).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Phone number is already registered")
    
    try:
        # 1. Create User
        user = User(
            name=data.name,
            phone=data.phone,
            email=data.email,
            password_hash=hash_password(data.password),
            role="customer",
            profile_completed=True,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        
        # 2. Create Customer Profile
        customer = Customer(
            user_id=user.id,
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
        
        return AdminCreateCustomerResponse(
            user_id=user.id,
            customer_id=customer.id,
            name=user.name,
            phone=user.phone,
            email=user.email,
            message=f"Customer {user.name} created successfully with ID {customer.id}"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating customer: {str(e)}")


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
    """Get all activities for a specific technician"""
    TechnicianUser = aliased(User)
    CustomerUser = aliased(User)
    
    logs = (
        db.query(
            TechnicianActivityLog, 
            TechnicianUser, 
            ServiceHistory, 
            Customer, 
            CustomerUser,
            Installation,
            PurifierModel
        )
        .join(TechnicianUser, TechnicianActivityLog.technician_id == TechnicianUser.id)
        .join(ServiceHistory, TechnicianActivityLog.service_id == ServiceHistory.id, isouter=True)
        .join(Customer, ServiceHistory.customer_id == Customer.id, isouter=True)
        .join(CustomerUser, Customer.user_id == CustomerUser.id, isouter=True)
        .join(Installation, ServiceHistory.installation_id == Installation.id, isouter=True)
        .join(PurifierModel, Installation.purifier_model_id == PurifierModel.id, isouter=True)
        .filter(TechnicianActivityLog.technician_id == technician_id)
        .order_by(TechnicianActivityLog.id.desc())
        .all()
    )
    
    response = []
    for log, technician, service, customer, customer_user, installation, purifier_model in logs:
        response.append({
            "id": log.id,
            "action": log.action,
            "created_at": str(log.created_at) if log.created_at else None,
            # Technician details
            "technician": {
                "id": technician.id,
                "name": technician.name,
                "phone": technician.phone,
                "role": technician.role,
            },
            # Service details
            "service": {
                "id": service.id if service else None,
                "service_number": service.service_number if service else None,
                "service_date": str(service.service_date) if service and service.service_date else None,
                "status": service.status if service else None,
            } if service else None,
            # Customer details
            "customer": {
                "id": customer.id if customer else None,
                "name": customer_user.name if customer_user else None,
                "phone": customer_user.phone if customer_user else None,
                "address_line1": customer.address_line1 if customer else None,
                "address_line2": customer.address_line2 if customer else None,
                "city": customer.city if customer else None,
                "state": customer.state if customer else None,
                "pincode": customer.pincode if customer else None,
            } if customer else None,
            # Purifier model details
            "purifier_model": {
                "id": purifier_model.id if purifier_model else None,
                "name": purifier_model.name if purifier_model else None,
                "capacity": purifier_model.capacity if purifier_model else None,
                "category": purifier_model.category if purifier_model else None,
                "price": purifier_model.price if purifier_model else None,
                "features": purifier_model.features if purifier_model else None,
                "service_interval_days": purifier_model.service_interval_days if purifier_model else None,
                "free_services": purifier_model.free_services if purifier_model else None,
            } if purifier_model else None,
        })
    
    return response


@router.get("/admin/technicians/activity-logs")
def get_all_technician_activity_logs(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    """Get all technician activity logs with full details"""
    TechnicianUser = aliased(User)
    CustomerUser = aliased(User)
    
    logs = (
        db.query(
            TechnicianActivityLog, 
            TechnicianUser, 
            ServiceHistory, 
            Customer, 
            CustomerUser,
            Installation,
            PurifierModel
        )
        .join(TechnicianUser, TechnicianActivityLog.technician_id == TechnicianUser.id)
        .join(ServiceHistory, TechnicianActivityLog.service_id == ServiceHistory.id, isouter=True)
        .join(Customer, ServiceHistory.customer_id == Customer.id, isouter=True)
        .join(CustomerUser, Customer.user_id == CustomerUser.id, isouter=True)
        .join(Installation, ServiceHistory.installation_id == Installation.id, isouter=True)
        .join(PurifierModel, Installation.purifier_model_id == PurifierModel.id, isouter=True)
        .order_by(TechnicianActivityLog.id.desc())
        .all()
    )
    
    response = []
    for log, technician, service, customer, customer_user, installation, purifier_model in logs:
        response.append({
            "id": log.id,
            "action": log.action,
            "created_at": str(log.created_at) if log.created_at else None,
            # Technician details
            "technician": {
                "id": technician.id,
                "name": technician.name,
                "phone": technician.phone,
                "role": technician.role,
            },
            # Service details
            "service": {
                "id": service.id if service else None,
                "service_number": service.service_number if service else None,
                "service_date": str(service.service_date) if service and service.service_date else None,
                "status": service.status if service else None,
            } if service else None,
            # Customer details
            "customer": {
                "id": customer.id if customer else None,
                "name": customer_user.name if customer_user else None,
                "phone": customer_user.phone if customer_user else None,
                "address_line1": customer.address_line1 if customer else None,
                "address_line2": customer.address_line2 if customer else None,
                "city": customer.city if customer else None,
                "state": customer.state if customer else None,
                "pincode": customer.pincode if customer else None,
            } if customer else None,
            # Purifier model details
            "purifier_model": {
                "id": purifier_model.id if purifier_model else None,
                "name": purifier_model.name if purifier_model else None,
                "capacity": purifier_model.capacity if purifier_model else None,
                "category": purifier_model.category if purifier_model else None,
                "price": purifier_model.price if purifier_model else None,
                "features": purifier_model.features if purifier_model else None,
                "service_interval_days": purifier_model.service_interval_days if purifier_model else None,
                "free_services": purifier_model.free_services if purifier_model else None,
            } if purifier_model else None,
        })
    
    return response

@router.get("/admin/product-requests")
def get_requests(db: Session = Depends(get_db)):
    """Return all product requests with full customer information"""
    try:
        # Use aliased to distinguish between Customer user and Requester user
        RequesterUser = aliased(User)
        CustomerUser = aliased(User)
        
        # Join ProductRequest with Customer and User tables to get customer details
        results = (
            db.query(ProductRequest, Customer, RequesterUser, CustomerUser)
            .join(Customer, ProductRequest.customer_id == Customer.id, isouter=True)
            .join(CustomerUser, Customer.user_id == CustomerUser.id, isouter=True)
            .join(RequesterUser, ProductRequest.user_id == RequesterUser.id, isouter=True)
            .all()
        )
        
        response = []
        for product_req, customer, requester_user, customer_user in results:
            # If customer exists, use customer details; otherwise use requester details
            if customer and customer_user:
                customer_info = {
                    "id": customer.id,
                    "name": customer_user.name,
                    "phone": customer_user.phone,
                    "address_line1": customer.address_line1,
                    "address_line2": customer.address_line2,
                    "city": customer.city,
                    "state": customer.state,
                    "pincode": customer.pincode,
                }
            elif requester_user:
                customer_info = {
                    "id": None,
                    "name": requester_user.name,
                    "phone": requester_user.phone,
                    "address_line1": None,
                    "address_line2": None,
                    "city": None,
                    "state": None,
                    "pincode": None,
                }
            else:
                customer_info = None
                
            response.append({
                "id": product_req.id,
                "customer_id": product_req.customer_id,
                "user_id": product_req.user_id,
                "purifier_model_id": product_req.purifier_model_id,
                "status": product_req.status,
                "assigned_technician_id": product_req.assigned_technician_id,
                "created_at": str(product_req.created_at) if product_req.created_at else None,
                "customer": customer_info,
            })
        
        return response
    except Exception as e:
        print(f"DEBUG: Error fetching product requests: {str(e)}")
        # Fallback: return minimal data if query fails
        try:
            requests = db.query(ProductRequest).all()
            return [{
                "id": r.id,
                "customer_id": r.customer_id,
                "user_id": r.user_id,
                "purifier_model_id": r.purifier_model_id,
                "status": r.status,
                "assigned_technician_id": r.assigned_technician_id,
                "created_at": str(r.created_at) if r.created_at else None,
                "customer": None,
            } for r in requests]
        except Exception as fallback_error:
            raise HTTPException(status_code=500, detail=f"Failed to fetch product requests: {str(fallback_error)}")


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


@router.get("/admin/dashboard")
def get_admin_dashboard_stats(
    db: Session = Depends(get_db),
    admin=Depends(require_admin)
):
    # Debug: Check what status values exist
    all_statuses = db.query(ServiceHistory.status).distinct().all()
    print(f"DEBUG: All service statuses in database: {[s[0] for s in all_statuses]}")

    # Debug: Check what role values exist
    all_roles = db.query(User.role).distinct().all()
    print(f"DEBUG: All user roles in database: {[r[0] for r in all_roles]}")

    # Total users count
    total_users = db.query(User).count()

    # Pending services count - let's be more inclusive
    # Include any status that isn't "COMPLETED"
    pending_services = db.query(ServiceHistory).filter(
        ServiceHistory.status != "COMPLETED",
        ServiceHistory.status.isnot(None)
    ).count()

    print(f"DEBUG: Pending services query result: {pending_services}")

    # Product requests count
    product_requests = db.query(ProductRequest).count()

    # Active now (users who logged in recently - let's say within last 24 hours)
    # For now, we'll use a simple count of all users as active
    active_now = total_users  # TODO: Implement proper active user tracking

    # Technicians count - debug this
    technicians = db.query(User).filter(User.role == "technician").count()
    print(f"DEBUG: Technicians count (role='technician'): {technicians}")

    # Also check for other possible role names
    technicians_alt = db.query(User).filter(User.role.ilike("%tech%")).count()
    print(f"DEBUG: Technicians count (role containing 'tech'): {technicians_alt}")

    # Resolved percentage (completed services / total services)
    total_services = db.query(ServiceHistory).count()
    resolved_services = db.query(ServiceHistory).filter(
        ServiceHistory.status == "COMPLETED"
    ).count()
    resolved_percentage = (resolved_services / total_services * 100) if total_services > 0 else 0.0

    # User growth data (last 7 days - simplified)
    # For now, return some sample growth data
    user_growth_data = [1200, 1150, 1180, 1220, 1250, 1270, total_users]

    return {
        "total_users": total_users,
        "pending_services": pending_services,
        "product_requests": product_requests,
        "active_now": active_now,
        "technicians": technicians,
        "resolved_percentage": resolved_percentage,
        "user_growth_data": user_growth_data
    }