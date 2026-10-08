class StaffAdminModel {
  final int id;
  final int userId;
  final String employeeCode;
  final String designation;
  final String? department;
  final String? joiningDate;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;

  StaffAdminModel({
    required this.id,
    required this.userId,
    required this.employeeCode,
    required this.designation,
    this.department,
    this.joiningDate,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
  });

  factory StaffAdminModel.fromJson(Map<String, dynamic> json) {
    return StaffAdminModel(
      id: json['id'],
      userId: json['user_id'],
      employeeCode: json['employee_code'],
      designation: json['designation'],
      department: json['department'],
      joiningDate: json['joining_date'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      isActive: json['is_active'] ?? true,
    );
  }
}