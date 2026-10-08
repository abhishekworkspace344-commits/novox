from fastapi import APIRouter, Depends

from app.core.dependencies import require_role


router = APIRouter(
    prefix="/student",
    tags=["Student"],
)


@router.get("/dashboard")
def student_dashboard(
    current_user=Depends(
        require_role("student")
    ),
):
    return {
        "message": "Student dashboard",
        "user_id": current_user.id,
        "name": current_user.name,
        "role": current_user.role,
    }


@router.get("/profile")
def student_profile(
    current_user=Depends(
        require_role("student")
    ),
):
    return {
        "user_id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "phone": current_user.phone,
        "role": current_user.role,
    }