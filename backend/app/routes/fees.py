from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from app.models.payment import Payment
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.student import Student

from app.core.dependencies import get_db, require_role
from app.models.fee import FeeStructure, StudentFee
from app.schemas.fee import (
    FeeStructureCreate,
    FeeStructureResponse,
    StudentFeeCreate,
    StudentFeeResponse,
    PaymentCreate,
    PaymentResponse,
)
from app.services.fee_service import (
    create_fee_structure,
    assign_student_fee,
    create_payment,
)
from app.services.pdf_service import generate_fee_receipt

router = APIRouter(prefix="/fees", tags=["Fees"])


# --------------------------------------------------
# ADMIN — CREATE FEE STRUCTURE
# --------------------------------------------------

@router.post(
    "/structure",
    response_model=FeeStructureResponse,
    dependencies=[Depends(require_role("admin"))],
)
def create_structure(
    data: FeeStructureCreate,
    db: Session = Depends(get_db),
):
    return create_fee_structure(
        db=db,
        course=data.course,
        fee_type=data.fee_type,
        total_amount=data.total_amount,
        description=data.description,
    )


# --------------------------------------------------
# ADMIN — ASSIGN FEE TO STUDENT
# --------------------------------------------------

@router.post(
    "/student",
    response_model=StudentFeeResponse,
    dependencies=[Depends(require_role("admin"))],
)
def create_student_fee(
    data: StudentFeeCreate,
    db: Session = Depends(get_db),
):
    return assign_student_fee(
        db=db,
        student_id=data.student_id,
        fee_structure_id=data.fee_structure_id,
        total_amount=data.total_amount,
    )


# --------------------------------------------------
# ADMIN — RECORD PAYMENT
# --------------------------------------------------

@router.post(
    "/payment",
    response_model=PaymentResponse,
    dependencies=[Depends(require_role("admin"))],
)
def record_payment(
    data: PaymentCreate,
    db: Session = Depends(get_db),
):
    student_fee = (
        db.query(StudentFee)
        .filter(StudentFee.id == data.student_fee_id)
        .first()
    )

    if not student_fee:
        raise HTTPException(
            status_code=404,
            detail="Student fee record not found",
        )

    try:
        return create_payment(
            db=db,
            student_fee=student_fee,
            amount=data.amount,
            payment_method=data.payment_method,
            transaction_id=data.transaction_id,
        )
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e),
        )


# --------------------------------------------------
# ADMIN — PENDING FEES
# --------------------------------------------------

@router.get(
    "/pending",
    response_model=list[StudentFeeResponse],
    dependencies=[Depends(require_role("admin"))],
)
def pending_fees(
    db: Session = Depends(get_db),
):
    return (
        db.query(StudentFee)
        .filter(StudentFee.status != "PAID")
        .order_by(StudentFee.created_at.desc())
        .all()
    )


# --------------------------------------------------
# ADMIN — STUDENT FEE DETAILS
# --------------------------------------------------

@router.get(
    "/student/{student_id}",
    response_model=list[StudentFeeResponse],
    dependencies=[Depends(require_role("admin"))],
)
def student_fee_details(
    student_id: int,
    db: Session = Depends(get_db),
):
    return (
        db.query(StudentFee)
        .filter(StudentFee.student_id == student_id)
        .order_by(StudentFee.created_at.desc())
        .all()
    )

@router.get(
    "/payments/{student_fee_id}",
    response_model=list[PaymentResponse],
    dependencies=[Depends(require_role("admin"))],
)
def payment_history(
    student_fee_id: int,
    db: Session = Depends(get_db),
):
    payments = (
        db.query(Payment)
        .filter(Payment.student_fee_id == student_fee_id)
        .order_by(Payment.payment_date.desc())
        .all()
    )

    return payments

@router.get(
    "/receipt/{receipt_number}",
    response_model=PaymentResponse,
    dependencies=[Depends(require_role("admin"))],
)
def get_receipt(
    receipt_number: str,
    db: Session = Depends(get_db),
):
    payment = (
        db.query(Payment)
        .filter(Payment.receipt_number == receipt_number)
        .first()
    )

    if not payment:
        raise HTTPException(
            status_code=404,
            detail="Receipt not found",
        )

    return payment


@router.get(
    "/my-fees",
)
def my_fees(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "student":
        raise HTTPException(
            status_code=403,
            detail="Student access required",
        )

    student = (
        db.query(Student)
        .filter(
            Student.user_id == current_user.id
        )
        .first()
    )


    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student profile not found",
        )

    return (
        db.query(StudentFee)
        .filter(
            StudentFee.student_id == student.id
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


@router.get("/my-payment-history", response_model=list[PaymentResponse])
def my_payment_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if current_user.role != "student":
        raise HTTPException(status_code=403, detail="Student access required")

    student = db.query(Student).filter(Student.user_id == current_user.id).first()
    if not student:
        raise HTTPException(status_code=404, detail="Student profile not found")

    return (
        db.query(Payment)
        .filter(Payment.student_id == student.id)
        .order_by(Payment.payment_date.desc())
        .all()
    )


@router.get(
    "/receipt/{receipt_number}/pdf",
)
def download_fee_receipt(
    receipt_number: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payment = (
        db.query(Payment)
        .filter(Payment.receipt_number == receipt_number)
        .first()
    )

    if not payment:
        raise HTTPException(status_code=404, detail="Receipt not found")

    if current_user.role == "student":
        student = db.query(Student).filter(Student.user_id == current_user.id).first()
        if not student or payment.student_id != student.id:
            raise HTTPException(status_code=403, detail="This receipt belongs to another student")
    elif current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Receipt access denied")

    student_fee = (
        db.query(StudentFee)
        .filter(StudentFee.id == payment.student_fee_id)
        .first()
    )

    if not student_fee:
        raise HTTPException(status_code=404, detail="Student fee not found")

    student = (
        db.query(Student)
        .filter(Student.id == payment.student_id)
        .first()
    )

    if not student:
        raise HTTPException(status_code=404, detail="Student not found")

    user = (
        db.query(User)
        .filter(User.id == student.user_id)
        .first()
    )

    if not user:
        raise HTTPException(status_code=404, detail="Student user not found")

    pdf_buffer = generate_fee_receipt(
        payment=payment,
        student_fee=student_fee,
        student_name=user.name,
        course=student.course,
    )

    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={
            "Content-Disposition":
                f'attachment; filename="{payment.receipt_number}.pdf"'
        },
    )
