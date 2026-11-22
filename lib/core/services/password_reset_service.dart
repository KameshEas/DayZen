import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../security/password_policy.dart' as policy;

/// Why a password reset step failed.
enum PasswordResetFailure {
  /// No connection or the request timed out.
  offline,

  /// Wrong, expired or used-up code (the server doesn't say which, on purpose).
  invalidCode,

  /// The reset token from the code step expired or was already used.
  sessionExpired,

  /// The server refused the new password (message from the server).
  weakPassword,

  /// Rate limited (HTTP 429).
  tooManyAttempts,

  /// Anything else.
  server,
}

class PasswordResetException implements Exception {
  const PasswordResetException(this.reason, [this.serverMessage]);

  final PasswordResetFailure reason;
  final String? serverMessage;

  String get message => switch (reason) {
        PasswordResetFailure.offline =>
          "Couldn't reach DayZen. Check your connection and try again.",
        PasswordResetFailure.invalidCode =>
          "That code didn't work. Check it, or request a new one.",
        PasswordResetFailure.sessionExpired =>
          'That reset took too long. Request a new code to start again.',
        PasswordResetFailure.weakPassword =>
          serverMessage ?? 'Please choose a stronger password.',
        PasswordResetFailure.tooManyAttempts =>
          'Too many attempts. Please wait a few minutes and try again.',
        PasswordResetFailure.server =>
          'Something went wrong on our side. Please try again later.',
      };

  @override
  String toString() => 'PasswordResetException($reason)';
}

/// The three calls of DayZen's in-app password reset (all signed out):
///
/// 1. [requestCode]   POST /auth/forgot-password           emails a 6-digit code
/// 2. [verifyCode]    POST /auth/reset-password/verify-otp  code -> reset token
/// 3. [resetPassword] POST /auth/reset-password            token + new password
///
/// Step 1 succeeds whether or not the email has an account (the server never
/// reveals that). A successful reset signs the account out everywhere.
class PasswordResetService {
  PasswordResetService({http.Client? client, String? baseUrl})
      : _http = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Shortest password the server accepts (shared with sign-up).
  static const int minPasswordLength = policy.minPasswordLength;

  /// Digits in the emailed code.
  static const int codeLength = 6;

  final http.Client _http;
  final String _baseUrl;

  Future<void> requestCode(String email) async {
    await _post('/auth/forgot-password', {'email': email.trim()});
  }

  /// Returns the one-time reset token.
  Future<String> verifyCode(String email, String code) async {
    final body = await _post('/auth/reset-password/verify-otp', {
      'email': email.trim(),
      'otp': code.trim(),
    }, on400: PasswordResetFailure.invalidCode);
    final token = body['reset_token'];
    if (token is! String || token.isEmpty) {
      throw const PasswordResetException(PasswordResetFailure.server);
    }
    return token;
  }

  Future<void> resetPassword(String resetToken, String newPassword) async {
    await _post('/auth/reset-password', {
      'reset_token': resetToken,
      'new_password': newPassword,
    }, on400: PasswordResetFailure.sessionExpired);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload, {
    PasswordResetFailure on400 = PasswordResetFailure.server,
  }) async {
    final http.Response response;
    try {
      response = await _http
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: {
              'Content-Type': 'application/json',
              'X-App-ID': AppConfig.appId,
            },
            body: jsonEncode({...payload, 'app_id': AppConfig.appId}),
          )
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const PasswordResetException(PasswordResetFailure.offline);
    } catch (_) {
      throw const PasswordResetException(PasswordResetFailure.offline);
    }

    Map<String, dynamic> body = const {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {/* non-JSON error body */}

    final status = response.statusCode;
    if (status >= 200 && status < 300) return body;
    if (status == 429) {
      throw const PasswordResetException(PasswordResetFailure.tooManyAttempts);
    }
    if (status == 400) {
      final detail = body['detail'];
      // The reset step answers 400 both for an expired session and for a
      // password the server's policy refuses; only the latter names it.
      if (on400 == PasswordResetFailure.sessionExpired &&
          detail is String &&
          detail.toLowerCase().contains('password') &&
          !detail.toLowerCase().contains('reset session')) {
        throw PasswordResetException(PasswordResetFailure.weakPassword, detail);
      }
      throw PasswordResetException(on400);
    }
    throw const PasswordResetException(PasswordResetFailure.server);
  }
}
