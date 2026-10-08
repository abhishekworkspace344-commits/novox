import 'package:dio/dio.dart';

class ApiError {
  static String message(Object error) {
    if (error is! DioException) {
      final message =
          error.toString().replaceFirst('Exception: ', '').trim();
      return message.isEmpty
          ? 'Something went wrong. Please try again.'
          : message;
    }

    final status = error.response?.statusCode;
    final body = error.response?.data;
    final detail = body is Map ? body['detail']?.toString() : null;

    if (status == 401) {
      return detail ?? 'Email or password is incorrect. Please try again.';
    }
    if (status == 403) {
      return detail ?? 'You do not have permission to do this.';
    }
    if (status == 404) {
      return detail ?? 'This feature is not available on the connected server.';
    }
    if (status != null && status >= 500) {
      return detail ?? 'The server could not complete this request. Please try again later.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Could not reach NOVOX. Check your connection and server address.';
    }
    return detail ?? 'The request could not be completed. Please try again.';
  }
}
