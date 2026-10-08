import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';

class ReportService {
  final ApiClient apiClient;

  ReportService(this.apiClient);

  // ============================================================
  // SUMMARY
  // ============================================================

  Future<Map<String, dynamic>> getSummary() async {
    final response = await apiClient.dio.get(
      ApiConstants.reportsSummary,
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // ============================================================
  // ATTENDANCE REPORT
  // ============================================================

  Future<List<dynamic>> getAttendanceReport({
    String? startDate,
    String? endDate,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.attendanceReport,
      queryParameters: {
        'start_date': ?startDate,
        'end_date': ?endDate,
      },
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return List<dynamic>.from(data);
  }

  // ============================================================
  // LATE ENTRY REPORT
  // ============================================================

  Future<List<dynamic>> getLateEntryReport({
    String? startDate,
    String? endDate,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.lateEntryReport,
      queryParameters: {
        'start_date': ?startDate,
        'end_date': ?endDate,
      },
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return List<dynamic>.from(data);
  }

  // ============================================================
  // FEE REPORT
  // ============================================================

  Future<List<dynamic>> getFeeReport() async {
    final response = await apiClient.dio.get(
      ApiConstants.feeReport,
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return List<dynamic>.from(data);
  }

  // ============================================================
  // SALARY REPORT
  // ============================================================

  Future<List<dynamic>> getSalaryReport({
    int? month,
    int? year,
  }) async {
    final response = await apiClient.dio.get(
      ApiConstants.salaryReport,
      queryParameters: {
        'month': ?month,
        'year': ?year,
      },
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return List<dynamic>.from(data);
  }

  // ============================================================
  // DOWNLOAD ATTENDANCE PDF
  // ============================================================

  Future<List<int>> downloadAttendancePdf({
    String? startDate,
    String? endDate,
  }) async {
    final response =
        await apiClient.dio.get<List<int>>(
      ApiConstants.attendancePdfExport,
      queryParameters: {
        'start_date': ?startDate,
        'end_date': ?endDate,
      },
      options: Options(
        responseType:
            ResponseType.bytes,
      ),
    );

    return response.data ?? [];
  }

  // ============================================================
  // DOWNLOAD ATTENDANCE CSV
  // ============================================================

  Future<List<int>> downloadAttendanceCsv({
    String? startDate,
    String? endDate,
  }) async {
    final response =
        await apiClient.dio.get<List<int>>(
      ApiConstants.attendanceCsvExport,
      queryParameters: {
        'start_date': ?startDate,
        'end_date': ?endDate,
      },
      options: Options(
        responseType:
            ResponseType.bytes,
      ),
    );

    return response.data ?? [];
  }

  // ============================================================
  // DOWNLOAD FEE PDF
  // ============================================================

  Future<List<int>> downloadFeePdf() async {
    final response =
        await apiClient.dio.get<List<int>>(
      ApiConstants.feePdfExport,
      options: Options(
        responseType:
            ResponseType.bytes,
      ),
    );

    return response.data ?? [];
  }

  // ============================================================
  // DOWNLOAD SALARY PDF
  // ============================================================

  Future<List<int>> downloadSalaryPdf({
    int? month,
    int? year,
  }) async {
    final response =
        await apiClient.dio.get<List<int>>(
      ApiConstants.salaryPdfExport,
      queryParameters: {
        'month': ?month,
        'year': ?year,
      },
      options: Options(
        responseType:
            ResponseType.bytes,
      ),
    );

    return response.data ?? [];
  }
}