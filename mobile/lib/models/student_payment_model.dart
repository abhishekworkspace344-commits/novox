class StudentPaymentModel {
  final int id;
  final int studentFeeId;
  final int studentId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String paymentDate;
  final String? receiptNumber;

  StudentPaymentModel({
    required this.id,
    required this.studentFeeId,
    required this.studentId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentDate,
    this.receiptNumber,
  });

  factory StudentPaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentPaymentModel(
      id: json['id'],
      studentFeeId: json['student_fee_id'],
      studentId: json['student_id'],
      amount: double.parse(
        json['amount'].toString(),
      ),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      paymentDate: json['payment_date'],
      receiptNumber: json['receipt_number'],
    );
  }
}