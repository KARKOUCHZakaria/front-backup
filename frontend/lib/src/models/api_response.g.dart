// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponse<T>(
  success: json['success'] as bool,
  message: json['message'] as String?,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  error: json['error'] == null
      ? null
      : ApiError.fromJson(json['error'] as Map<String, dynamic>),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'error': instance.error,
  'metadata': instance.metadata,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
  code: json['code'] as String,
  message: json['message'] as String,
  details: json['details'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': instance.details,
};

ModelHealthStatus _$ModelHealthStatusFromJson(Map<String, dynamic> json) =>
    ModelHealthStatus(
      healthy: json['healthy'] as bool,
      modelVersion: json['model_version'] as String,
      modelType: json['model_type'] as String,
      lastTrained: json['last_trained'] == null
          ? null
          : DateTime.parse(json['last_trained'] as String),
      metrics: json['metrics'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ModelHealthStatusToJson(ModelHealthStatus instance) =>
    <String, dynamic>{
      'healthy': instance.healthy,
      'model_version': instance.modelVersion,
      'model_type': instance.modelType,
      'last_trained': instance.lastTrained?.toIso8601String(),
      'metrics': instance.metrics,
    };
