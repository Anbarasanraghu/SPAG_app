from fastapi import FastAPI
from app.database import engine, Base
from app.models import purifier_model, user, customer, installation, service_history
from app.routers import purifier_model ,customer ,installation ,service_history ,dashboard ,auth,admin
from fastapi.middleware.cors import CORSMiddleware

Base.metadata.create_all(bind=engine)


app = FastAPI(title="SPAG Purifier Service App")

app.include_router(purifier_model.router)
app.include_router(customer.router)
app.include_router(installation.router)
app.include_router(service_history.router)
app.include_router(dashboard.router)
app.include_router(auth.router)
app.include_router(admin.router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # dev only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"status": "SPAG Backend Running"}
