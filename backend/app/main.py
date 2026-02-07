from fastapi import FastAPI
from app.database import engine, Base
import logging
from app.models import purifier_model, user, customer, installation, service_history
from app.routers import purifier_model ,customer ,installation ,service_history ,dashboard ,auth,admin
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="SPAG Purifier Service App")


@app.on_event("startup")
def on_startup():
    try:
        Base.metadata.create_all(bind=engine)
        logging.getLogger(__name__).info("Database tables ensured")
    except Exception as e:
        logging.getLogger(__name__).warning(
            f"Could not connect to database during startup: {e}. Continuing without DB."
        )

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

if __name__ == "__main__":
    import uvicorn
    print("Starting server on 127.0.0.1:8000")
    uvicorn.run(app, host="127.0.0.1", port=8000)
