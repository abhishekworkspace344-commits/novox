import math

from sqlalchemy.orm import Session

from app.models.geofence import GeofenceSettings


def calculate_distance(
    latitude1: float,
    longitude1: float,
    latitude2: float,
    longitude2: float,
) -> float:

    earth_radius = 6371000

    lat1 = math.radians(latitude1)
    lat2 = math.radians(latitude2)

    delta_lat = math.radians(latitude2 - latitude1)
    delta_lon = math.radians(longitude2 - longitude1)

    a = (
        math.sin(delta_lat / 2) ** 2
        + math.cos(lat1)
        * math.cos(lat2)
        * math.sin(delta_lon / 2) ** 2
    )

    c = 2 * math.atan2(
        math.sqrt(a),
        math.sqrt(1 - a),
    )

    return earth_radius * c


def validate_geofence(
    db: Session,
    latitude: float,
    longitude: float,
):

    settings = (
        db.query(GeofenceSettings)
        .filter(
            GeofenceSettings.active == True
        )
        .first()
    )

    if not settings:
        return {
            "valid": False,
            "reason": "Geofence is not configured",
            "distance": None,
        }

    distance = calculate_distance(
        latitude,
        longitude,
        settings.latitude,
        settings.longitude,
    )

    inside = distance <= settings.radius_meters

    return {
        "valid": inside,
        "reason": (
            "Inside Campus"
            if inside
            else "Out of Campus"
        ),
        "distance": round(distance, 2),
    }