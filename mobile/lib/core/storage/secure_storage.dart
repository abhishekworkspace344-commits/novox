import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String tokenKey = "access_token";
  static const String roleKey = "role";
  static const String userIdKey = "user_id";
  static const String nameKey = "name";

  static Future<void> saveLoginData({
    required String token,
    required String role,
    required int userId,
    required String name,
  }) async {
    await _storage.write(
      key: tokenKey,
      value: token,
    );

    await _storage.write(
      key: roleKey,
      value: role,
    );

    await _storage.write(
      key: userIdKey,
      value: userId.toString(),
    );

    await _storage.write(
      key: nameKey,
      value: name,
    );
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: tokenKey,
    );
  }

  static Future<String?> getRole() async {
    return await _storage.read(
      key: roleKey,
    );
  }

  static Future<String?> getName() async {
    return await _storage.read(
      key: nameKey,
    );
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}

