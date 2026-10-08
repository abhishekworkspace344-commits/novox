class StaffModel {
  final int id;
  final int? userId;
  final String name;
  final String email;
  final String? phone;
  final String employeeCode;
  final String designation;
  final String? department;
  final String? joiningDate;
  final bool isActive;

  StaffModel({
    required this.id,
    this.userId,
    required this.name,
    required this.email,
    this.phone,
    required this.employeeCode,
    required this.designation,
    this.department,
    this.joiningDate,
    required this.isActive,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: _toInt(json['id']),
      userId: json['user_id'] == null ? null : _toInt(json['user_id']),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      employeeCode: (json['employee_code'] ?? '').toString(),
      designation: (json['designation'] ?? '').toString(),
      department: json['department']?.toString(),
      joiningDate: json['joining_date']?.toString(),
      isActive: json['is_active'] == null
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
      'employee_code': employeeCode,
      'designation': designation,
      'department': department,
      'joining_date': joiningDate,
      'is_active': isActive,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}