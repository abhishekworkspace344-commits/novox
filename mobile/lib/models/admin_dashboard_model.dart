class AdminDashboardModel {
  final int totalStudents;
  final int totalStaff;
  final int presentToday;
  final int lateToday;
  final int checkedOutToday;
  final int pendingFeeStudents;
  final double totalPendingAmount;

  AdminDashboardModel({
    required this.totalStudents,
    required this.totalStaff,
    required this.presentToday,
    required this.lateToday,
    required this.checkedOutToday,
    required this.pendingFeeStudents,
    required this.totalPendingAmount,
  });

  factory AdminDashboardModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminDashboardModel(
      totalStudents:
          _toInt(json['total_students']),
      totalStaff:
          _toInt(json['total_staff']),
      presentToday:
          _toInt(json['present_today']),
      lateToday:
          _toInt(json['late_today']),
      checkedOutToday:
          _toInt(json['checked_out_today']),
      pendingFeeStudents:
          _toInt(json['pending_fee_students']),
      totalPendingAmount:
          _toDouble(json['total_pending_amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_students': totalStudents,
      'total_staff': totalStaff,
      'present_today': presentToday,
      'late_today': lateToday,
      'checked_out_today': checkedOutToday,
      'pending_fee_students': pendingFeeStudents,
      'total_pending_amount': totalPendingAmount,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }
}