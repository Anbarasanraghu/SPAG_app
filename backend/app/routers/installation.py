from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import SessionLocal
from app.models.installation import Installation
from app.models.customer import Customer
from app.models.purifier_model import PurifierModel
from app.schemas.installation import InstallationCreate, InstallationResponse
from app.core.service_generator import generate_services


router = APIRouter(prefix="/installations", tags=["Installations"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=InstallationResponse)
def create_installation(data: InstallationCreate, db: Session = Depends(get_db)):
    customer = db.query(Customer).filter(Customer.id == data.customer_id).first()
    if not customer:
        raise HTTPException(status_code=404, detail="Customer not found")

    model = db.query(PurifierModel).filter(PurifierModel.id == data.purifier_model_id).first()
    if not model:
        raise HTTPException(status_code=404, detail="Purifier model not found")

    installation = Installation(
        customer_id=data.customer_id,
        purifier_model_id=data.purifier_model_id,
        install_date=data.install_date,
        status="INSTALLED"
    )

    db.add(installation)
    db.commit()
    db.refresh(installation)
    generate_services(db, installation, model)

    return installation
