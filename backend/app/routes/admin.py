from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.dependencies import (
    get_db,
    require_role,
)

from app.schemas.admin import (
    DashboardSummary,
    AttendanceMonitorItem,
    PendingFeeItem,
)

from app.services.admin_service import (
    get_dashboard_summary,
    get_today_attendance,
    get_pending_fees,
)


router = APIRouter(
    prefix="/admin",
    tags=["Admin Dashboard"]
)


# ==========================================
# DASHBOARD SUMMARY
# ==========================================

@router.get(
    "/dashboard",
    response_model=DashboardSummary,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def dashboard(
    db: Session = Depends(get_db),
):

    return get_dashboard_summary(db)


# ==========================================
# LIVE / TODAY ATTENDANCE
# ==========================================

@router.get(
    "/attendance/today",
    response_model=list[AttendanceMonitorItem],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def today_attendance(
    db: Session = Depends(get_db),
):

    return get_today_attendance(db)


# ==========================================
# PENDING FEES
# ==========================================

@router.get(
    "/fees/pending",
    response_model=list[PendingFeeItem],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def pending_fees(
    db: Session = Depends(get_db),
):

    return get_pending_fees(db)