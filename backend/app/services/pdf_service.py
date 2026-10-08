from io import BytesIO

from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas


def generate_fee_receipt(
    payment,
    student_fee,
    student_name: str,
    course: str,
):
    buffer = BytesIO()

    pdf = canvas.Canvas(buffer, pagesize=A4)

    width, height = A4

    pdf.setFont("Helvetica-Bold", 22)
    pdf.drawCentredString(width / 2, height - 60, "NOVOX")

    pdf.setFont("Helvetica", 11)
    pdf.drawCentredString(
        width / 2,
        height - 80,
        "EDUCATION MANAGEMENT SYSTEM",
    )

    pdf.line(50, height - 95, width - 50, height - 95)

    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawString(50, height - 130, "FEE RECEIPT")

    y = height - 175

    pdf.setFont("Helvetica", 11)

    pdf.drawString(50, y, f"Receipt No: {payment.receipt_number}")
    y -= 25

    pdf.drawString(50, y, f"Student: {student_name}")
    y -= 25

    pdf.drawString(50, y, f"Course: {course}")
    y -= 25

    pdf.drawString(
        50,
        y,
        f"Payment Date: {payment.payment_date.strftime('%d/%m/%Y %H:%M')}",
    )
    y -= 45

    pdf.setFont("Helvetica-Bold", 12)
    pdf.drawString(50, y, "Payment Details")
    y -= 30

    pdf.setFont("Helvetica", 11)

    pdf.drawString(50, y, f"Total Fee: Rs. {student_fee.total_amount:.2f}")
    y -= 25

    pdf.drawString(50, y, f"Amount Paid: Rs. {payment.amount:.2f}")
    y -= 25

    pdf.drawString(50, y, f"Payment Method: {payment.payment_method}")
    y -= 25

    if payment.transaction_id:
        pdf.drawString(50, y, f"Transaction ID: {payment.transaction_id}")
        y -= 25

    y -= 10
    pdf.drawString(50, y, f"Pending Amount: Rs. {student_fee.pending_amount:.2f}")
    y -= 25
    pdf.drawString(50, y, f"Fee Status: {student_fee.status}")

    y -= 60
    pdf.setFont("Helvetica", 10)
    pdf.drawString(50, y, "This is a digitally generated fee receipt.")

    pdf.save()

    buffer.seek(0)
    return buffer


def generate_salary_slip(
    salary_slip,
    staff_name: str,
    employee_code: str,
    designation: str,
):
    buffer = BytesIO()

    pdf = canvas.Canvas(buffer, pagesize=A4)

    width, height = A4

    pdf.setFont("Helvetica-Bold", 22)
    pdf.drawCentredString(width / 2, height - 60, "NOVOX")

    pdf.setFont("Helvetica", 11)
    pdf.drawCentredString(
        width / 2,
        height - 80,
        "EDUCATION MANAGEMENT SYSTEM",
    )

    pdf.line(50, height - 95, width - 50, height - 95)

    pdf.setFont("Helvetica-Bold", 16)
    pdf.drawString(50, height - 130, "SALARY SLIP")

    y = height - 175

    pdf.setFont("Helvetica", 11)

    pdf.drawString(50, y, f"Staff: {staff_name}")
    y -= 25

    pdf.drawString(50, y, f"Employee Code: {employee_code}")
    y -= 25

    pdf.drawString(50, y, f"Designation: {designation}")
    y -= 25

    pdf.drawString(
        50,
        y,
        f"Salary Period: {salary_slip.month}/{salary_slip.year}",
    )
    y -= 45

    pdf.setFont("Helvetica-Bold", 12)
    pdf.drawString(50, y, "Salary Breakdown")
    y -= 30

    pdf.setFont("Helvetica", 11)

    pdf.drawString(50, y, f"Basic Salary: Rs. {salary_slip.basic_salary:.2f}")
    y -= 25

    pdf.drawString(50, y, f"Allowance: Rs. {salary_slip.allowance:.2f}")
    y -= 25

    pdf.drawString(50, y, f"Deduction: Rs. {salary_slip.deduction:.2f}")
    y -= 35

    pdf.setFont("Helvetica-Bold", 13)
    pdf.drawString(50, y, f"Net Salary: Rs. {salary_slip.net_salary:.2f}")
    y -= 35

    pdf.drawString(50, y, f"Status: {salary_slip.status}")

    y -= 60
    pdf.setFont("Helvetica", 10)
    pdf.drawString(50, y, "This is a digitally generated salary slip.")

    pdf.save()

    buffer.seek(0)
    return buffer