from datetime import date, datetime, timezone, timedelta

# India Standard Time is UTC+5:30
IST = timezone(timedelta(hours=5, minutes=30))


def now_india() -> datetime:
    """Return the current datetime in India Standard Time."""
    return datetime.now(tz=IST)


def today_india() -> date:
    """Return today's date in India Standard Time."""
    return now_india().date()
