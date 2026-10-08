from fastapi import APIRouter, Depends

from app.core.dependencies import require_role


router = APIRouter(
    prefix="/staff",
    tags=["Staff"],
)


@router.get("/dashboard")
def staff_dashboard(
    current_user=Depends(
        require_role("staff")
    ),
):
    return {
        "message": "Staff dashboard",
        "user_id": current_user.id,
        "name": current_user.name,
        "role": current_user.role,
    }


@router.get("/profile")
def staff_profile(
    current_user=Depends(
        require_role("staff")
    ),
):
    return {
        "user_id": current_user.id,
        "name": current_user.name,
        "email": current_user.email,
        "phone": current_user.phone,
        "role": current_user.role,
    }