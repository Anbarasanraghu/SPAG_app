from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.database import Base


class TechnicianActivityLog(Base):
    __tablename__ = "technician_activity_logs"

    id = Column(Integer, primary_key=True, index=True)

    technician_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    service_id = Column(
        Integer,
        ForeignKey("service_history.id", ondelete="CASCADE"),
        nullable=False,
    )

    action = Column(
        String,
        nullable=False,
    )
    # Examples:
    # ASSIGNED
    # STARTED
    # COMPLETED

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
