from datetime import date, datetime

from sqlalchemy import (
    Date,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base


class Attendance(Base):
    __tablename__ = "attendance"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False,
        index=True,
    )

    attendance_date: Mapped[date] = mapped_column(
        Date,
        nullable=False,
        index=True,
    )

    check_in: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    checkout: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True,
    )

    attendance_status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    arrival_status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    check_in_latitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    check_in_longitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    check_in_distance: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    checkout_latitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    checkout_longitude: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    total_break_minutes: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    total_work_minutes: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )