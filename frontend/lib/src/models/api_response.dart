import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

/// Generic API response wrapper
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final ApiError? error;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
    this.metadata,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseToJson(this, toJsonT);
}

/// API error details
@JsonSerializable()
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);
}

/// Model health status
@JsonSerializable()
class ModelHealthStatus {
  final bool healthy;
  @JsonKey(name: 'model_version')
  final String modelVersion;
  @JsonKey(name: 'model_type')
  final String modelType;
  @JsonKey(name: 'last_trained')
  final DateTime? lastTrained;
  final Map<String, dynamic>? metrics;

  ModelHealthStatus({
    required this.healthy,
    required this.modelVersion,
    required this.modelType,
    this.lastTrained,
    this.metrics,
  });

  factory ModelHealthStatus.fromJson(Map<String, dynamic> json) =>
      _$ModelHealthStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ModelHealthStatusToJson(this);
}
