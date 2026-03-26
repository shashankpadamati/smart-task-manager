class AuthUser {
  final String token;
  final int id;
  final String username;

  AuthUser({required this.token, required this.id, required this.username});

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      token: json['token'] ?? '',
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
    );
  }
}
