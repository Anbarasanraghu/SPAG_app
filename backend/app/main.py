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
        # Ensure columns exist
        try:
            with engine.connect() as conn:
                dialect = conn.dialect.name
                if dialect == "postgresql":
                    # Check for changed_by_role in service_status_logs
                    res = conn.execute(
                        text("SELECT column_name FROM information_schema.columns WHERE table_name='service_status_logs' AND column_name='changed_by_role'")
                    )
                    exists = res.first() is not None
                    if not exists:
                        conn.execute(text("ALTER TABLE service_status_logs ADD COLUMN changed_by_role VARCHAR;"))
                        logging.getLogger(__name__).info("Added missing column changed_by_role to service_status_logs")
                    # Check for email and profile_completed in users
                    res = conn.execute(
                        text("SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='email'")
                    )
                    if not res.first():
                        conn.execute(text("ALTER TABLE users ADD COLUMN email VARCHAR;"))
                        logging.getLogger(__name__).info("Added missing column email to users")
                    res = conn.execute(
                        text("SELECT column_name FROM information_schema.columns WHERE table_name='users' AND column_name='profile_completed'")
                    )
                    if not res.first():
                        conn.execute(text("ALTER TABLE users ADD COLUMN profile_completed BOOLEAN DEFAULT FALSE;"))
                        logging.getLogger(__name__).info("Added missing column profile_completed to users")
                        # Ensure product_requests has user_id column (added in refactor)
                        res = conn.execute(
                            text("SELECT column_name FROM information_schema.columns WHERE table_name='product_requests' AND column_name='user_id'")
                        )
                        if not res.first():
                            try:
                                conn.execute(text("ALTER TABLE product_requests ADD COLUMN user_id INTEGER;"))
                                logging.getLogger(__name__).info("Added missing column user_id to product_requests")
                                try:
                                    conn.execute(text("ALTER TABLE product_requests ADD CONSTRAINT fk_product_requests_user FOREIGN KEY (user_id) REFERENCES users(id);") )
                                    logging.getLogger(__name__).info("Added FK constraint product_requests.user_id -> users.id")
                                except Exception:
                                    # constraint addition best-effort
                                    pass
                            except Exception:
                                logging.getLogger(__name__).warning("Could not add user_id to product_requests")
                else:
                    # sqlite
                    try:
                        res = conn.execute(text("PRAGMA table_info('service_status_logs')"))
                        cols = [row[1] for row in res.fetchall()]
                        if 'changed_by_role' not in cols:
                            conn.execute(text("ALTER TABLE service_status_logs ADD COLUMN changed_by_role VARCHAR;"))
                            logging.getLogger(__name__).info("Added missing column changed_by_role to service_status_logs (sqlite)")
                        res = conn.execute(text("PRAGMA table_info('users')"))
                        cols = [row[1] for row in res.fetchall()]
                        if 'email' not in cols:
                            conn.execute(text("ALTER TABLE users ADD COLUMN email VARCHAR;"))
                            logging.getLogger(__name__).info("Added missing column email to users (sqlite)")
                        if 'profile_completed' not in cols:
                            conn.execute(text("ALTER TABLE users ADD COLUMN profile_completed BOOLEAN DEFAULT FALSE;"))
                            logging.getLogger(__name__).info("Added missing column profile_completed to users (sqlite)")
                    except Exception:
                        # best-effort
                        pass

                # Universal check: try PostgreSQL information_schema, fall back to SQLite PRAGMA
                try:
                    # Try postgres-style check
                    res = conn.execute(
                        text("SELECT column_name FROM information_schema.columns WHERE table_name='product_requests' AND column_name='user_id'")
                    )
                    if not res.first():
                        try:
                            conn.execute(text("ALTER TABLE product_requests ADD COLUMN user_id INTEGER;"))
                            logging.getLogger(__name__).info("Added missing column user_id to product_requests")
                            try:
                                conn.execute(text("ALTER TABLE product_requests ADD CONSTRAINT fk_product_requests_user FOREIGN KEY (user_id) REFERENCES users(id);") )
                                logging.getLogger(__name__).info("Added FK constraint product_requests.user_id -> users.id")
                            except Exception:
                                pass
                        except Exception:
                            logging.getLogger(__name__).warning("Could not add user_id to product_requests")
                except Exception:
                    # Fallback for sqlite
                    try:
                        res = conn.execute(text("PRAGMA table_info('product_requests')"))
                        pr_cols = [row[1] for row in res.fetchall()]
                        if 'user_id' not in pr_cols:
                            try:
                                conn.execute(text("ALTER TABLE product_requests ADD COLUMN user_id INTEGER;"))
                                logging.getLogger(__name__).info("Added missing column user_id to product_requests (sqlite)")
                            except Exception:
                                logging.getLogger(__name__).warning("Could not add user_id to product_requests (sqlite)")
                    except Exception:
                        pass
        except Exception:
            logging.getLogger(__name__).exception("Error while ensuring schema")
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
    print("Starting server on 192.168.1.7:3000")
    uvicorn.run(app, host="192.168.1.3", port=3000)
