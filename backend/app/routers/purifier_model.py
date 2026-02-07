from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.security import get_current_user
from app.routers.dashboard import get_db
from app.models.customer import Customer
from app.models.product_request import ProductRequest

from app.database import SessionLocal
from app.models.purifier_model import PurifierModel
from app.schemas.purifier_model import PurifierModelCreate, PurifierModelResponse

router = APIRouter(prefix="/purifier-models", tags=["Purifier Models"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=PurifierModelResponse)
def create_purifier_model(data: PurifierModelCreate, db: Session = Depends(get_db)):
    model = PurifierModel(**data.dict())
    db.add(model)
    db.commit()
    db.refresh(model)
    return model

@router.get("/", response_model=list[PurifierModelResponse])
def list_purifier_models(db: Session = Depends(get_db)):
    return db.query(PurifierModel).all()


@router.post("/product-requests")
def create_request(
    purifier_model_id: int,
    db: Session = Depends(get_db),
    user = Depends(get_current_user)
):
    # customer = db.query(Customer).filter_by(user_id=user.id).first()
    # customer = db.query(Customer).filter_by(user_id=user["id"]).first()
    customer = db.query(Customer).filter_by(user_id=user["user_id"]).first()

    if not customer:
        customer = Customer(
            user_id=user["user_id"],
            address=""  # can be updated later
        )
    db.add(customer)
    db.commit()
    db.refresh(customer)


    req = ProductRequest(
        customer_id=customer.id,
        purifier_model_id=purifier_model_id
    )
    db.add(req)
    db.commit()
    return {"message": "Request submitted"}