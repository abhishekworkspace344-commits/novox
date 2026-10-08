from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class SalaryStructureCreate(BaseModel):
    staff_id: int
    basic_salary: Decimal
    allowance: Decimal = Decimal("0")
    deduction: Decimal = Decimal("0")
    effective_from: datetime


class SalaryStructureResponse(BaseModel):
    id: int
    staff_id: int
    basic_salary: Decimal
    allowance: Decimal
    deduction: Decimal
    effective_from: datetime

    class Config:
        from_attributes = True


class SalarySlipResponse(BaseModel):
    id: int
    staff_id: int
    month: int
    year: int
    basic_salary: Decimal
    allowance: Decimal
    deduction: Decimal
    net_salary: Decimal
    status: str
    generated_at: datetime

    class Config:
        from_attributes = True