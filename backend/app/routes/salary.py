from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.staff import Staff

from fastapi.responses import StreamingResponse

from app.models.staff import Staff
from app.models.user import User

from app.services.pdf_service import (
    generate_salary_slip as generate_salary_slip_pdf
)

from app.core.dependencies import get_db, require_role

from app.schemas.salary import (
    SalaryStructureCreate,
    SalaryStructureResponse,
    SalarySlipResponse,
)

from app.services.salary_service import (
    create_salary_structure,
    generate_salary_slip,
)

from app.models.salary_slip import SalarySlip


router = APIRouter(
    prefix="/salary",
    tags=["Salary"]
)


# -----------------------------------------
# CREATE SALARY STRUCTURE
# -----------------------------------------

@router.post(
    "/structure",
    response_model=SalaryStructureResponse,
    dependencies=[Depends(require_role("admin"))],
)
def create_structure(
    data: SalaryStructureCreate,
    db: Session = Depends(get_db),
):

    return create_salary_structure(
        db=db,
        staff_id=data.staff_id,
        basic_salary=data.basic_salary,
        allowance=data.allowance,
        deduction=data.deduction,
    )


# -----------------------------------------
# GENERATE SALARY SLIP
# -----------------------------------------

@router.post(
    "/slip/{staff_id}/{year}/{month}",
    response_model=SalarySlipResponse,
    dependencies=[Depends(require_role("admin"))],
)
def generate_slip(
    staff_id: int,
    year: int,
    month: int,
    db: Session = Depends(get_db),
):

    if month < 1 or month > 12:
        raise HTTPException(
            status_code=400,
            detail="Invalid month"
        )

    try:

        return generate_salary_slip(
            db=db,
            staff_id=staff_id,
            month=month,
            year=year,
        )

    except ValueError as e:

        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


# -----------------------------------------
# STAFF SALARY HISTORY
# -----------------------------------------

@router.get(
    "/staff/{staff_id}",
    response_model=list[SalarySlipResponse],
    dependencies=[Depends(require_role("admin"))],
)
def salary_history(
    staff_id: int,
    db: Session = Depends(get_db),
):

    return (
        db.query(SalarySlip)
        .filter(
            SalarySlip.staff_id == staff_id
        )
        .order_by(
            SalarySlip.year.desc(),
            SalarySlip.month.desc()
        )
        .all()
    )

@router.get(
    "/slip/{slip_id}/pdf",
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def download_salary_slip(
    slip_id: int,
    db: Session = Depends(get_db),
):

    slip = (
        db.query(SalarySlip)
        .filter(
            SalarySlip.id == slip_id
        )
        .first()
    )

    if not slip:
        raise HTTPException(
            status_code=404,
            detail="Salary slip not found",
        )

    staff = (
        db.query(Staff)
        .filter(
            Staff.id == slip.staff_id
        )
        .first()
    )

    if not staff:
        raise HTTPException(
            status_code=404,
            detail="Staff not found",
        )

    user = (
        db.query(User)
        .filter(
            User.id == staff.user_id
        )
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Staff user not found",
        )

    pdf_buffer = generate_salary_slip_pdf(
        salary_slip=slip,
        staff_name=user.name,
        employee_code=staff.employee_code,
        designation=staff.designation,
    )

    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                f'attachment; filename="'
                f'salary-slip-{slip.id}.pdf"'
        },
    )

@router.get(
    "/my-slips",
    response_model=list[SalarySlipResponse],
)
def my_salary_slips(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    if current_user.role != "staff":
        raise HTTPException(
            status_code=403,
            detail="Staff access required",
        )

    staff = (
        db.query(Staff)
        .filter(
            Staff.user_id == current_user.id
        )
        .first()
    )

    if not staff:
        raise HTTPException(
            status_code=404,
            detail="Staff profile not found",
        )

    return (
        db.query(SalarySlip)
        .filter(
            SalarySlip.staff_id == staff.id
        )
        .order_by(
            SalarySlip.year.desc(),
            SalarySlip.month.desc(),
        )
        .all()
    )
