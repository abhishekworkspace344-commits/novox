from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel


class StudentPaymentHistoryResponse(BaseModel):
    id: int
    student_fee_id: int
    student_id: int
    amount: Decimal
    payment_method: str
    transaction_id: str | None
    payment_date: datetime
    receipt_number: str | None

    class Config:
        from_attributes = True