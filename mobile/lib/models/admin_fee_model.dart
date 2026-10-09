class AdminFeeModel {
  final int id;
  final int studentId;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String status;
  final String studentName;
  final String studentCode;
  final String course;

  AdminFeeModel({
    required this.id,
    required this.studentId,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.status,
    this.studentName = '',
    this.studentCode = '',
    this.course = '',
  });

  factory AdminFeeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminFeeModel(
      id: int.parse(json['id'].toString()),
      studentId: int.parse(json['student_id'].toString()),
      totalAmount:
          double.parse(json['total_amount'].toString()),
      paidAmount:
          double.parse(json['paid_amount'].toString()),
      pendingAmount:
          double.parse(json['pending_amount'].toString()),
      status: json['status'],
      studentName: (json['student_name'] ?? '').toString(),
      studentCode: (json['student_code'] ?? '').toString(),
      course: (json['course'] ?? '').toString(),
    );
  }
}
