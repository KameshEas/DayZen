/// JWT-based authentication service for managing tokens and auth state.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../logging/app_logger.dart';
import '../config/app_config.dart';
import 'package:http/http.dart' as http;

/// JWT token model
class JwtToken {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  JwtToken({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isExpiringSoon => expiresAt != null && DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt!);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  factory JwtToken.fromJson(Map<String, dynamic> json) => JwtToken(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
  );
}

/// User model
class AuthUser {
  final String id;
  final String email;
  final String? name;

  AuthUser({
    required this.id,
    required this.email,
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String?,
  );
}

/// Service for managing JWT authentication tokens and auth state.
class JwtAuthService extends ChangeNotifier {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'auth_user';
  static const String _refreshTokenKey = 'jwt_refresh_token';

  late SharedPreferences _prefs;
  JwtToken? _currentToken;
  AuthUser? _currentUser;
  bool _initialized = false;

  /// Get the currently authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null && _currentToken != null && !_currentToken!.isExpired;

  /// Get user ID
  String? get userId => _currentUser?.id;

  /// Get user email
  String? get userEmail => _currentUser?.email;

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Initialize the auth service and restore previous session if available
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Try to restore previous session
      final tokenJson = _prefs.getString(_tokenKey);
      final userJson = _prefs.getString(_userKey);

      if (tokenJson != null && userJson != null) {
        try {
          _currentToken = JwtToken.fromJson(jsonDecode(tokenJson));
          _currentUser = AuthUser.fromJson(jsonDecode(userJson));

          // Check if token needs refresh
          if (_currentToken != null && _currentToken!.isExpiringSoon) {
            await _refreshToken();
          }
        } catch (e) {
          AppLogger.debug('Error restoring session: $e');
          await _clearSession();
        }
      }

      _initialized = true;
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Error initializing JwtAuthService: $e');
      _initialized = true;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  /// Returns true on success, false on failure
  Future<bool> signIn({
    required String email,
    required String password,
    required String apiBaseUrl,
  }) async {
    try {
      final url = Uri.parse('$apiBaseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Parse token response (adjust field names based on your API)
        final tokenData = data['data'] ?? data;
        _currentToken = JwtToken(
          accessToken: tokenData['access_token'] as String? ?? tokenData['accessToken'] as String,
          refreshToken: tokenData['refresh_token'] as String? ?? tokenData['refreshToken'] as String?,
          expiresAt: _parseTokenExpiry(tokenData['access_token'] as String? ?? tokenData['accessToken'] as String),
        );

        // Parse user data
        _currentUser = AuthUser(
          id: tokenData['user_id'] as String? ?? tokenData['userId'] as String,
          email: tokenData['email'] as String? ?? email.trim(),
          name: tokenData['name'] as String? ?? tokenData['full_name'] as String?,
        );

        await _saveSession();
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        AppLogger.debug('Invalid credentials');
        return false;
      } else {
        AppLogger.debug('Sign in failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.debug('Sign in error: $e');
      return false;
    }
  }

  /// Sign up with email and password
  /// Returns true on success, false on failure
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String apiBaseUrl,
  }) async {
    try {
      final url = Uri.parse('$apiBaseUrl/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Parse token response
        final tokenData = data['data'] ?? data;
        _currentToken = JwtToken(
          accessToken: tokenData['access_token'] as String? ?? tokenData['accessToken'] as String,
          refreshToken: tokenData['refresh_token'] as String? ?? tokenData['refreshToken'] as String?,
          expiresAt: _parseTokenExpiry(tokenData['access_token'] as String? ?? tokenData['accessToken'] as String),
        );

        // Parse user data
        _currentUser = AuthUser(
          id: tokenData['user_id'] as String? ?? tokenData['userId'] as String,
          email: email.trim(),
          name: name.trim(),
        );

        await _saveSession();
        notifyListeners();
        return true;
      } else {
        AppLogger.debug('Sign up failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.debug('Sign up error: $e');
      return false;
    }
  }

  /// Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      if (_currentToken?.refreshToken == null) {
        await _clearSession();
        notifyListeners();
        return false;
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': _currentToken!.refreshToken,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenData = data['data'] ?? data;

        _currentToken = JwtToken(
          accessToken: tokenData['access_token'] as String? ?? tokenData['accessToken'] as String,
          refreshToken: tokenData['refresh_token'] as String? ?? _currentToken!.refreshToken,
          expiresAt: _parseTokenExpiry(tokenData['access_token'] as String? ?? tokenData['accessToken'] as String),
        );

        await _saveSession();
        return true;
      } else {
        await _clearSession();
        notifyListeners();
        return false;
      }
    } catch (e) {
      AppLogger.debug('Token refresh error: $e');
      await _clearSession();
      notifyListeners();
      return false;
    }
  }

  /// Get valid access token, refreshing if necessary
  Future<String?> getAccessToken() async {
    if (_currentToken == null) {
      return null;
    }

    if (_currentToken!.isExpiringSoon) {
      await _refreshToken();
    }

    return _currentToken?.accessToken;
  }

  /// Get authentication headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();

    if (token == null) {
      return {};
    }

    return {
      'Authorization': 'Bearer $token',
    };
  }

  /// Sign out and clear session
  Future<void> signOut() async {
    try {
      await _clearSession();
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Sign out error: $e');
    }
  }

  /// Save session to persistent storage
  Future<void> _saveSession() async {
    try {
      if (!_initialized) {
        _prefs = await SharedPreferences.getInstance();
      }
      if (_currentToken != null) {
        await _prefs.setString(_tokenKey, jsonEncode(_currentToken!.toJson()));
      }
      if (_currentUser != null) {
        await _prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
      }
    } catch (e) {
      AppLogger.debug('Error saving session: $e');
    }
  }

  /// Clear session from persistent storage
  Future<void> _clearSession() async {
    try {
      _currentToken = null;
      _currentUser = null;
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userKey);
      await _prefs.remove(_refreshTokenKey);
    } catch (e) {
      AppLogger.debug('Error clearing session: $e');
    }
  }

  /// Parse expiry time from JWT token
  /// JWT tokens have exp claim in payload (2nd part)
  DateTime? _parseTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Decode payload (add padding if necessary)
      var payload = parts[1];
      final padding = (4 - payload.length % 4) % 4;
      payload += '=' * padding;

      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;

      if (json.containsKey('exp')) {
        final expiration = DateTime.fromMillisecondsSinceEpoch(
          (json['exp'] as int) * 1000,
        );
        return expiration;
      }
    } catch (e) {
      AppLogger.debug('Error parsing token expiry: $e');
    }
    return null;
  }
}
