import 'package:flutter/foundation.dart';
import '../../core/services/jwt_auth_service.dart';
import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';

/// Auth state controller backed by JWT authentication.
class AuthController extends ChangeNotifier {
  final JwtAuthService _authService;

  /// Creates an [AuthController] with a [JwtAuthService] instance.
  AuthController({JwtAuthService? authService})
      : _authService = authService ?? JwtAuthService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Signs in with [email] and [password] via JWT auth.
  Future<bool> signIn({
    required String email,
    required String password,
    required void Function() onSuccess,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _setError('Please fill in all fields.');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _authService.signIn(
        email: email.trim(),
        password: password,
        apiBaseUrl: AppConfig.apiBaseUrl,
      );

      if (success) {
        _setLoading(false);
        notifyListeners();
        onSuccess();
        return true;
      } else {
        _setError('Incorrect email or password.');
        return false;
      }
    } catch (e) {
      AppLogger.debug('Sign in error: $e');
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Creates a new account via JWT auth.
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required void Function() onSuccess,
  }) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      _setError('Please fill in all fields.');
      return false;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters.');
      return false;
    }

    _setLoading(true);
    try {
      final success = await _authService.signUp(
        name: fullName.trim(),
        email: email.trim(),
        password: password,
        apiBaseUrl: AppConfig.apiBaseUrl,
      );

      if (success) {
        _setLoading(false);
        notifyListeners();
        onSuccess();
        return true;
      } else {
        _setError('Failed to create account. Please try again.');
        return false;
      }
    } catch (e) {
      AppLogger.debug('Sign up error: $e');
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Sign out error: $e');
      _setError('Failed to sign out. Please try again.');
    }
  }

  /// Send password reset email (not yet implemented in JWT auth)
  /// This would be handled by backend password reset endpoint
  Future<bool> sendPasswordReset({required String email}) async {
    if (email.trim().isEmpty) {
      _setError('Please enter your email address.');
      return false;
    }
    _setLoading(true);
    try {
      // TODO: Implement password reset via backend endpoint
      // For now, just show a placeholder message
      _setLoading(false);
      _setError('Password reset functionality coming soon.');
      return false;
    } catch (e) {
      AppLogger.debug('Password reset error: $e');
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }
}
