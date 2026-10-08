from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.dependencies import (
    get_db,
    require_role,
)

from app.schemas.geofence import (
    GeofenceCreate,
    GeofenceResponse,
)

from app.services.geofence_admin_service import (
    get_active_geofence,
    create_geofence,
    update_geofence,
)


router = APIRouter(
    prefix="/admin/geofence",
    tags=["Geofence Management"],
)


# ==========================================
# VIEW CURRENT GEOFENCE
# ==========================================

@router.get(
    "",
    response_model=GeofenceResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def current_geofence(
    db: Session = Depends(get_db),
):

    geofence = get_active_geofence(db)

    if not geofence:
        raise HTTPException(
            status_code=404,
            detail="No active geofence configured",
        )

    return geofence


# ==========================================
# CREATE / SET GEOFENCE
# ==========================================

@router.post(
    "",
    response_model=GeofenceResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def set_geofence(
    data: GeofenceCreate,
    db: Session = Depends(get_db),
):

    return create_geofence(
        db=db,
        latitude=data.latitude,
        longitude=data.longitude,
        radius_meters=data.radius_meters,
    )


# ==========================================
# UPDATE GEOFENCE
# ==========================================

@router.put(
    "/{geofence_id}",
    response_model=GeofenceResponse,
    dependencies=[
        Depends(require_role("admin"))
    ],
)
def edit_geofence(
    geofence_id: int,
    data: GeofenceCreate,
    db: Session = Depends(get_db),
):

    try:

        return update_geofence(
            db=db,
            geofence_id=geofence_id,
            latitude=data.latitude,
            longitude=data.longitude,
            radius_meters=data.radius_meters,
        )

    except ValueError as e:

        raise HTTPException(
            status_code=404,
            detail=str(e),
        )