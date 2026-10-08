from sqlalchemy.orm import Session

from app.models.geofence import GeofenceSettings


def get_active_geofence(db: Session):

    return (
        db.query(GeofenceSettings)
        .filter(
            GeofenceSettings.active == True
        )
        .order_by(
            GeofenceSettings.id.desc()
        )
        .first()
    )


def create_geofence(
    db: Session,
    latitude: float,
    longitude: float,
    radius_meters: float,
):

    # Disable existing geofences
    db.query(GeofenceSettings).update(
        {
            GeofenceSettings.active: False
        }
    )

    geofence = GeofenceSettings(
        latitude=latitude,
        longitude=longitude,
        radius_meters=radius_meters,
        active=True,
    )

    db.add(geofence)
    db.commit()
    db.refresh(geofence)

    return geofence


def update_geofence(
    db: Session,
    geofence_id: int,
    latitude: float,
    longitude: float,
    radius_meters: float,
):

    geofence = (
        db.query(GeofenceSettings)
        .filter(
            GeofenceSettings.id == geofence_id
        )
        .first()
    )

    if not geofence:
        raise ValueError(
            "Geofence not found"
        )

    geofence.latitude = latitude
    geofence.longitude = longitude
    geofence.radius_meters = radius_meters

    db.commit()
    db.refresh(geofence)

    return geofence