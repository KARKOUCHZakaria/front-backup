import 'dart:async';
import 'dart:io';
import '../models/user.dart';

/// Authentication result wrapper
class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.error,
  });
}

/// Mock Authentication service - no backend API calls
/// All data is stored locally for now
class AuthService {
  // Mock user database
  static final Map<String, User> _mockUsers = {};
  static User? _currentUser;

  AuthService();

  /// Register a new user
  /// Mock implementation - stores user locally
  Future<AuthResult> register(String email, String fullName, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Check if email already exists
    if (_mockUsers.containsKey(email)) {
      return AuthResult(
        success: false,
        error: 'Email already registered',
      );
    }

    // Create new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch,
      email: email,
      username: fullName,
      identityVerified: false,
    );

    // Store user with password (in real app, this would be hashed)
    _mockUsers[email] = newUser;

    return AuthResult(
      success: true,
      message: 'Registration successful',
      user: newUser,
    );
  }

  /// Login user
  /// Mock implementation - checks local storage
  Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Demo credentials check
    if (email == 'demo@example.com' && password == 'demo123') {
      final demoUser = User(
        id: 1,
        email: email,
        username: 'Demo User',
        identityVerified: true,
        phone: '+212600000000',
      );
      _currentUser = demoUser;
      return AuthResult(
        success: true,
        message: 'Welcome back!',
        user: demoUser,
      );
    }

    // Check if user exists
    final user = _mockUsers[email];
    if (user == null) {
      return AuthResult(
        success: false,
        error: 'No account found with this email',
      );
    }

    // In real app, verify password here
    _currentUser = user;
    
    return AuthResult(
      success: true,
      message: 'Login successful',
      user: user,
    );
  }

  /// Verify CIN (ID card) with photo
  /// Mock implementation - always succeeds after delay
  Future<AuthResult> verifyCin(int userId, File photo) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Find user and update
    User? user;
    for (final entry in _mockUsers.entries) {
      if (entry.value.id == userId) {
        user = entry.value.copyWith(
          identityVerified: true,
          cinPhoto: photo.path,
        );
        _mockUsers[entry.key] = user;
        break;
      }
    }

    if (user == null && _currentUser?.id == userId) {
      user = _currentUser!.copyWith(
        identityVerified: true,
        cinPhoto: photo.path,
      );
      _currentUser = user;
    }

    if (user != null) {
      return AuthResult(
        success: true,
        message: 'Identity verified successfully',
        user: user,
      );
    }

    return AuthResult(
      success: false,
      error: 'User not found',
    );
  }

  /// Update supplementary info (phone, country)
  /// Mock implementation
  Future<AuthResult> updateSupplementaryInfo({
    required int userId,
    required String phone,
    required String countryCode,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Find and update user
    User? user;
    for (final entry in _mockUsers.entries) {
      if (entry.value.id == userId) {
        user = entry.value.copyWith(
          phone: phone,
          countryCode: countryCode,
        );
        _mockUsers[entry.key] = user;
        break;
      }
    }

    if (user == null && _currentUser?.id == userId) {
      user = _currentUser!.copyWith(
        phone: phone,
        countryCode: countryCode,
      );
      _currentUser = user;
    }

    if (user != null) {
      return AuthResult(
        success: true,
        message: 'Information updated successfully',
        user: user,
      );
    }

    return AuthResult(
      success: false,
      error: 'User not found',
    );
  }

  /// Logout user (client-side only)
  Future<void> logout() async {
    _currentUser = null;
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Get current user
  User? getCurrentUser() => _currentUser;
}

