from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.models.payment import Payment
from app.core.dependencies import (
    get_current_user,
    get_db,
    require_role,
)
from app.models.user import User
from app.models.student import Student
from app.models.fee import FeeStructure, StudentFee

from app.schemas.fee import (
    FeeStructureCreate,
    FeeStructureResponse,
    FeeStructureUpdate,
    StudentFeeCreate,
    StudentFeeResponse,
    StudentFeeUpdate,
    StudentFeeAdminResponse,
    PaymentCreate,
    PaymentResponse,
)

from app.services.fee_service import (
    create_fee_structure,
    update_fee_structure,
    assign_student_fee,
    create_payment,
    update_student_fee,
)

from app.services.pdf_service import generate_fee_receipt


router = APIRouter(
    prefix="/fees",
    tags=["Fees"],
)


# ============================================================
# ADMIN — GET ALL FEE STRUCTURES
# ============================================================

@router.get(
    "/structure",
    response_model=list[FeeStructureResponse],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def get_fee_structures(
    db: Session = Depends(get_db),
):
    return (
        db.query(FeeStructure)
        .order_by(
            FeeStructure.created_at.desc()
        )
        .all()
    )


# ============================================================
# ADMIN — CREATE FEE STRUCTURE
# ============================================================

@router.post(
    "/structure",
    response_model=FeeStructureResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
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


# ============================================================
# ADMIN — EDIT FEE STRUCTURE
# ============================================================

@router.put(
    "/structure/{structure_id}",
    response_model=FeeStructureResponse,
    dependencies=[Depends(require_role("admin"))],
)
def edit_structure(
    structure_id: int,
    data: FeeStructureUpdate,
    db: Session = Depends(get_db),
):
    try:
        return update_fee_structure(
            db=db,
            structure_id=structure_id,
            course=data.course,
            fee_type=data.fee_type,
            total_amount=data.total_amount,
            description=data.description,
        )
    except ValueError as error:
        raise HTTPException(status_code=404, detail=str(error))


# ============================================================
# ADMIN — ASSIGN FEE TO STUDENT
# ============================================================

@router.post(
    "/student",
    response_model=StudentFeeResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
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


# ============================================================
# ADMIN — EDIT STUDENT FEE
# ============================================================

@router.put(
    "/student/{student_fee_id}",
    response_model=StudentFeeResponse,
    dependencies=[Depends(require_role("admin"))],
)
def edit_student_fee(
    student_fee_id: int,
    data: StudentFeeUpdate,
    db: Session = Depends(get_db),
):
    student_fee = db.query(StudentFee).filter(
        StudentFee.id == student_fee_id
    ).first()
    if not student_fee:
        raise HTTPException(status_code=404, detail="Student fee record not found")
    try:
        return update_student_fee(db, student_fee, data.total_amount)
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error))


# ============================================================
# ADMIN — ALL STUDENT FEE RECORDS
# ============================================================

@router.get(
    "/admin/all",
    response_model=list[StudentFeeAdminResponse],
    dependencies=[Depends(require_role("admin"))],
)
def all_student_fees(db: Session = Depends(get_db)):
    rows = (
        db.query(StudentFee, Student, User)
        .join(Student, Student.id == StudentFee.student_id)
        .join(User, User.id == Student.user_id)
        .order_by(StudentFee.created_at.desc())
        .all()
    )
    return [
        {
            "id": fee.id,
            "student_id": fee.student_id,
            "fee_structure_id": fee.fee_structure_id,
            "total_amount": fee.total_amount,
            "paid_amount": fee.paid_amount,
            "pending_amount": fee.pending_amount,
            "status": fee.status,
            "created_at": fee.created_at,
            "student_name": user.name,
            "student_code": student.student_code,
            "course": student.course,
        }
        for fee, student, user in rows
    ]


# ============================================================
# ADMIN — RECORD PAYMENT
# ============================================================

@router.post(
    "/payment",
    response_model=PaymentResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def record_payment(
    data: PaymentCreate,
    db: Session = Depends(get_db),
):
    student_fee = (
        db.query(StudentFee)
        .filter(
            StudentFee.id
            == data.student_fee_id
        )
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


# ============================================================
# ADMIN — PENDING FEES
# ============================================================

@router.get(
    "/pending",
    response_model=list[StudentFeeResponse],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def pending_fees(
    db: Session = Depends(get_db),
):
    return (
        db.query(StudentFee)
        .filter(
            StudentFee.status != "PAID"
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


# ============================================================
# ADMIN — STUDENT FEE DETAILS
# ============================================================

@router.get(
    "/student/{student_id}",
    response_model=list[StudentFeeResponse],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def student_fee_details(
    student_id: int,
    db: Session = Depends(get_db),
):
    return (
        db.query(StudentFee)
        .filter(
            StudentFee.student_id
            == student_id
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


# ============================================================
# ADMIN — PAYMENT HISTORY
# ============================================================

@router.get(
    "/payments/{student_fee_id}",
    response_model=list[PaymentResponse],
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def payment_history(
    student_fee_id: int,
    db: Session = Depends(get_db),
):
    payments = (
        db.query(Payment)
        .filter(
            Payment.student_fee_id
            == student_fee_id
        )
        .order_by(
            Payment.payment_date.desc()
        )
        .all()
    )

    return payments


# ============================================================
# ADMIN — GET RECEIPT
# ============================================================

@router.get(
    "/receipt/{receipt_number}",
    response_model=PaymentResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def get_receipt(
    receipt_number: str,
    db: Session = Depends(get_db),
):
    payment = (
        db.query(Payment)
        .filter(
            Payment.receipt_number
            == receipt_number
        )
        .first()
    )

    if not payment:
        raise HTTPException(
            status_code=404,
            detail="Receipt not found",
        )

    return payment


# ============================================================
# STUDENT — MY FEES
# ============================================================

@router.get(
    "/my-fees",
)
def my_fees(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    if current_user.role != "student":
        raise HTTPException(
            status_code=403,
            detail="Student access required",
        )

    student = (
        db.query(Student)
        .filter(
            Student.user_id
            == current_user.id
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
            StudentFee.student_id
            == student.id
        )
        .order_by(
            StudentFee.created_at.desc()
        )
        .all()
    )


# ============================================================
# STUDENT — MY PAYMENT HISTORY
# ============================================================

@router.get(
    "/my-payment-history",
    response_model=list[PaymentResponse],
)
def my_payment_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    if current_user.role != "student":
        raise HTTPException(
            status_code=403,
            detail="Student access required",
        )

    student = (
        db.query(Student)
        .filter(
            Student.user_id
            == current_user.id
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student profile not found",
        )

    return (
        db.query(Payment)
        .filter(
            Payment.student_id
            == student.id
        )
        .order_by(
            Payment.payment_date.desc()
        )
        .all()
    )


# ============================================================
# RECEIPT PDF
# ============================================================

@router.get(
    "/receipt/{receipt_number}/pdf",
)
def download_fee_receipt(
    receipt_number: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(
        get_current_user
    ),
):
    payment = (
        db.query(Payment)
        .filter(
            Payment.receipt_number
            == receipt_number
        )
        .first()
    )

    if not payment:
        raise HTTPException(
            status_code=404,
            detail="Receipt not found",
        )

    # --------------------------------------------------------
    # STUDENT CAN ONLY ACCESS OWN RECEIPT
    # --------------------------------------------------------

    if current_user.role == "student":

        student = (
            db.query(Student)
            .filter(
                Student.user_id
                == current_user.id
            )
            .first()
        )

        if (
            not student
            or payment.student_id
            != student.id
        ):
            raise HTTPException(
                status_code=403,
                detail=(
                    "This receipt belongs "
                    "to another student"
                ),
            )

    # --------------------------------------------------------
    # ONLY ADMIN OR STUDENT
    # --------------------------------------------------------

    elif current_user.role != "admin":

        raise HTTPException(
            status_code=403,
            detail="Receipt access denied",
        )

    # --------------------------------------------------------
    # STUDENT FEE
    # --------------------------------------------------------

    student_fee = (
        db.query(StudentFee)
        .filter(
            StudentFee.id
            == payment.student_fee_id
        )
        .first()
    )

    if not student_fee:
        raise HTTPException(
            status_code=404,
            detail="Student fee not found",
        )

    # --------------------------------------------------------
    # STUDENT
    # --------------------------------------------------------

    student = (
        db.query(Student)
        .filter(
            Student.id
            == payment.student_id
        )
        .first()
    )

    if not student:
        raise HTTPException(
            status_code=404,
            detail="Student not found",
        )

    # --------------------------------------------------------
    # USER
    # --------------------------------------------------------

    user = (
        db.query(User)
        .filter(
            User.id
            == student.user_id
        )
        .first()
    )

    if not user:
        raise HTTPException(
            status_code=404,
            detail="Student user not found",
        )

    # --------------------------------------------------------
    # GENERATE PDF
    # --------------------------------------------------------

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
                (
                    f'attachment; '
                    f'filename="'
                    f'{payment.receipt_number}.pdf"'
                )
        },
    )
