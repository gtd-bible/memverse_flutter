import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token.freezed.dart';
part 'auth_token.g.dart'; // For json_serializable

@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required String scope,
    @JsonKey(name: 'created_at') required int createdAt,
    @JsonKey(name: 'user_id') int? userId,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenFromJson(json);
}