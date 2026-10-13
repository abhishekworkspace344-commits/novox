from datetime import date, datetime, timezone, timedelta

# India Standard Time is UTC+5:30
IST = timezone(timedelta(hours=5, minutes=30))


def elapsed_between(start: datetime, end: datetime) -> timedelta:
    """Subtract database timestamps consistently; naive DB values are stored in IST."""
    if start.tzinfo is None:
        start = start.replace(tzinfo=IST)
    else:
        start = start.astimezone(IST)
    if end.tzinfo is None:
        end = end.replace(tzinfo=IST)
    else:
        end = end.astimezone(IST)
    return end - start


def now_india() -> datetime:
    """Return the current datetime in India Standard Time."""
    return datetime.now(tz=IST)


def today_india() -> date:
    """Return today's date in India Standard Time."""
    return now_india().date()
