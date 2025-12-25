import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import '../models/user.dart';
import '../config/api_config.dart';
import 'http_service.dart';

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? error;

  AuthResult({required this.success, this.message, this.user, this.error});
}

/// Real Authentication service - calls backend API
class AuthService {
  final HttpService _httpService;
  static User? _currentUser;

  AuthService({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  /// Register a new user
  Future<AuthResult> register(
    String email,
    String fullName,
    String password,
  ) async {
    print('🔵 [AuthService] Starting registration for: $email');

    try {
      final response = await _httpService.post(ApiConfig.authRegister, {
        'email': email,
        'username': fullName,
        'password': password,
      }, includeAuth: false);

      if (_httpService.isSuccess(response)) {
        final data = _httpService.parseResponse(response);
        print('✅ [AuthService] Registration successful: $data');

        final user = User.fromJson(data);
        _currentUser = user;

        // Store token if present
        if (data['token'] != null) {
          _httpService.setAuthToken(data['token']);
        }

        return AuthResult(
          success: true,
          message: 'Registration successful',
          user: user,
        );
      } else {
        final error = _httpService.parseResponse(response);
        print('❌ [AuthService] Registration failed: ${error['message']}');
        return AuthResult(
          success: false,
          error: error['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('❌ [AuthService] Registration error: $e');
      return AuthResult(
        success: false,
        error: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Login user
  Future<AuthResult> login(String email, String password) async {
    print('🔵 [AuthService] Starting login for: $email');

    try {
      final response = await _httpService.post(ApiConfig.authLogin, {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (_httpService.isSuccess(response)) {
        final data = _httpService.parseResponse(response);
        print('✅ [AuthService] Login successful: $data');

        final user = User.fromJson(data);
        _currentUser = user;

        // Store token if present
        if (data['token'] != null) {
          _httpService.setAuthToken(data['token']);
        }

        return AuthResult(
          success: true,
          message: 'Login successful',
          user: user,
        );
      } else {
        final error = _httpService.parseResponse(response);
        print('❌ [AuthService] Login failed: ${error['message']}');
        return AuthResult(
          success: false,
          error: error['message'] ?? 'Invalid credentials',
        );
      }
    } catch (e) {
      print('❌ [AuthService] Login error: $e');
      return AuthResult(
        success: false,
        error: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Verify CIN (ID card) with photo
  Future<AuthResult> verifyCin(
    int userId,
    String cin, {
    File? photo,
    Uint8List? photoBytes,
    String? filename,
  }) async {
    print('🔵 [AuthService] Starting CIN verification for user ID: $userId');

    if (photo == null && photoBytes == null) {
      return AuthResult(
        success: false,
        error: 'Either photo file or photo bytes must be provided',
      );
    }

    try {
      // Call /auth/verify-cin endpoint with CIN photo (includes ML OCR verification)
      print(
        '📤 [AuthService] Uploading CIN photo and verifying with ML OCR...',
      );

      final response = photoBytes != null
          ? await _httpService.uploadBytes(
              ApiConfig.authVerifyCin,
              photoBytes,
              filename: filename ?? 'cin.jpg',
              fieldName: 'cinPhoto',
              additionalFields: {'userId': userId.toString(), 'cin': cin},
            )
          : await _httpService.uploadFile(
              ApiConfig.authVerifyCin,
              photo!,
              fieldName: 'cinPhoto',
              additionalFields: {'userId': userId.toString(), 'cin': cin},
            );

      if (_httpService.isSuccess(response)) {
        final data = _httpService.parseResponse(response);
        print('✅ [AuthService] CIN verification successful with ML OCR: $data');

        final userData = data['data'] ?? data;
        final user = User.fromJson(userData);
        _currentUser = user;

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Identity verified successfully',
          user: user,
        );
      } else {
        final error = _httpService.parseResponse(response);
        print('❌ [AuthService] CIN verification failed: ${error['message']}');
        return AuthResult(
          success: false,
          error: error['message'] ?? 'Verification failed',
        );
      }
    } catch (e) {
      print('❌ [AuthService] CIN verification error: $e');
      return AuthResult(
        success: false,
        error: 'Connection error: ${e.toString()}',
      );
    }
  }

  /// Update supplementary info (phone, country)
  Future<AuthResult> updateSupplementaryInfo({
    required int userId,
    required String phone,
    required String countryCode,
  }) async {
    print('🔵 [AuthService] Updating supplementary info for user ID: $userId');

    // For now, just update locally since backend doesn't have this endpoint yet
    // TODO: Create backend endpoint for updating user info

    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser = _currentUser!.copyWith(
        phone: phone,
        countryCode: countryCode,
      );

      return AuthResult(
        success: true,
        message: 'Information updated successfully',
        user: _currentUser,
      );
    }

    return AuthResult(success: false, error: 'User not found');
  }

  /// Logout user
  Future<void> logout() async {
    print('🔵 [AuthService] Logging out');
    _currentUser = null;
    _httpService.clearAuthToken();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get current user
  User? getCurrentUser() => _currentUser;

  /// Fetch current user from backend
  Future<AuthResult> fetchCurrentUser() async {
    print('🔵 [AuthService] Fetching current user from backend');

    try {
      final response = await _httpService.get(
        ApiConfig.currentUser,
        includeAuth: true,
      );

      if (_httpService.isSuccess(response)) {
        final responseData = _httpService.parseResponse(response);
        print('✅ [AuthService] Current user fetched: $responseData');

        // Extract user data from ApiResponse wrapper
        final userData = responseData['data'] ?? responseData;
        final user = User.fromJson(userData);
        _currentUser = user;

        return AuthResult(
          success: true,
          message: 'User data refreshed',
          user: user,
        );
      } else {
        final error = _httpService.parseResponse(response);
        print('❌ [AuthService] Fetch user failed: ${error['message']}');
        return AuthResult(
          success: false,
          error: error['message'] ?? 'Failed to fetch user data',
        );
      }
    } catch (e) {
      print('❌ [AuthService] Fetch user error: $e');
      return AuthResult(
        success: false,
        error: 'Connection error: ${e.toString()}',
      );
    }
  }
}
