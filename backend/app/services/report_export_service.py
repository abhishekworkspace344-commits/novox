import csv
import io

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.platypus import (
    SimpleDocTemplate,
    Table,
    TableStyle,
    Paragraph,
    Spacer,
)
from reportlab.lib.styles import getSampleStyleSheet


def create_attendance_pdf(records):
    buffer = io.BytesIO()

    document = SimpleDocTemplate(
        buffer,
        pagesize=landscape(A4),
    )

    styles = getSampleStyleSheet()

    elements = [
        Paragraph(
            "NOVOX - Attendance Report",
            styles["Title"],
        ),
        Spacer(1, 15),
    ]

    data = [[
        "Name",
        "Date",
        "Check In",
        "Checkout",
        "Status",
        "Arrival",
        "Break",
        "Work",
    ]]

    for item in records:
        data.append([
            item["user_name"],
            str(item["attendance_date"]),
            str(item["check_in"] or "-"),
            str(item["checkout"] or "-"),
            item["attendance_status"],
            item["arrival_status"],
            f'{item["total_break_minutes"]} min',
            f'{item["total_work_minutes"]} min',
        ])

    table = Table(
        data,
        repeatRows=1,
    )

    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.grey),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 8),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))

    elements.append(table)

    document.build(elements)

    buffer.seek(0)
    return buffer


def create_fee_pdf(records):
    buffer = io.BytesIO()

    document = SimpleDocTemplate(
        buffer,
        pagesize=A4,
    )

    styles = getSampleStyleSheet()

    elements = [
        Paragraph(
            "NOVOX - Fee Report",
            styles["Title"],
        ),
        Spacer(1, 15),
    ]

    data = [[
        "Student",
        "Total",
        "Paid",
        "Pending",
        "Status",
    ]]

    for item in records:
        data.append([
            item["student_name"],
            str(item["total_amount"]),
            str(item["paid_amount"]),
            str(item["pending_amount"]),
            item["status"],
        ])

    table = Table(
        data,
        repeatRows=1,
    )

    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.grey),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
    ]))

    elements.append(table)

    document.build(elements)

    buffer.seek(0)
    return buffer


def create_salary_pdf(records):
    buffer = io.BytesIO()

    document = SimpleDocTemplate(
        buffer,
        pagesize=A4,
    )

    styles = getSampleStyleSheet()

    elements = [
        Paragraph(
            "NOVOX - Salary Report",
            styles["Title"],
        ),
        Spacer(1, 15),
    ]

    data = [[
        "Staff",
        "Month",
        "Basic",
        "Allowance",
        "Deduction",
        "Net",
    ]]

    for item in records:
        data.append([
            item["staff_name"],
            f'{item["month"]}/{item["year"]}',
            str(item["basic_salary"]),
            str(item["allowance"]),
            str(item["deduction"]),
            str(item["net_salary"]),
        ])

    table = Table(
        data,
        repeatRows=1,
    )

    table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.grey),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, -1), 9),
    ]))

    elements.append(table)

    document.build(elements)

    buffer.seek(0)
    return buffer

def create_csv(headers, rows):
    output = io.StringIO()

    writer = csv.writer(output)

    writer.writerow(headers)

    for row in rows:
        writer.writerow(row)

    output.seek(0)

    return output.getvalue().encode("utf-8")

