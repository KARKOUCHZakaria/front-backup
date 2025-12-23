import 'package:json_annotation/json_annotation.dart';

part 'auth_request.g.dart';

/// Auth request model matching the backend AuthRequest payload
@JsonSerializable()
class AuthRequest {
  final String email;
  final String? username;
  final String password;

  AuthRequest({
    required this.email,
    this.username,
    required this.password,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}
