class UserModel {
  final String token;
  final String tokenType;
  final String role;
  final int userId;
  final String name;

  UserModel({
    required this.token,
    required this.tokenType,
    required this.role,
    required this.userId,
    required this.name,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      token: json["access_token"],
      tokenType: json["token_type"],
      role: json["role"],
      userId: json["user_id"],
      name: json["name"],
    );
  }
}