from fastapi import APIRouter, Depends, HTTPException, Body, Request
from fastapi.responses import JSONResponse
import logging
from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from app.core.security import get_current_user, get_optional_current_user
from app.routers.dashboard import get_db
from app.models.customer import Customer
from app.models.product_request import ProductRequest
from app.models.user import User
from app.core.security import hash_password, create_access_token

from app.database import SessionLocal
from app.models.purifier_model import PurifierModel
from app.schemas.purifier_model import PurifierModelCreate, PurifierModelResponse, ProductRequestCreate

router = APIRouter(prefix="/purifier-models", tags=["Purifier Models"])

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
    request: Request,
    data: ProductRequestCreate | None = Body(None),
    purifier_model_id: int | None = None,
    db: Session = Depends(get_db),
    user = Depends(get_optional_current_user)
):
    logger = logging.getLogger(__name__)
    # Attempt to log raw body for debugging client issues
    try:
        raw = request._body if hasattr(request, '_body') else None
    except Exception:
        raw = None
    logger.info("[create_request] purifier_model_id=%s, body=%s, parsed=%s", purifier_model_id, raw, (data.dict() if data else None))
    
    # Ensure we have data or purifier_model_id
    if data is None and purifier_model_id is None:
        raise HTTPException(status_code=400, detail="Either provide purifier_model_id in query parameter or full request data in body")
    
    # If data is None, create from query param
    if data is None:
        data = ProductRequestCreate(purifier_model_id=purifier_model_id)
    elif purifier_model_id is not None:
        data.purifier_model_id = purifier_model_id

    if user:
        # Logged in user: use auth user id; do NOT create customer here
        user_id = user["user_id"]
        customer = None
    else:
        # Anonymous, create user
        if not data.mobile_number or not data.gmail or not data.password:
            raise HTTPException(status_code=400, detail="mobile_number, gmail, password required for anonymous request")
        existing_user = db.query(User).filter_by(phone=data.mobile_number).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="User already exists")
        new_user = User(
            phone=data.mobile_number,
            email=data.gmail,
            password_hash=hash_password(data.password),
            role="customer",
            profile_completed=False
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        user_id = new_user.id
        # Generate token
        token = create_access_token({"user_id": user_id, "phone": data.mobile_number, "role": "customer"})

    # Create product request linked to auth user; customer profile will be created later by technician
    # Try inserting via ORM; if the DB is missing the `user_id` column, attempt
    # to add it and retry once (best-effort). If ALTER is not permitted, return
    # a clear 500 so client can surface a useful message.
    try:
        req = ProductRequest(
            user_id=user_id,
            purifier_model_id=data.purifier_model_id
        )
        db.add(req)
        db.commit()
        db.refresh(req)
    except Exception as e:
        logger.exception("First attempt to create ProductRequest failed: %s", e)
        # Detect missing column error
        msg = str(e)
        if 'product_requests.user_id' in msg or 'column "user_id"' in msg or isinstance(e, ProgrammingError):
            logger.info("Attempting to add missing column product_requests.user_id")
            db.rollback()  # Rollback the failed transaction
            try:
                db.execute(text("ALTER TABLE product_requests ADD COLUMN user_id INTEGER;"))
                db.commit()
            except Exception as e2:
                logger.exception("Could not add user_id column automatically: %s", e2)
                raise HTTPException(status_code=500, detail="Database schema missing product_requests.user_id; please add column in DB console")

            # Retry insert
            try:
                req = ProductRequest(
                    user_id=user_id,
                    purifier_model_id=data.purifier_model_id
                )
                db.add(req)
                db.commit()
                db.refresh(req)
            except Exception as e3:
                logger.exception("Retry after adding column failed: %s", e3)
                raise HTTPException(status_code=500, detail="Failed to create product request after schema migration")
        else:
            logger.exception("Unexpected error creating ProductRequest: %s", e)
            raise HTTPException(status_code=500, detail="Failed to create product request")

    # Return useful response so the client can store token (if created) and request id
    response = {"request_id": req.id}
    if 'token' in locals():
        response['token'] = token
    return JSONResponse(status_code=201, content=response)
@router.get("/product-requests", response_model=list)
def list_product_requests(
    db: Session = Depends(get_db),
    user = Depends(get_optional_current_user)
):
    if not user:
        raise HTTPException(status_code=401, detail="Authentication required")
    
    user_id = user["user_id"]
    requests = db.query(ProductRequest).filter(ProductRequest.user_id == user_id).all()
    
    # Return with model details
    result = []
    for req in requests:
        model = db.query(PurifierModel).filter(PurifierModel.id == req.purifier_model_id).first()
        result.append({
            "id": req.id,
            "purifier_model_id": req.purifier_model_id,
            "model_name": model.name if model else "Unknown",
            "status": req.status,
            "created_at": getattr(req, 'created_at', None).isoformat() if getattr(req, 'created_at', None) else None,
        })
    return result