import logging
from fastapi import APIRouter, Depends ,HTTPException, Body
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.product_request import ProductRequest 
from app.models.installation import Installation
from app.models.technician_activity_log import TechnicianActivityLog
from app.models.customer import Customer
from app.models.purifier_model import PurifierModel
from app.models.user import User
from app.schemas.installation_job import InstallationJobResponse, CompleteInstallationRequest

from app.core.service_generator import generate_services
from app.core.security import get_current_user
from app.core.auth_utils import extract_user_id
router = APIRouter(
    prefix="/technician",
    tags=["technician"]
)

@router.get("/installations", response_model=list[InstallationJobResponse])
def technician_installations(
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    technician_id = extract_user_id(user)

    # Show requests assigned to this technician OR unassigned requested products
    from sqlalchemy import and_, or_
    requests = db.query(ProductRequest).filter(
        or_(
            and_(ProductRequest.assigned_technician_id == technician_id, ProductRequest.status.in_(["requested", "assigned"])),
            and_(ProductRequest.assigned_technician_id == None, ProductRequest.status == "requested")
        )
    ).all()

    # Transform to response schema with customer and model details
    result = []
    for req in requests:
        customer = db.query(Customer).filter(Customer.id == req.customer_id).first()
        user = None
        if not customer and req.user_id:
            user = db.query(User).filter(User.id == req.user_id).first()
        model = db.query(PurifierModel).filter(PurifierModel.id == req.purifier_model_id).first()

        # build response using customer profile if exists, otherwise use auth user info
        if model:
            customer_name = customer.full_name if customer else (user.name if user else "")
            customer_phone = customer.mobile_number if customer else (user.phone if user else "")
            address = ""
            if customer:
                address = f"{customer.address_line1}, {customer.city}, {customer.state}"
            job_response = InstallationJobResponse(
                request_id=req.id,
                customer_name=customer_name or "",
                customer_phone=customer_phone or "",
                address=address,
                model_name=model.name,
                purifier_model_id=model.id,
                status=req.status
            )
            result.append(job_response)
    
    return result



@router.put("/installations/{request_id}/complete")
def complete_installation(
    request_id: int,
    payload: CompleteInstallationRequest = Body(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    technician_id = extract_user_id(user)

    request = db.query(ProductRequest).filter(
        ProductRequest.id == request_id,
        ProductRequest.assigned_technician_id == technician_id
    ).first()

    if not request:
        raise HTTPException(status_code=404, detail="Request not found")

    # payload is validated by Pydantic; no manual required field checks needed

    # 1️⃣ Create Customer profile linked to user on the request
    auth_user = db.query(User).filter(User.id == request.user_id).first()
    if not auth_user:
        raise HTTPException(status_code=400, detail="Auth user not found for this request")

    customer = Customer(
        user_id=auth_user.id,
        full_name=payload.customer_name,
        mobile_number=auth_user.phone,
        email=getattr(auth_user, "email", None),
        address_line1=payload.address,
        address_line2=payload.address_line2 or payload.site_details,
        city=payload.city or "",
        state=payload.state or "",
        pincode=payload.pincode or "",
        landmark=payload.landmark or ""
    )
    db.add(customer)
    db.commit()
    db.refresh(customer)

    # 2️⃣ Create installation
    installation = Installation(
        customer_id=customer.id,
        purifier_model_id=payload.purifier_model_id,
        install_date=payload.installation_date,
        status="ACTIVE"
    )
    db.add(installation)
    db.flush()

    # 3️⃣ Fetch purifier model and generate services
    purifier_model = db.query(PurifierModel).filter(
        PurifierModel.id == payload.purifier_model_id
    ).first()

    if not purifier_model:
        raise HTTPException(status_code=400, detail="Purifier model not found")

    generate_services(db=db, installation=installation, purifier_model=purifier_model)

    # 4️⃣ Mark user profile completed and update request
    auth_user.profile_completed = True
    request.customer_id = customer.id
    request.status = "completed"

    # 5️⃣ Log technician activity
    log = TechnicianActivityLog(
        technician_id=technician_id,
        action="INSTALLATION_COMPLETED",
    )
    db.add(log)

    db.commit()

    return {"message": "Installation completed successfully"}

@router.put("/pending-requests/{request_id}/claim")
def claim_product_request(
    request_id: int,
    db: Session = Depends(get_db),
    user=Depends(get_current_user)
):
    """Allow technician to claim an unassigned product request"""
    technician_id = extract_user_id(user)
    
    request = db.query(ProductRequest).filter(
        ProductRequest.id == request_id,
        ProductRequest.assigned_technician_id == None,
        ProductRequest.status == "requested"
    ).first()
    
    if not request:
        raise HTTPException(status_code=404, detail="Request not found or already assigned")
    
    # Assign to this technician
    request.assigned_technician_id = technician_id
    request.status = "assigned"
    db.commit()
    db.refresh(request)
    
    return {"message": "Request claimed successfully", "request_id": request.id}