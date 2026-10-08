import 'package:flutter/foundation.dart';

class ApiConstants {
  // =========================================================
  // BASE URL
  // =========================================================

  static const String _configuredBaseUrl =
      String.fromEnvironment("API_BASE_URL");

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }

    // Web running on PC
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }

    // Android physical device through ADB reverse
    return "http://127.0.0.1:8000";
  }

  // =========================================================
  // AUTHENTICATION
  // =========================================================

  static const String login = "/auth/login";

  // =========================================================
  // STUDENT
  // =========================================================

  static const String studentDashboard = "/student/dashboard";
  static const String myFees = "/fees/my-fees";
  static const String myPaymentHistory =
      "/fees/my-payment-history";

  // =========================================================
  // STAFF
  // =========================================================

  static const String staffDashboard = "/staff/dashboard";
  static const String staffProfile = "/staff/profile";
  static const String staffSalary = "/salary/my-slips";

  // =========================================================
  // ADMIN
  // =========================================================

  static const String adminDashboard = "/admin/dashboard";
  static const String adminAttendance =
      "/admin/attendance/today";
  static const String adminPendingFees =
      "/admin/fees/pending";
  static const String adminStudents =
      "/admin/management/students";
  static const String adminStaff =
      "/admin/management/staff";
  static const String adminGeofence =
      "/admin/geofence";

  // =========================================================
  // ATTENDANCE
  // =========================================================

  static const String checkIn =
      "/attendance/check-in";

  static const String startBreak =
      "/attendance/break/start";

  static const String endBreak =
      "/attendance/break/end";

  static const String checkout =
      "/attendance/checkout";

  static const String attendanceHistory =
      "/attendance/history";

  // =========================================================
  // FEES
  // =========================================================

  static const String feeStructure =
      "/fees/structure";

  static const String studentFee =
      "/fees/student";

  static const String feePayment =
      "/fees/payment";

  static const String pendingFees =
      "/fees/pending";

  static const String feeStudent =
      "/fees/student";

  static const String feeReceipt =
      "/fees/receipt";

  static String feeReceiptPdf(String receiptNumber) {
    return "/fees/receipt/$receiptNumber/pdf";
  }

  // =========================================================
  // SALARY
  // =========================================================

  static const String salaryStructure =
      "/salary/structure";

  static const String salaryStaff =
      "/salary/staff";

  static const String generateSalarySlip =
      "/salary/slip";

  // =========================================================
  // REPORTS
  // =========================================================

  static const String reportsSummary =
      "/admin/reports/summary";

  static const String attendanceReport =
      "/admin/reports/attendance";

  static const String lateEntryReport =
      "/admin/reports/late-entry";

  static const String feeReport =
      "/admin/reports/fees";

  static const String salaryReport =
      "/admin/reports/salary";

  // =========================================================
  // REPORT EXPORTS
  // =========================================================

  static const String attendancePdfExport =
      "/admin/reports/export/attendance/pdf";

  static const String attendanceCsvExport =
      "/admin/reports/export/attendance/csv";

  static const String feePdfExport =
      "/admin/reports/export/fees/pdf";

  static const String salaryPdfExport =
      "/admin/reports/export/salary/pdf";
}