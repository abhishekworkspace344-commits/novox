from datetime import datetime

from sqlalchemy.orm import Session

from app.models.salary import SalaryStructure
from app.models.salary_slip import SalarySlip


def create_salary_structure(
    db: Session,
    staff_id: int,
    basic_salary: float,
    allowance: float,
    deduction: float,
):
    salary = SalaryStructure(
        staff_id=staff_id,
        basic_salary=basic_salary,
        allowance=allowance,
        deduction=deduction,
    )

    db.add(salary)
    db.commit()
    db.refresh(salary)

    return salary


def generate_salary_slip(
    db: Session,
    staff_id: int,
    month: int,
    year: int,
):
    salary_structure = (
        db.query(SalaryStructure)
        .filter(
            SalaryStructure.staff_id == staff_id
        )
        .order_by(
            SalaryStructure.effective_from.desc()
        )
        .first()
    )

    if not salary_structure:
        raise ValueError(
            "Salary structure not found"
        )

    existing_slip = (
        db.query(SalarySlip)
        .filter(
            SalarySlip.staff_id == staff_id,
            SalarySlip.month == month,
            SalarySlip.year == year,
        )
        .first()
    )

    if existing_slip:
        raise ValueError(
            "Salary slip already exists for this month"
        )

    net_salary = (
        salary_structure.basic_salary
        + salary_structure.allowance
        - salary_structure.deduction
    )

    slip = SalarySlip(
        staff_id=staff_id,
        month=month,
        year=year,
        basic_salary=salary_structure.basic_salary,
        allowance=salary_structure.allowance,
        deduction=salary_structure.deduction,
        net_salary=net_salary,
        status="GENERATED",
    )

    db.add(slip)
    db.commit()
    db.refresh(slip)

    return slip