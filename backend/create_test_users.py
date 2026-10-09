from app.database.connection import SessionLocal
from app.models.user import User
from app.models.student import Student
from app.models.staff import Staff
from app.core.security import hash_password


def create_test_users():
    db = SessionLocal()

    try:
        # ============================================================
        # ADMIN
        # ============================================================

        admin = (
            db.query(User)
            .filter(User.email == "admin@novox.com")
            .first()
        )

        if not admin:
            admin = User(
                name="NOVOX Administrator",
                email="admin@novox.com",
                password_hash=hash_password("Admin@123"),
                role="admin",
                phone="9000000001",
                is_active=True,
            )

            db.add(admin)
            db.flush()

            print("Admin created")
        else:
            print("Admin already exists")

        # ============================================================
        # STAFF USER
        # ============================================================

        staff_user = (
            db.query(User)
            .filter(User.email == "staff@novox.com")
            .first()
        )

        if not staff_user:
            staff_user = User(
                name="NOVOX Staff",
                email="staff@novox.com",
                password_hash=hash_password("Staff@123"),
                role="staff",
                phone="9000000002",
                is_active=True,
            )

            db.add(staff_user)
            db.flush()

            print("Staff user created")

        else:
            print("Staff user already exists")

        # ============================================================
        # STAFF PROFILE
        # ============================================================

        if staff_user:
            existing_staff = (
                db.query(Staff)
                .filter(
                    Staff.user_id == staff_user.id
                )
                .first()
            )

            if not existing_staff:
                staff = Staff(
                    user_id=staff_user.id,
                    employee_code="NOVOX-STF-001",
                    designation="Faculty",
                    department="Computer Science",
                )

                db.add(staff)

                print("Staff profile created")

            else:
                print("Staff profile already exists")

        # ============================================================
        # STUDENT USER
        # ============================================================

        student_user = (
            db.query(User)
            .filter(User.email == "student@novox.com")
            .first()
        )

        if not student_user:
            student_user = User(
                name="NOVOX Student",
                email="student@novox.com",
                password_hash=hash_password("Student@123"),
                role="student",
                phone="9000000003",
                is_active=True,
            )

            db.add(student_user)
            db.flush()

            print("Student user created")

        else:
            print("Student user already exists")

        # ============================================================
        # STUDENT PROFILE
        # ============================================================

        if student_user:
            existing_student = (
                db.query(Student)
                .filter(
                    Student.user_id == student_user.id
                )
                .first()
            )

            if not existing_student:
                student = Student(
                    user_id=student_user.id,
                    student_code="NOVOX-STU-001",
                    course="MCA",
                    batch="2025-2027",
                )

                db.add(student)

                print("Student profile created")

            else:
                print("Student profile already exists")

        # ============================================================
        # COMMIT
        # ============================================================

        db.commit()

        # ============================================================
        # RESULT
        # ============================================================

        print()
        print("=" * 60)
        print("NOVOX TEST ACCOUNTS")
        print("=" * 60)

        print()
        print("ADMIN")
        print("Email    : admin@novox.com")
        print("Password : Admin@123")

        print()
        print("STAFF")
        print("Email    : staff@novox.com")
        print("Password : Staff@123")
        print("Employee : NOVOX-STF-001")

        print()
        print("STUDENT")
        print("Email    : student@novox.com")
        print("Password : Student@123")
        print("Student  : NOVOX-STU-001")

        print()
        print("=" * 60)
        print("ALL TEST ACCOUNTS READY")
        print("=" * 60)

    except Exception as e:
        db.rollback()

        print()
        print("=" * 60)
        print("ERROR CREATING TEST USERS")
        print("=" * 60)
        print(e)

        raise

    finally:
        db.close()


if __name__ == "__main__":
    create_test_users()