from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import (
    get_current_user,
    get_db,
    require_role,
)
from app.models.user import User
from app.schemas.attendance import (
    CheckInRequest,
    CheckInResponse,
    CheckoutRequest,
    CheckoutResponse,
    AttendanceHistoryItem,
    AttendanceHistoryResponse,
)
from app.services.attendance_service import (
    check_in_user,
    checkout_user,
    auto_checkout_user,
    get_attendance_history,
    start_break,
    end_break,
)


router = APIRouter(
    prefix="/attendance",
    tags=["Attendance"],
)


@router.post(
    "/check-in",
    response_model=CheckInResponse,
)
def check_in(
    request: CheckInRequest,
    current_user: User = Depends(
        require_role(
            "student",
            "staff",
        )
    ),
    db: Session = Depends(get_db),
):
    result = check_in_user(
        db=db,
        user_id=current_user.id,
        latitude=request.latitude,
        longitude=request.longitude,
    )

    attendance = result["attendance"]

    if not result["success"]:
        return CheckInResponse(
            success=False,
            message=result["message"],
            distance_meters=result["distance"],
        )

    return CheckInResponse(
        success=True,
        message=result["message"],
        attendance_id=attendance.id,
        attendance_status=attendance.attendance_status,
        arrival_status=attendance.arrival_status,
        check_in=attendance.check_in,
        distance_meters=result["distance"],
    )


@router.post(
    "/auto-checkout",
    response_model=CheckoutResponse,
)
def auto_checkout(
    data: CheckoutRequest,
    current_user: User = Depends(
        require_role("student", "staff")
    ),
    db: Session = Depends(get_db),
):
    result = auto_checkout_user(
        db=db,
        user_id=current_user.id,
        latitude=data.latitude or 0.0,
        longitude=data.longitude or 0.0,
    )

    attendance = result.get("attendance")

    return CheckoutResponse(
        success=result["success"],
        message=result["message"],
        checkout=attendance.checkout if attendance else None,
        total_break_minutes=attendance.total_break_minutes if attendance else None,
        total_work_minutes=attendance.total_work_minutes if attendance else None,
    )


@router.post(
    "/checkout",
    response_model=CheckoutResponse,
)
def checkout(
    current_user: User = Depends(
        require_role("student", "staff")
    ),
    db: Session = Depends(get_db),
):
    result = checkout_user(
        db=db,
        user_id=current_user.id,
    )

    attendance = result.get("attendance")

    return CheckoutResponse(
        success=result["success"],
        message=result["message"],
        checkout=attendance.checkout if attendance else None,
        total_break_minutes=attendance.total_break_minutes if attendance else None,
        total_work_minutes=attendance.total_work_minutes if attendance else None,
    )


@router.post("/break/start")
def start_break_route(
    current_user: User = Depends(
        require_role("student", "staff")
    ),
    db: Session = Depends(get_db),
):
    return start_break(db=db, user_id=current_user.id)


@router.post("/break/end")
def end_break_route(
    current_user: User = Depends(
        require_role("student", "staff")
    ),
    db: Session = Depends(get_db),
):
    return end_break(db=db, user_id=current_user.id)


@router.get(
    "/history",
    response_model=AttendanceHistoryResponse,
)
def attendance_history(
    month: int | None = None,
    year: int | None = None,
    current_user: User = Depends(
        require_role("student", "staff")
    ),
    db: Session = Depends(get_db),
):
    records = get_attendance_history(
        db=db,
        user_id=current_user.id,
        month=month,
        year=year,
    )

    return AttendanceHistoryResponse(
        success=True,
        total_records=len(records),
        records=records,
    )