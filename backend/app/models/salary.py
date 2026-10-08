from datetime import datetime
from sqlalchemy import DateTime, Integer, Numeric, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base


class SalaryStructure(Base):
    __tablename__ = "salary_structures"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    staff_id: Mapped[int] = mapped_column(
        ForeignKey("staff.id"),
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

    effective_from: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False
    )