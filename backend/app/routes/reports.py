from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, require_role
from app.models.user import User
from app.services.report_service import (
    get_attendance_report,
    get_late_entry_report,
    get_fee_report,
    get_salary_report,
    get_reports_summary,
)

router = APIRouter(
    prefix="/admin/reports",
    tags=["Admin Reports"],
)

@router.get("/summary")
def reports_summary(
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    return get_reports_summary(db)

@router.get("/attendance")
def attendance_report(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    return get_attendance_report(
        db=db,
        start_date=start_date,
        end_date=end_date,
    )


@router.get("/late-entry")
def late_entry_report(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    return get_late_entry_report(
        db=db,
        start_date=start_date,
        end_date=end_date,
    )

@router.get("/fees")
def fee_report(
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    return get_fee_report(db)

@router.get("/salary")
def salary_report(
    month: int | None = Query(None, ge=1, le=12),
    year: int | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    return get_salary_report(
        db=db,
        month=month,
        year=year,
    )
