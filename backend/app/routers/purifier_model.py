from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

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
