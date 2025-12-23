import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

/// Auth state that holds the current user and authentication status
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool needsVerification;
  final bool needsSupplementaryInfo;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.needsVerification = false,
    this.needsSupplementaryInfo = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? needsVerification,
    bool? needsSupplementaryInfo,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      needsVerification: needsVerification ?? this.needsVerification,
      needsSupplementaryInfo: needsSupplementaryInfo ?? this.needsSupplementaryInfo,
    );
  }
}

/// Auth notifier that handles authentication logic
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  /// Register a new user
  Future<bool> register(String email, String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.register(email, username, password);

    if (result.success && result.user != null) {
      state = AuthState(
        user: result.user,
        isAuthenticated: false, // Not fully authenticated until CIN verified
        needsVerification: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }

  /// Login user
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.login(email, password);

    if (result.success && result.user != null) {
      final user = result.user!;
      
      if (user.identityVerified) {
        // Fully authenticated
        state = AuthState(
          user: user,
          isAuthenticated: true,
          needsVerification: false,
          isLoading: false,
        );
      } else {
        // Need to verify CIN
        state = AuthState(
          user: user,
          isAuthenticated: false,
          needsVerification: true,
          isLoading: false,
        );
      }
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }

  /// Verify CIN with photo
  Future<bool> verifyCin(File photo) async {
    if (state.user?.id == null) {
      state = state.copyWith(error: 'No user logged in');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.verifyCin(state.user!.id!, photo);

    if (result.success && result.user != null) {
      // Update user with verification info
      final updatedUser = state.user!.copyWith(
        identityVerified: true,
        cinPhoto: result.user!.cinPhoto,
        token: result.user!.token,
      );

      state = AuthState(
        user: updatedUser,
        isAuthenticated: false, // Not fully authenticated until supplementary info added
        needsVerification: false,
        needsSupplementaryInfo: true,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }

  /// Update supplementary info (phone, country)
  Future<bool> updateSupplementaryInfo({
    required String phone,
    required String countryCode,
  }) async {
    if (state.user?.id == null) {
      state = state.copyWith(error: 'No user logged in');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _authService.updateSupplementaryInfo(
      userId: state.user!.id!,
      phone: phone,
      countryCode: countryCode,
    );

    if (result.success && result.user != null) {
      final updatedUser = state.user!.copyWith(
        phone: result.user!.phone,
        countryCode: result.user!.countryCode,
      );

      state = AuthState(
        user: updatedUser,
        isAuthenticated: true,
        needsVerification: false,
        needsSupplementaryInfo: false,
        isLoading: false,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
      );
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

/// Convenience providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final needsVerificationProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).needsVerification;
});

final needsSupplementaryInfoProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).needsSupplementaryInfo;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});
