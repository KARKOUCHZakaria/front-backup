import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model matching the backend User entity
@JsonSerializable()
class User {
  final int? id;
  final String email;
  final String username;
  final bool identityVerified;
  final String? cin;
  final String? cinPhoto;
  final String? token;
  final String? phone;
  final String? countryCode;

  User({
    this.id,
    required this.email,
    required this.username,
    this.identityVerified = false,
    this.cin,
    this.cinPhoto,
    this.token,
    this.phone,
    this.countryCode,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? email,
    String? username,
    bool? identityVerified,
    String? cin,
    String? cinPhoto,
    String? token,
    String? phone,
    String? countryCode,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      identityVerified: identityVerified ?? this.identityVerified,
      cin: cin ?? this.cin,
      cinPhoto: cinPhoto ?? this.cinPhoto,
      token: token ?? this.token,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
