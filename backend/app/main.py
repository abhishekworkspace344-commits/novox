from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text, inspect
from app.routes.websocket import router as websocket_router

from app.core.config import settings
from app.database.base import Base
from app.database.connection import engine
# Register every mapped model (including salary tables) before create_all.
import app.models  # noqa: F401
from app.models.user import User
from app.routes.auth import router as auth_router

from app.models.student import Student
from app.models.staff import Staff

from app.routes.student import router as student_router
from app.routes.staff import router as staff_router
from app.routes.admin import router as admin_router

from app.models.geofence import GeofenceSettings
from app.models.attendance import Attendance
from app.models.attendance_break import AttendanceBreak
from app.routes.attendance import router as attendance_router
from app.models.fee import FeeStructure, StudentFee
from app.models.payment import Payment
from app.routes.fees import router as fees_router
from app.routes.salary import router as salary_router
from app.routes.admin_management import router as admin_management_router
from app.routes.geofence_admin import router as geofence_admin_router
from app.routes.reports import router as reports_router
from app.routes.report_exports import (
    router as report_exports_router,
)



Base.metadata.create_all(bind=engine)

# create_all does not add columns to an existing installation.
with engine.begin() as connection:
    existing_columns = {column["name"] for column in inspect(connection).get_columns("geofence_settings")}
    for column_name in ("south", "north", "west", "east"):
        if column_name not in existing_columns:
            connection.execute(text(f"ALTER TABLE geofence_settings ADD COLUMN {column_name} FLOAT NULL"))




app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=settings.CORS_ALLOW_ORIGIN_REGEX,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router)
app.include_router(student_router)
app.include_router(staff_router)
app.include_router(attendance_router)
app.include_router(admin_router)
app.include_router(fees_router)
app.include_router(salary_router)
app.include_router(admin_management_router)
app.include_router(geofence_admin_router)
app.include_router(reports_router)

app.include_router(
    websocket_router
)

app.include_router(
    report_exports_router
)


@app.get("/")
def root():
    return {
        "application": "NOVOX",
        "status": "running",
        "version": "1.0.0",
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/database-test")
def database_test():

    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        return {
            "status": "success",
            "database": "MySQL connected",
        }

    except Exception as error:
        return {
            "status": "error",
            "message": str(error),
        }
