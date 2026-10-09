from datetime import datetime

from sqlalchemy.orm import Session

from app.models.fee import FeeStructure, StudentFee
from app.models.payment import Payment


# ============================================================
# FEE STATUS
# ============================================================

def calculate_fee_status(
    total_amount: float,
    paid_amount: float,
):
    pending_amount = max(
        total_amount - paid_amount,
        0,
    )

    if paid_amount <= 0:
        status = "PENDING"

    elif paid_amount < total_amount:
        status = "PARTIALLY_PAID"

    else:
        status = "PAID"

    return pending_amount, status


# ============================================================
# CREATE FEE STRUCTURE
# ============================================================

def create_fee_structure(
    db: Session,
    course: str,
    fee_type: str,
    total_amount: float,
    description: str | None = None,
):
    fee_structure = FeeStructure(
        course=course,
        fee_type=fee_type,
        total_amount=total_amount,
        description=description,
    )

    db.add(fee_structure)
    db.commit()
    db.refresh(fee_structure)

    return fee_structure


def update_fee_structure(
    db: Session,
    structure_id: int,
    course: str,
    fee_type: str,
    total_amount: float,
    description: str | None = None,
):
    structure = db.query(FeeStructure).filter(
        FeeStructure.id == structure_id
    ).first()
    if not structure:
        raise ValueError("Fee structure not found")

    structure.course = course
    structure.fee_type = fee_type
    structure.total_amount = total_amount
    structure.description = description
    db.commit()
    db.refresh(structure)
    return structure


def update_student_fee(
    db: Session,
    student_fee: StudentFee,
    total_amount: float,
):
    if total_amount < student_fee.paid_amount:
        raise ValueError(
            "Total fee cannot be less than the amount already paid"
        )

    student_fee.total_amount = total_amount
    pending_amount, status = calculate_fee_status(
        total_amount,
        student_fee.paid_amount,
    )
    student_fee.pending_amount = pending_amount
    student_fee.status = status
    db.commit()
    db.refresh(student_fee)
    return student_fee


# ============================================================
# ASSIGN FEE TO STUDENT
# ============================================================

def assign_student_fee(
    db: Session,
    student_id: int,
    fee_structure_id: int | None,
    total_amount: float,
):
    student_fee = StudentFee(
        student_id=student_id,
        fee_structure_id=fee_structure_id,
        total_amount=total_amount,
        paid_amount=0,
        pending_amount=total_amount,
        status="PENDING",
    )

    db.add(student_fee)
    db.commit()
    db.refresh(student_fee)

    return student_fee


# ============================================================
# CREATE PAYMENT
# ============================================================

def create_payment(
    db: Session,
    student_fee: StudentFee,
    amount: float,
    payment_method: str,
    transaction_id: str | None = None,
):
    # --------------------------------------------------------
    # Validate payment amount
    # --------------------------------------------------------

    if amount <= 0:
        raise ValueError(
            "Payment amount must be greater than zero"
        )

    if amount > student_fee.pending_amount:
        raise ValueError(
            "Payment amount exceeds pending fee"
        )

    # --------------------------------------------------------
    # Update paid amount
    # --------------------------------------------------------

    student_fee.paid_amount += amount

    # --------------------------------------------------------
    # Recalculate pending/status
    # --------------------------------------------------------

    pending_amount, status = calculate_fee_status(
        student_fee.total_amount,
        student_fee.paid_amount,
    )

    student_fee.pending_amount = pending_amount
    student_fee.status = status

    # --------------------------------------------------------
    # Generate receipt number
    # --------------------------------------------------------

    receipt_number = (
        f"NOVOX-"
        f"{datetime.now().strftime('%Y%m%d%H%M%S')}"
        f"-{student_fee.student_id}"
    )

    # --------------------------------------------------------
    # Create payment
    # --------------------------------------------------------

    payment = Payment(
        student_fee_id=student_fee.id,
        student_id=student_fee.student_id,
        amount=amount,
        payment_method=payment_method,
        transaction_id=transaction_id,
        receipt_number=receipt_number,
    )

    db.add(payment)

    db.commit()

    db.refresh(payment)

    return payment


# ============================================================
# GET STUDENT PAYMENT HISTORY
# ============================================================

def get_my_payment_history(
    db: Session,
    student_id: int,
):
    return (
        db.query(Payment)
        .filter(
            Payment.student_id == student_id
        )
        .order_by(
            Payment.payment_date.desc()
        )
        .all()
    )


# ============================================================
# GET STUDENT FEES
# ============================================================

def get_student_fees(
    db: Session,
    student_id: int,
):
    return (
        db.query(StudentFee)
        .filter(
            StudentFee.student_id == student_id
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


# ============================================================
# GET PENDING FEES
# ============================================================

def get_pending_fees(
    db: Session,
):
    return (
        db.query(StudentFee)
        .filter(
            StudentFee.pending_amount > 0
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


# ============================================================
# GET PAYMENTS FOR A FEE
# ============================================================

def get_fee_payments(
    db: Session,
    student_fee_id: int,
):
    return (
        db.query(Payment)
        .filter(
            Payment.student_fee_id == student_fee_id
        )
        .order_by(
            Payment.payment_date.desc()
        )
        .all()
    )


# ============================================================
# GET PAYMENT BY RECEIPT NUMBER
# ============================================================

def get_payment_by_receipt(
    db: Session,
    receipt_number: str,
):
    return (
        db.query(Payment)
        .filter(
            Payment.receipt_number == receipt_number
        )
        .first()
    )
