/// Firebase authentication service for managing ID tokens.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../logging/app_logger.dart';

/// Service for managing Firebase authentication tokens and headers.
class AuthService extends ChangeNotifier {
  AuthService._() {
    _firebaseAuth = FirebaseAuth.instance;
    _setupAuthStateListener();
  }

  static final AuthService _instance = AuthService._();

  static AuthService get instance => _instance;

  late final FirebaseAuth _firebaseAuth;
  User? _currentUser;
  String? _cachedIdToken;
  DateTime? _tokenExpiryTime;

  /// Get the currently authenticated user
  User? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Get user UID
  String? get userId => _currentUser?.uid;

  /// Get user email
  String? get userEmail => _currentUser?.email;

  /// Initialize auth state listener
  void _setupAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((user) {
      _currentUser = user;
      _cachedIdToken = null;
      _tokenExpiryTime = null;
      notifyListeners();
    });
  }

  /// Get Firebase ID token for API authentication
  /// Returns cached token if still valid, otherwise fetches fresh token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      if (_currentUser == null) {
        return null;
      }

      // Check if cached token is still valid (with 5 minute buffer)
      if (!forceRefresh &&
          _cachedIdToken != null &&
          _tokenExpiryTime != null &&
          DateTime.now().isBefore(_tokenExpiryTime!.subtract(
            const Duration(minutes: 5),
          ))) {
        return _cachedIdToken;
      }

      // Get fresh token
      final tokenResult = await _currentUser?.getIdToken();

      if (tokenResult != null) {
        _cachedIdToken = tokenResult;
        // Set expiry time (tokens are typically valid for 1 hour)
        _tokenExpiryTime = DateTime.now().add(const Duration(hours: 1));
      }

      return tokenResult;
    } catch (e) {
      AppLogger.debug('Error getting ID token: $e');
      return null;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      AppLogger.debug('Sign in error: $e');
      rethrow;
    }
  }

  /// Sign up with email and password
  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      AppLogger.debug('Sign up error: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _cachedIdToken = null;
      _tokenExpiryTime = null;
      await _firebaseAuth.signOut();
    } catch (e) {
      AppLogger.debug('Sign out error: $e');
      rethrow;
    }
  }

  /// Clear cached token (useful when token refresh is needed)
  void clearCachedToken() {
    _cachedIdToken = null;
    _tokenExpiryTime = null;
  }

  /// Get authentication headers for API requests
  /// This should be called for every API request
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getIdToken();

    if (token == null) {
      return {};
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Verify if token is still valid (for debugging/diagnostics)
  bool get isTokenValid {
    if (_tokenExpiryTime == null) {
      return false;
    }

    return DateTime.now().isBefore(_tokenExpiryTime!);
  }

  /// Get token expiry time (for debugging)
  DateTime? get tokenExpiryTime => _tokenExpiryTime;
}


