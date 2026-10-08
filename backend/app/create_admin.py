from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.database.connection import SessionLocal
from app.models.user import User


def create_admin():

    db: Session = SessionLocal()

    try:

        existing_admin = (
            db.query(User)
            .filter(User.email == "admin@novox.com")
            .first()
        )

        if existing_admin:
            print("Admin already exists.")
            return

        admin = User(
            name="NOVOX Administrator",
            email="admin@novox.com",
            password_hash=hash_password("Admin@123"),
            role="admin",
            phone=None,
            is_active=True,
        )

        db.add(admin)
        db.commit()

        print("NOVOX admin created successfully.")

    finally:
        db.close()


if __name__ == "__main__":
    create_admin()