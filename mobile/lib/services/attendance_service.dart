import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final ApiClient apiClient;

  AttendanceService(this.apiClient);

  List<dynamic> _recordsFromResponse(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic> && data["records"] is List) {
      return data["records"] as List<dynamic>;
    }

    throw const FormatException(
      "Invalid attendance history response from server",
    );
  }

  AttendanceModel _attendanceFromJson(dynamic data) {
    if (data is! Map<String, dynamic>) {
      throw const FormatException("Invalid attendance record from server");
    }

    return AttendanceModel.fromJson(data);
  }

  // ------------------------------------------------------------
  // CHECK IN
  // ------------------------------------------------------------

  Future<AttendanceModel> checkIn({
    required double latitude,
    required double longitude,
  }) async {
    final response = await apiClient.dio.post(
      ApiConstants.checkIn,
      data: {"latitude": latitude, "longitude": longitude},
    );

    final data = response.data;

    // Backend may return:
    // {
    //   "success": true,
    //   "message": "...",
    //   "attendance": {...},
    //   "distance": 12.5
    // }
    //
    // Extract the actual attendance object when available.

    if (data is Map<String, dynamic>) {
      if (data["success"] == false) {
        throw Exception(data["message"] ?? "Check-in was not accepted");
      }

      final attendanceData = data["attendance"];

      if (attendanceData is Map<String, dynamic>) {
        return AttendanceModel.fromJson(attendanceData);
      }

      // The API's check-in response is a summary, not a full history record.
      return AttendanceModel(
        id: data["attendance_id"] ?? data["id"] ?? 0,
        attendanceDate: (data["check_in"] ?? DateTime.now().toIso8601String())
            .toString()
            .split("T")
            .first,
        checkIn: data["check_in"]?.toString(),
        attendanceStatus: data["attendance_status"] ?? "PRESENT",
        arrivalStatus: data["arrival_status"] ?? "ON_TIME",
        checkInDistance: data["distance_meters"] == null
            ? null
            : double.tryParse(data["distance_meters"].toString()),
        totalBreakMinutes: 0,
        activeBreak: false,
      );
    }

    throw Exception("Invalid check-in response from server");
  }

  // ------------------------------------------------------------
  // START BREAK
  // ------------------------------------------------------------

  Future<void> startBreak() async {
    await apiClient.dio.post(ApiConstants.startBreak);
  }

  // ------------------------------------------------------------
  // END BREAK
  // ------------------------------------------------------------

  Future<void> endBreak() async {
    await apiClient.dio.post(ApiConstants.endBreak);
  }

  // ------------------------------------------------------------
  // CHECKOUT
  // ------------------------------------------------------------

  Future<void> checkout({
    required double latitude,
    required double longitude,
  }) async {
    await apiClient.dio.post(
      ApiConstants.checkout,
      data: {"latitude": latitude, "longitude": longitude},
    );
  }

  // ------------------------------------------------------------
  // TODAY'S ATTENDANCE
  // ------------------------------------------------------------

  Future<AttendanceModel?> getToday() async {
    final response = await apiClient.dio.get(ApiConstants.attendanceHistory);

    final records = _recordsFromResponse(response.data);
    if (records.isEmpty) {
      return null;
    }

    // Backend returns newest records first.
    return _attendanceFromJson(records.first);
  }

  // ------------------------------------------------------------
  // ATTENDANCE HISTORY
  // ------------------------------------------------------------

  Future<List<AttendanceModel>> getHistory({int? month, int? year}) async {
    final Map<String, dynamic> queryParameters = {};

    if (month != null) {
      queryParameters["month"] = month;
    }

    if (year != null) {
      queryParameters["year"] = year;
    }

    final response = await apiClient.dio.get(
      ApiConstants.attendanceHistory,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );

    return _recordsFromResponse(
      response.data,
    ).map(_attendanceFromJson).toList();
  }
}
