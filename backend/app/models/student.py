from datetime import date

from sqlalchemy import Date, Integer, String, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base


class Student(Base):
    __tablename__ = "students"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        unique=True,
        nullable=False,
    )

    student_code: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False,
        index=True,
    )

    course: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    batch: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    joining_date: Mapped[date | None] = mapped_column(
        Date,
        nullable=True,
    )

    guardian_name: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True,
    )

    guardian_phone: Mapped[str | None] = mapped_column(
        String(20),
        nullable=True,
    )