class FeeReceiptModel {
  final String receiptNumber;
  final int studentId;
  final int studentFeeId;
  final double amount;
  final String paymentMethod;
  final String? transactionId;
  final String paymentDate;

  FeeReceiptModel({
    required this.receiptNumber,
    required this.studentId,
    required this.studentFeeId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentDate,
  });

  factory FeeReceiptModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FeeReceiptModel(
      receiptNumber: json['receipt_number'],
      studentId: json['student_id'],
      studentFeeId: json['student_fee_id'],
      amount:
          double.parse(json['amount'].toString()),
      paymentMethod:
          json['payment_method'],
      transactionId:
          json['transaction_id'],
      paymentDate:
          json['payment_date'],
    );
  }
}