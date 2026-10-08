class AdminFeeModel {
  final int id;
  final int studentId;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;

  AdminFeeModel({
    required this.id,
    required this.studentId,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
  });

  factory AdminFeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminFeeModel(
      id: json['id'],
      studentId: json['student_id'],
      totalAmount:
          double.parse(json['total_amount'].toString()),
      paidAmount:
          double.parse(json['paid_amount'].toString()),
      pendingAmount:
          double.parse(json['pending_amount'].toString()),
      status: json['status'],
    );
  }
}