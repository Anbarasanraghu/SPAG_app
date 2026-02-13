import logging
from fastapi import APIRouter, Depends ,HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.product_request import ProductRequest 
from app.models.installation import Installation
from app.models.technician_activity_log import TechnicianActivityLog
from app.models.customer import Customer
from app.models.purifier_model import PurifierModel
from app.schemas.installation_job import InstallationJobResponse
from datetime import date

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

    requests = db.query(ProductRequest).filter(
        ProductRequest.assigned_technician_id == technician_id,
        ProductRequest.status.in_(["assigned"])
    ).all()

    # Transform to response schema with customer and model details
    result = []
    for req in requests:
        customer = db.query(Customer).filter(Customer.id == req.customer_id).first()
        model = db.query(PurifierModel).filter(PurifierModel.id == req.purifier_model_id).first()
        
        if customer and model:
            job_response = InstallationJobResponse(
                request_id=req.id,
                customer_name=customer.full_name or "",
                customer_phone=customer.mobile_number or "",
                address=f"{customer.address_line1}, {customer.city}, {customer.state}",
                model_name=model.name,
                status=req.status
            )
            result.append(job_response)
    
    return result


@router.put("/installations/{request_id}/complete")
def complete_installation(
    request_id: int,
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

    # 1️⃣ Update request status
    request.status = "INSTALLED"

    # 2️⃣ Create installation
    installation = Installation(
        customer_id=request.customer_id,
        purifier_model_id=request.purifier_model_id,
        install_date=date.today(),
        status="ACTIVE"
    )
    db.add(installation)
    db.flush()  # Get installation.id

    # 3️⃣ Fetch purifier model object properly
    purifier_model = db.query(PurifierModel).filter(
        PurifierModel.id == request.purifier_model_id
    ).first()

    if not purifier_model:
        raise HTTPException(status_code=400, detail="Purifier model not found")

    print("DEBUG MODEL:", purifier_model.free_services)
    print("DEBUG INSTALL DATE:", installation.install_date)

    # 4️⃣ Generate services
    generate_services(
        db=db,
        installation=installation,
        purifier_model=purifier_model
    )

    # 5️⃣ Log technician activity
    log = TechnicianActivityLog(
        technician_id=technician_id,
        action="INSTALLATION_COMPLETED",
    )
    db.add(log)

    db.commit()

    return {"message": "Installation completed successfully"}
