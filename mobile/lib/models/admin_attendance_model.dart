class AdminAttendanceModel {
  final int attendanceId;
  final int userId;
  final String attendanceDate;
  final String? checkIn;
  final String? checkout;
  final String attendanceStatus;
  final String arrivalStatus;
  final double? checkInDistance;

  AdminAttendanceModel({
    required this.attendanceId,
    required this.userId,
    required this.attendanceDate,
    this.checkIn,
    this.checkout,
    required this.attendanceStatus,
    required this.arrivalStatus,
    this.checkInDistance,
  });

  factory AdminAttendanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminAttendanceModel(
      attendanceId: json["attendance_id"],
      userId: json["user_id"],
      attendanceDate: json["attendance_date"],
      checkIn: json["check_in"],
      checkout: json["checkout"],
      attendanceStatus:
          json["attendance_status"],
      arrivalStatus:
          json["arrival_status"],
      checkInDistance:
          json["check_in_distance"] != null
              ? double.parse(
                  json["check_in_distance"]
                      .toString(),
                )
              : null,
    );
  }
}

