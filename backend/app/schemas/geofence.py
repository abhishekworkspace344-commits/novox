from datetime import datetime

from pydantic import BaseModel, Field


class GeofenceCreate(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    radius_meters: float = Field(gt=0)


class GeofenceResponse(BaseModel):
    id: int
    latitude: float
    longitude: float
    radius_meters: float
    active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True