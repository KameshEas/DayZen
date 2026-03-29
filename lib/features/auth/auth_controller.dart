import 'package:flutter/foundation.dart';

/// Minimal auth state controller using ValueNotifier.
/// Handles login, sign-up, and offline mode transitions.
class AuthController extends ChangeNotifier {
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

  /// Simulate sign-in.  Replace body with real auth logic (e.g. Supabase / Firebase).
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
    await Future.delayed(const Duration(seconds: 1)); // TODO: replace with real call
    _setLoading(false);
    onSuccess();
    return true;
  }

  /// Simulate sign-up. Replace body with real auth logic.
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
    await Future.delayed(const Duration(seconds: 1)); // TODO: replace with real call
    _setLoading(false);
    onSuccess();
    return true;
  }
}
