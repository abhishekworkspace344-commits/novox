from datetime import date, datetime

from pydantic import BaseModel, Field


class AttendanceHistoryItem(BaseModel):
    id: int
    attendance_date: date
    check_in: datetime | None
    checkout: datetime | None
    attendance_status: str
    arrival_status: str
    total_break_minutes: int
    total_work_minutes: int | None
    active_break: bool = False
    current_break_start: datetime | None = None


class AttendanceHistoryResponse(BaseModel):
    success: bool
    total_records: int
    records: list[AttendanceHistoryItem]


class CheckInRequest(BaseModel):
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)


class CheckInResponse(BaseModel):
    success: bool
    message: str
    attendance_id: int | None = None
    attendance_status: str | None = None
    arrival_status: str | None = None
    check_in: datetime | None = None
    distance_meters: float | None = None


class BreakResponse(BaseModel):
    success: bool
    message: str
    break_id: int | None = None
    start_time: datetime | None = None
    end_time: datetime | None = None
    duration_minutes: int | None = None


class CheckoutRequest(BaseModel):
    latitude: float | None = Field(
        default=None,
        ge=-90,
        le=90,
    )

    longitude: float | None = Field(
        default=None,
        ge=-180,
        le=180,
    )


class CheckoutResponse(BaseModel):
    success: bool
    message: str
    checkout: datetime | None = None
    total_break_minutes: int | None = None
    total_work_minutes: int | None = None
