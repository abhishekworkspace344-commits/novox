from datetime import datetime

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base


class FeeStructure(Base):
    __tablename__ = "fee_structures"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    course: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    fee_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    total_amount: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    description: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )


class StudentFee(Base):
    __tablename__ = "student_fees"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    student_id: Mapped[int] = mapped_column(
        ForeignKey("students.id"),
        nullable=False,
        index=True,
    )

    fee_structure_id: Mapped[int | None] = mapped_column(
        ForeignKey("fee_structures.id"),
        nullable=True,
    )

    total_amount: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    paid_amount: Mapped[float] = mapped_column(
        Float,
        default=0,
        nullable=False,
    )

    pending_amount: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    status: Mapped[str] = mapped_column(
        String(30),
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )