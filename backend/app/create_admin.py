from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.database.connection import SessionLocal
from app.database.base import Base
from app.database.connection import engine

# Import ALL models so SQLAlchemy knows about all tables
from app.models.user import User
from app.models.student import Student
from app.models.staff import Staff
from app.models.attendance import Attendance
from app.models.attendance_break import AttendanceBreak
from app.models.geofence import GeofenceSettings
from app.models.fee import FeeStructure, StudentFee
from app.models.payment import Payment
from app.models.salary import SalaryStructure
from app.models.salary_slip import SalarySlip


def create_tables():
    print("Creating NOVOX database tables...")

    Base.metadata.create_all(
        bind=engine
    )

    print("Database tables created successfully.")


def create_admin():

    db: Session = SessionLocal()

    try:

        existing_admin = (
            db.query(User)
            .filter(
                User.email == "admin@novox.com"
            )
            .first()
        )

        if existing_admin:
            print("Admin already exists.")
            return

        admin = User(
            name="NOVOX Administrator",
            email="admin@novox.com",
            password_hash=hash_password(
                "Admin@123"
            ),
            role="admin",
            phone=None,
            is_active=True,
        )

        db.add(admin)
        db.commit()

        print(
            "NOVOX admin created successfully."
        )

        print(
            "Email: admin@novox.com"
        )

        print(
            "Password: Admin@123"
        )

    except Exception as e:

        db.rollback()

        print(
            "Failed to create admin."
        )

        print(
            f"Error: {e}"
        )

        raise

    finally:

        db.close()


if __name__ == "__main__":

    # ---------------------------------------------------------
    # STEP 1: CREATE DATABASE TABLES
    # ---------------------------------------------------------

    create_tables()

    # ---------------------------------------------------------
    # STEP 2: CREATE ADMIN USER
    # ---------------------------------------------------------

    create_admin()