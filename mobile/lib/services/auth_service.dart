import 'package:dio/dio.dart';

import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  // =========================================================
  // LOGIN
  // =========================================================

  Future<UserModel> login(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          "email": email.trim(),
          "password": password,
        },
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        throw Exception(
          "Invalid login response received from server.",
        );
      }

      final user = UserModel.fromJson(data);

      if (user.token.isEmpty) {
        throw Exception(
          "Login succeeded but no authentication token was returned.",
        );
      }

      await SecureStorage.saveLoginData(
        token: user.token,
        role: user.role,
        userId: user.userId,
        name: user.name,
      );

      return user;
    } on DioException catch (e) {
      // =====================================================
      // BACKEND / NETWORK ERROR
      // =====================================================

      if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          "Cannot connect to NOVOX server. "
          "Make sure FastAPI is running.",
        );
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          "Connection to NOVOX server timed out.",
        );
      }

      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          "NOVOX server took too long to respond.",
        );
      }

      // =====================================================
      // HTTP ERROR FROM BACKEND
      // =====================================================

      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        String message = "Login failed.";

        if (responseData is Map<String, dynamic>) {
          final detail = responseData["detail"];

          if (detail != null) {
            message = detail.toString();
          } else if (responseData["message"] != null) {
            message = responseData["message"].toString();
          }
        }

        throw Exception(
          "Login failed ($statusCode): $message",
        );
      }

      throw Exception(
        "Unable to login. Please check your internet/network connection.",
      );
    } catch (e) {
      throw Exception(
        "Login failed: ${e.toString()}",
      );
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}