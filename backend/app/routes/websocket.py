from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.websocket_manager import manager
from app.database.connection import SessionLocal
from app.models.user import User

router = APIRouter()


@router.websocket("/ws/admin")
async def admin_websocket(
    websocket: WebSocket,
):
    token = websocket.query_params.get("token")

    if not token:
        await websocket.close(code=1008)
        return

    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )

        user_id = payload.get("sub")
        role = payload.get("role")

        if not user_id or role != "admin":
            await websocket.close(code=1008)
            return

    except JWTError:
        await websocket.close(code=1008)
        return

    db: Session = SessionLocal()

    try:
        user = (
            db.query(User)
            .filter(User.id == int(user_id))
            .first()
        )

        if not user or not user.is_active:
            await websocket.close(code=1008)
            return

        await manager.connect(websocket)

        while True:
            await websocket.receive_text()

    except WebSocketDisconnect:
        manager.disconnect(websocket)

    except Exception:
        manager.disconnect(websocket)

    finally:
        db.close()