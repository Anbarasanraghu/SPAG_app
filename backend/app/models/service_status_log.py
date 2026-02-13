from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.sql import func
from app.database import Base


class ServiceStatusLog(Base):
    __tablename__ = "service_status_logs"

    id = Column(Integer, primary_key=True, index=True)

    service_id = Column(
        Integer,
        ForeignKey("service_history.id", ondelete="CASCADE"),
        nullable=False,
    )

    old_status = Column(String, nullable=True)
    new_status = Column(String, nullable=False)

    changed_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
    )

    # changed_by_role = Column(String, nullable=True)

    changed_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
