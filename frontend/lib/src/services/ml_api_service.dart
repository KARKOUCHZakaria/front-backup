import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/credit_application_data.dart';
import '../models/prediction_result.dart';
import '../models/api_response.dart';

/// Service for communicating with the ML Backend API
class MLApiService {
  late final Dio _dio;

  MLApiService({Dio? dio}) {
    _dio = dio ?? _createDio();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.mlUrl,  // Use ML API URL
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add logging interceptor in debug mode
    if (ApiConfig.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    return dio;
  }

  /// Predict credit score for a given application
  Future<PredictionResult> predict(CreditApplicationData application) async {
    try {
      final response = await _dio.post(
        ApiConfig.predict,
        data: application.toJson(),
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Prediction failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get SHAP explanation for a prediction
  Future<Map<String, double>> explainShap(
    CreditApplicationData application,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.explainShap,
        data: application.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Convert to Map<String, double>
          return data.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }
        return {};
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'SHAP explanation failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get fairness metrics for a specific demographic group
  Future<FairnessMetrics> getFairnessMetrics({
    String protectedAttribute = 'CODE_GENDER',
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.fairnessMetrics,
        queryParameters: {'protected_attribute': protectedAttribute},
      );

      if (response.statusCode == 200) {
        return FairnessMetrics.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Fairness metrics failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check model health status
  Future<ModelHealthStatus> checkModelHealth() async {
    try {
      final response = await _dio.get(ApiConfig.modelHealth);

      if (response.statusCode == 200) {
        return ModelHealthStatus.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Health check failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      final response = await _dio.get(ApiConfig.modelInfo);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Model info failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get feature importance from the model
  Future<Map<String, double>> getFeatureImportance() async {
    try {
      final response = await _dio.get(ApiConfig.featureImportance);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }
        return {};
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Feature importance failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Batch predict for multiple applications
  Future<List<PredictionResult>> batchPredict(
    List<CreditApplicationData> applications,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.batchPredict,
        data: {
          'applications': applications.map((app) => app.toJson()).toList(),
        },
      );

      if (response.statusCode == 200) {
        final results = response.data as List;
        return results
            .map((result) => PredictionResult.fromJson(result))
            .toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Batch predict failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';
        return Exception('Server error ($statusCode): $message');
      
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      
      case DioExceptionType.connectionError:
        return Exception(
          'Connection failed. Please check if the backend server is running.',
        );
      
      default:
        return Exception('Unexpected error: ${error.message}');
    }
  }
}
