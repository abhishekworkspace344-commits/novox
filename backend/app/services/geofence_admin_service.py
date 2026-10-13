from sqlalchemy.orm import Session

from app.models.geofence import GeofenceSettings


def get_active_geofence(db: Session):

    return (
        db.query(GeofenceSettings)
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
    active: bool = True,
    south: float | None = None, north: float | None = None,
    west: float | None = None, east: float | None = None,
):

    geofence = GeofenceSettings(
        latitude=latitude,
        longitude=longitude,
        radius_meters=radius_meters,
        active=active,
        south=south, north=north, west=west, east=east,
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
    active: bool = True,
    south: float | None = None, north: float | None = None,
    west: float | None = None, east: float | None = None,
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
    geofence.active = active
    geofence.south, geofence.north = south, north
    geofence.west, geofence.east = west, east

    db.commit()
    db.refresh(geofence)

    return geofence
