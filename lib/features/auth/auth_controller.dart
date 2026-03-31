import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Auth state controller backed by Firebase Authentication.
class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  /// Signs in with [email] and [password] via Firebase Auth.
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
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _setLoading(false);
      onSuccess();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyMessage(e.code));
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Creates a new account via Firebase Auth.
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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(fullName.trim());
      _setLoading(false);
      onSuccess();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyMessage(e.code));
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  /// Sends a password-reset email to [email].
  Future<bool> sendPasswordReset({required String email}) async {
    if (email.trim().isEmpty) {
      _setError('Please enter your email address.');
      return false;
    }
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyMessage(e.code));
      return false;
    } catch (_) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

