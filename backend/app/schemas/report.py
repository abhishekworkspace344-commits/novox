from datetime import date, datetime
from decimal import Decimal
from pydantic import BaseModel


class AttendanceReportItem(BaseModel):
    attendance_id: int
    user_id: int
    user_name: str
    attendance_date: date
    check_in: datetime | None
    checkout: datetime | None
    attendance_status: str
    arrival_status: str
    total_break_minutes: int
    total_work_minutes: int


class LateEntryReportItem(BaseModel):
    attendance_id: int
    user_id: int
    user_name: str
    attendance_date: date
    check_in: datetime | None
    arrival_status: str


class FeeReportItem(BaseModel):
    student_fee_id: int
    student_id: int
    student_name: str
    total_amount: Decimal
    paid_amount: Decimal
    pending_amount: Decimal
    status: str


class SalaryReportItem(BaseModel):
    slip_id: int
    staff_id: int
    staff_name: str
    month: int
    year: int
    basic_salary: Decimal
    allowance: Decimal
    deduction: Decimal
    net_salary: Decimal
    status: str