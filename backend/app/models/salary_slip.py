from datetime import datetime

from sqlalchemy import DateTime, Integer, Numeric, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base


class SalarySlip(Base):
    __tablename__ = "salary_slips"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    staff_id: Mapped[int] = mapped_column(
        ForeignKey("staff.id"),
        nullable=False
    )

    month: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    year: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    basic_salary: Mapped[float] = mapped_column(
        Numeric(12, 2),
        nullable=False
    )

    allowance: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    deduction: Mapped[float] = mapped_column(
        Numeric(12, 2),
        default=0
    )

    net_salary: Mapped[float] = mapped_column(
        Numeric(12, 2),
        nullable=False
    )

    status: Mapped[str] = mapped_column(
        String(30),
        default="GENERATED",
        nullable=False
    )

    generated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )