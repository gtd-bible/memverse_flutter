class AuthToken {
  const AuthToken({
    required this.accessToken,
    this.tokenType = 'Bearer',
    this.scope = 'user',
    this.createdAt = 0,
    this.userId,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      scope: json['scope'] as String,
      createdAt: json['created_at'] as int,
      userId: json['user_id'] as int?,
    );
  }

  final String accessToken;
  final String tokenType;
  final String scope;
  final int createdAt;
  final int? userId;

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
      'scope': scope,
      'created_at': createdAt,
      if (userId != null) 'user_id': userId,
    };
  }
}
