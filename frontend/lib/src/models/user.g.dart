// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  identityVerified: json['identityVerified'] as bool? ?? false,
  cin: json['cin'] as String?,
  cinPhoto: json['cinPhoto'] as String?,
  token: json['token'] as String?,
  phone: json['phone'] as String?,
  countryCode: json['countryCode'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'identityVerified': instance.identityVerified,
  'cin': instance.cin,
  'cinPhoto': instance.cinPhoto,
  'token': instance.token,
  'phone': instance.phone,
  'countryCode': instance.countryCode,
};
