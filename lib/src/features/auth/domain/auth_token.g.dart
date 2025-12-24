// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthTokenImpl _$$AuthTokenImplFromJson(Map<String, dynamic> json) =>
    _$AuthTokenImpl(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      scope: json['scope'] as String,
      createdAt: (json['created_at'] as num).toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AuthTokenImplToJson(_$AuthTokenImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'scope': instance.scope,
      'created_at': instance.createdAt,
      'user_id': instance.userId,
    };
