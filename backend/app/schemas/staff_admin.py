from datetime import date
from pydantic import BaseModel, EmailStr


class StaffCreate(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: str | None = None
    employee_code: str
    designation: str
    department: str | None = None
    joining_date: date | None = None


class StaffUpdate(BaseModel):
    name: str | None = None
    phone: str | None = None
    employee_code: str | None = None
    designation: str | None = None
    department: str | None = None
    joining_date: date | None = None


class StaffResponse(BaseModel):
    id: int
    user_id: int
    employee_code: str
    designation: str
    department: str | None
    joining_date: date | None
    name: str
    email: str
    phone: str | None
    is_active: bool

    class Config:
        from_attributes = True