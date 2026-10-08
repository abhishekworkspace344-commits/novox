from datetime import date

from fastapi import APIRouter, Depends, Query
from fastapi.responses import StreamingResponse, Response
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, require_role
from app.models.user import User

from app.services.report_service import (
    get_attendance_report,
    get_fee_report,
    get_salary_report,
)

from app.services.report_export_service import (
    create_attendance_pdf,
    create_fee_pdf,
    create_salary_pdf,
    create_csv,
)

router = APIRouter(
    prefix="/admin/reports/export",
    tags=["Report Exports"],
)

@router.get("/attendance/pdf")
def export_attendance_pdf(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    records = get_attendance_report(
        db,
        start_date,
        end_date,
    )

    pdf = create_attendance_pdf(records)

    return StreamingResponse(
        pdf,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                "attachment; filename=attendance_report.pdf"
        },
    )

@router.get("/fees/pdf")
def export_fee_pdf(
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    records = get_fee_report(db)

    pdf = create_fee_pdf(records)

    return StreamingResponse(
        pdf,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                "attachment; filename=fee_report.pdf"
        },
    )


@router.get("/salary/pdf")
def export_salary_pdf(
    month: int | None = Query(None, ge=1, le=12),
    year: int | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    records = get_salary_report(
        db,
        month,
        year,
    )

    pdf = create_salary_pdf(records)

    return StreamingResponse(
        pdf,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                "attachment; filename=salary_report.pdf"
        },
    )


@router.get("/attendance/csv")
def export_attendance_csv(
    start_date: date | None = Query(None),
    end_date: date | None = Query(None),
    current_user: User = Depends(
        require_role("admin")
    ),
    db: Session = Depends(get_db),
):
    records = get_attendance_report(
        db,
        start_date,
        end_date,
    )

    rows = []

    for item in records:
        rows.append([
            item["user_name"],
            item["attendance_date"],
            item["check_in"],
            item["checkout"],
            item["attendance_status"],
            item["arrival_status"],
            item["total_break_minutes"],
            item["total_work_minutes"],
        ])

    content = create_csv(
        [
            "Name",
            "Date",
            "Check In",
            "Checkout",
            "Status",
            "Arrival",
            "Break Minutes",
            "Work Minutes",
        ],
        rows,
    )

    return Response(
        content=content,
        media_type="text/csv",
        headers={
            "Content-Disposition":
                "attachment; filename=attendance_report.csv"
        },
    )


