from datetime import datetime

from pydantic import BaseModel, Field, model_validator


class GeofenceCreate(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    radius_meters: float = Field(gt=0)
    active: bool = True
    south: float | None = Field(default=None, ge=-90, le=90)
    north: float | None = Field(default=None, ge=-90, le=90)
    west: float | None = Field(default=None, ge=-180, le=180)
    east: float | None = Field(default=None, ge=-180, le=180)

    @model_validator(mode="after")
    def validate_bounds(self):
        bounds = (self.south, self.north, self.west, self.east)
        if any(value is not None for value in bounds) and any(value is None for value in bounds):
            raise ValueError("Provide all four bounds: south, north, west, and east")
        if self.south is not None and self.south >= self.north:
            raise ValueError("South must be less than north")
        if self.west is not None and self.west >= self.east:
            raise ValueError("West must be less than east")
        return self


class GeofenceResponse(BaseModel):
    id: int
    latitude: float
    longitude: float
    radius_meters: float
    active: bool
    south: float | None = None
    north: float | None = None
    west: float | None = None
    east: float | None = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
