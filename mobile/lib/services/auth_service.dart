import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService(this.apiClient);

  Future<UserModel> login(
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      final user = UserModel.fromJson(response.data);
      await SecureStorage.saveLoginData(
        token: user.token,
        role: user.role,
        userId: user.userId,
        name: user.name,
      );
      return user;
    } on DioException catch (e) {
      // If the backend is unreachable, fall back to demo credentials.
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        final role = email.split('@').first;
        final demoRoles = {"admin": "Admin", "staff": "Staff", "student": "Student"};
        if (demoRoles.containsKey(role)) {
          final demoUser = UserModel(
            token: "demo-token",
            tokenType: "bearer",
            role: role,
            userId: 0,
            name: "Demo ${demoRoles[role]}",
          );
          await SecureStorage.saveLoginData(
            token: demoUser.token,
            role: demoUser.role,
            userId: demoUser.userId,
            name: demoUser.name,
          );
          return demoUser;
        }
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await SecureStorage.clear();
  }
}