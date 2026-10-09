class StudentAdminModel {
  final int id;
  final int? userId;

  final String name;
  final String email;
  final String? phone;

  final String studentCode;
  final String course;
  final String? batch;

  final String? joiningDate;
  final String? guardianName;
  final String? guardianPhone;
  final double totalFees;

  final bool isActive;

  StudentAdminModel({
    required this.id,
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.studentCode,
    required this.course,
    this.batch,
    this.joiningDate,
    this.guardianName,
    this.guardianPhone,
    this.totalFees = 0,
    required this.isActive,
  });

  factory StudentAdminModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentAdminModel(
      id: _toInt(json['id']),
      userId: json['user_id'] == null
          ? null
          : _toInt(json['user_id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      studentCode:
          (json['student_code'] ?? '').toString(),
      course:
          (json['course'] ?? '').toString(),
      batch:
          json['batch']?.toString(),
      joiningDate:
          json['joining_date']?.toString(),
      guardianName:
          json['guardian_name']?.toString(),
      guardianPhone:
          json['guardian_phone']?.toString(),
      totalFees: _toDouble(json['total_fees']),
      isActive:
          json['is_active'] == null
              ? true
              : json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'student_code': studentCode,
      'course': course,
      'batch': batch,
      'joining_date': joiningDate,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'total_fees': totalFees,
      'is_active': isActive,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
