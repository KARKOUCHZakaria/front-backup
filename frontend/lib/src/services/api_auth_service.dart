import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;
  final String? error;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.token,
    this.error,
  });
}

/// Real Authentication service with Backend API
class ApiAuthService {
  late final Dio _dio;
  String? _authToken;

  ApiAuthService({Dio? dio}) {
    _dio = dio ?? _createDio();
  }

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Add logging interceptor
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  /// Register a new user
  Future<AuthResult> register(String email, String fullName, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.authRegister,
        data: {
          'email': email,
          'username': fullName,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Extract user data from response
        final user = User(
          id: data['id'] ?? 0,
          email: data['email'] ?? email,
          username: data['username'] ?? fullName,
          identityVerified: data['identityVerified'] ?? false,
        );

        // Store token if provided
        if (data['token'] != null) {
          _authToken = data['token'];
        }

        return AuthResult(
          success: true,
          message: 'Registration successful',
          user: user,
          token: _authToken,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Registration failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Registration failed: $e',
      );
    }
  }

  /// Login user
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Extract user data and token
        final user = User(
          id: data['id'] ?? 0,
          email: data['email'] ?? email,
          username: data['username'] ?? data['name'] ?? 'User',
          identityVerified: data['identityVerified'] ?? false,
          phone: data['phone'],
        );

        _authToken = data['token'];

        return AuthResult(
          success: true,
          message: 'Login successful',
          user: user,
          token: _authToken,
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Login failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Login failed: $e',
      );
    }
  }

  /// Verify CIN with image
  Future<AuthResult> verifyCIN(String cin, String cinImagePath) async {
    try {
      final formData = FormData.fromMap({
        'cin': cin,
        'cinImage': await MultipartFile.fromFile(
          cinImagePath,
          filename: 'cin.jpg',
        ),
      });

      final response = await _dio.post(
        ApiConfig.authVerifyCin,
        data: formData,
        options: Options(
          headers: _authToken != null
              ? ApiConfig.authHeaders(_authToken!)
              : ApiConfig.defaultHeaders,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        return AuthResult(
          success: data['verified'] ?? false,
          message: data['message'] ?? 'Verification completed',
        );
      } else {
        return AuthResult(
          success: false,
          error: 'Verification failed: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        error: _handleDioError(e),
      );
    } catch (e) {
      return AuthResult(
        success: false,
        error: 'Verification failed: $e',
      );
    }
  }

  /// Logout - clear token
  Future<void> logout() async {
    _authToken = null;
  }

  /// Get current auth token
  String? get token => _authToken;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  /// Handle Dio errors
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 
                       e.response?.data?['error'] ??
                       'Request failed';
        return 'Error $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Please check if backend is running.';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
