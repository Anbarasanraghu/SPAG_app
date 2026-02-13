from fastapi import FastAPI
from app.database import engine, Base
import logging
from app.models import purifier_model, user, customer, installation, service_history
from sqlalchemy import text
from app.routers import purifier_model ,customer ,installation ,service_history ,dashboard ,auth,admin,customer_profile,technician
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="SPAG Purifier Service App")


@app.on_event("startup")
def on_startup():
    try:
        Base.metadata.create_all(bind=engine)
        logging.getLogger(__name__).info("Database tables ensured")
        # Ensure 'changed_by_role' exists in service_status_logs (add if missing)
        try:
            with engine.connect() as conn:
                dialect = conn.dialect.name
                if dialect == "postgresql":
                    res = conn.execute(
                        text("SELECT column_name FROM information_schema.columns WHERE table_name='service_status_logs' AND column_name='changed_by_role'")
                    )
                    exists = res.first() is not None
                    if not exists:
                        conn.execute(text("ALTER TABLE service_status_logs ADD COLUMN changed_by_role VARCHAR;"))
                        logging.getLogger(__name__).info("Added missing column changed_by_role to service_status_logs")
                else:
                    # sqlite or others: use pragma or attempt alter
                    try:
                        res = conn.execute(text("PRAGMA table_info('service_status_logs')"))
                        cols = [row[1] for row in res.fetchall()]
                        if 'changed_by_role' not in cols:
                            conn.execute(text("ALTER TABLE service_status_logs ADD COLUMN changed_by_role VARCHAR;"))
                            logging.getLogger(__name__).info("Added missing column changed_by_role to service_status_logs (sqlite)")
                    except Exception:
                        # best-effort: try alter and ignore failures
                        try:
                            conn.execute(text("ALTER TABLE service_status_logs ADD COLUMN changed_by_role VARCHAR;"))
                        except Exception:
                            pass
        except Exception:
            logging.getLogger(__name__).exception("Error while ensuring service_status_logs schema")
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
app.include_router(customer_profile.router)
app.include_router(technician.router)

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
    # print("Starting server on 127.0.0.1:8000")
    # uvicorn.run(app, host="127.0.0.1", port=8000)
    print("Starting server on 192.168.1.7:8000")
    uvicorn.run(app, host="192.168.1.3", port=8000)
