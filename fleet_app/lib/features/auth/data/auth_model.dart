class AuthResponse {
  final String token;
  final Map<String, dynamic>? user;

  AuthResponse({required this.token, this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    if (token == null || token is! String) {
      throw ArgumentError('Token must be a non-null string');
    }
    
    return AuthResponse(
      token: token,
      user: json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null,
    );
  }
}
