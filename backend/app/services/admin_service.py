from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.user import User
from app.models.attendance import Attendance
from app.models.fee import StudentFee


def get_dashboard_summary(db: Session):

    today = date.today()

    total_students = (
        db.query(User)
        .filter(User.role == "student")
        .count()
    )

    total_staff = (
        db.query(User)
        .filter(User.role == "staff")
        .count()
    )

    today_attendance = (
        db.query(Attendance)
        .filter(
            Attendance.attendance_date == today
        )
    )

    present_today = (
        today_attendance
        .filter(
            Attendance.attendance_status == "PRESENT"
        )
        .count()
    )

    late_today = (
        today_attendance
        .filter(
            Attendance.arrival_status == "LATE"
        )
        .count()
    )

    checked_out_today = (
        today_attendance
        .filter(
            Attendance.checkout.isnot(None)
        )
        .count()
    )

    pending_fee_students = (
        db.query(StudentFee)
        .filter(
            StudentFee.status != "PAID"
        )
        .count()
    )

    total_pending_amount = (
        db.query(
            func.coalesce(
                func.sum(StudentFee.pending_amount),
                0
            )
        )
        .filter(
            StudentFee.status != "PAID"
        )
        .scalar()
    )

    return {
        "total_students": total_students,
        "total_staff": total_staff,
        "present_today": present_today,
        "late_today": late_today,
        "checked_out_today": checked_out_today,
        "pending_fee_students": pending_fee_students,
        "total_pending_amount": float(
            total_pending_amount or 0
        ),
    }


def get_today_attendance(db: Session):

    today = date.today()

    return (
        db.query(Attendance)
        .filter(
            Attendance.attendance_date == today
        )
        .order_by(
            Attendance.check_in.desc()
        )
        .all()
    )


def get_pending_fees(db: Session):

    return (
        db.query(StudentFee)
        .filter(
            StudentFee.status != "PAID"
        )
        .order_by(
            StudentFee.pending_amount.desc()
        )
        .all()
    )