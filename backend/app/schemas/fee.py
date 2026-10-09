from datetime import datetime

from pydantic import BaseModel, Field


class FeeStructureCreate(BaseModel):
    course: str
    fee_type: str
    total_amount: float = Field(gt=0)
    description: str | None = None


class FeeStructureUpdate(FeeStructureCreate):
    pass


class FeeStructureResponse(BaseModel):
    id: int
    course: str
    fee_type: str
    total_amount: float
    description: str | None

    class Config:
        from_attributes = True


class StudentFeeCreate(BaseModel):
    student_id: int
    fee_structure_id: int | None = None
    total_amount: float = Field(gt=0)


class StudentFeeUpdate(BaseModel):
    total_amount: float = Field(gt=0)


class StudentFeeResponse(BaseModel):
    id: int
    student_id: int
    fee_structure_id: int | None
    total_amount: float
    paid_amount: float
    pending_amount: float
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class StudentFeeAdminResponse(StudentFeeResponse):
    student_name: str
    student_code: str
    course: str


class PaymentCreate(BaseModel):
    student_fee_id: int
    amount: float = Field(gt=0)
    payment_method: str
    transaction_id: str | None = None


class PaymentResponse(BaseModel):
    id: int
    student_fee_id: int
    student_id: int
    amount: float
    payment_method: str
    transaction_id: str | None
    payment_date: datetime
    receipt_number: str | None

    class Config:
        from_attributes = True
