class AttendanceModel {
  final int id;
  final String attendanceDate;
  final String? checkIn;
  final String? checkout;
  final String attendanceStatus;
  final String arrivalStatus;
  final double? checkInDistance;
  final int totalBreakMinutes;
  final int? totalWorkMinutes;
  final bool activeBreak;

  AttendanceModel({
    required this.id,
    required this.attendanceDate,
    this.checkIn,
    this.checkout,
    required this.attendanceStatus,
    required this.arrivalStatus,
    this.checkInDistance,
    required this.totalBreakMinutes,
    this.totalWorkMinutes,
    this.activeBreak = false,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json["id"],
      attendanceDate: json["attendance_date"],
      checkIn: json["check_in"],
      checkout: json["checkout"],
      attendanceStatus: json["attendance_status"],
      arrivalStatus: json["arrival_status"],
      checkInDistance: json["check_in_distance"] != null
          ? double.parse(json["check_in_distance"].toString())
          : null,
      totalBreakMinutes: json["total_break_minutes"] ?? 0,
      totalWorkMinutes: json["total_work_minutes"],
      activeBreak: json["active_break"] == true,
    );
  }
}
