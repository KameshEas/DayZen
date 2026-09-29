/// OAuth 2.1 + PKCE client for the DayZen AI assistant's MCP token.
///
/// Unlike the app's own sign-in (JwtAuthService), this is a *second*,
/// separate token: an MCP-scoped access/refresh token pair the auth service
/// issues to the "DayZen Mobile Chat Panel" OAuth client so the n8n chatbot
/// workflow can call dayzen-mcp-server on the user's behalf, scoped to
/// exactly that client and exactly this user. The PKCE code_verifier never
/// leaves the device and the resulting token is never the same as the
/// user's normal DayZen session token.
///
/// There is no browser redirect in this in-app flow: POST /oauth/authorize
/// is a JSON API the app itself calls once the user taps "Connect" in the
/// consent step (see lib/features/ai_assistant/), using the user's existing
/// DayZen session as proof of identity - it returns the authorization code
/// directly instead of redirecting a user-agent.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../logging/app_logger.dart';
import 'jwt_auth_service.dart';

class McpToken {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  McpToken({required this.accessToken, required this.refreshToken, required this.expiresAt});

  bool get isExpiringSoon => DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory McpToken.fromJson(Map<String, dynamic> json) => McpToken(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}

/// Thrown for any step of the connect/refresh flow that fails.
class McpAuthException implements Exception {
  final String message;
  McpAuthException(this.message);

  @override
  String toString() => message;
}

class McpAuthService extends ChangeNotifier {
  static final McpAuthService instance = McpAuthService();

  static const String _tokenKey = 'mcp_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
  );
  final http.Client _client = http.Client();

  McpToken? _token;
  bool _restored = false;

  /// Whether a previous [connect] succeeded and its token is still stored
  /// (it may still need a transparent refresh - see [getValidToken]).
  Future<bool> get isConnected async {
    await _restoreIfNeeded();
    return _token != null;
  }

  Future<void> _restoreIfNeeded() async {
    if (_restored) return;
    _restored = true;
    try {
      final json = await _secureStorage.read(key: _tokenKey);
      if (json != null) {
        _token = McpToken.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (e) {
      AppLogger.debug('Error restoring MCP token: $e');
    }
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(64, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  String _codeChallengeFor(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Runs the full authorize -> token exchange, using the user's existing
  /// DayZen session to approve the chatbot client. Throws [McpAuthException]
  /// with a message suitable to show the user on any failure.
  Future<void> connect() async {
    if (AppConfig.mcpOauthClientId.isEmpty) {
      throw McpAuthException('The AI assistant is not configured yet. Please try again later.');
    }

    final dayzenAuthHeaders = await JwtAuthService.instance.getAuthHeaders();
    if (dayzenAuthHeaders.isEmpty) {
      throw McpAuthException('Please sign in to DayZen before connecting the AI assistant.');
    }

    final verifier = _generateCodeVerifier();
    final challenge = _codeChallengeFor(verifier);
    final state = _generateCodeVerifier();

    final String code;
    try {
      final authorizeResp = await _client
          .post(
            Uri.parse('${AppConfig.authBaseUrl}/oauth/authorize'),
            headers: {'Content-Type': 'application/json', ...dayzenAuthHeaders},
            body: jsonEncode({
              'client_id': AppConfig.mcpOauthClientId,
              'scope': AppConfig.mcpOauthScope,
              'redirect_uri': AppConfig.mcpOauthRedirectUri,
              'code_challenge': challenge,
              'code_challenge_method': 'S256',
              'state': state,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (authorizeResp.statusCode != 200) {
        throw McpAuthException('Could not connect the AI assistant (${authorizeResp.statusCode}).');
      }
      code = (jsonDecode(authorizeResp.body) as Map<String, dynamic>)['code'] as String;
    } on TimeoutException {
      throw McpAuthException('Connecting the AI assistant timed out. Please try again.');
    } on McpAuthException {
      rethrow;
    } catch (e) {
      AppLogger.debug('MCP authorize error: $e');
      throw McpAuthException('Could not connect the AI assistant. Please try again.');
    }

    await _exchangeCode(code: code, verifier: verifier);
  }

  Future<void> _exchangeCode({required String code, required String verifier}) async {
    try {
      final tokenResp = await _client
          .post(
            Uri.parse('${AppConfig.authBaseUrl}/oauth/token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'grant_type': 'authorization_code',
              'code': code,
              'redirect_uri': AppConfig.mcpOauthRedirectUri,
              'code_verifier': verifier,
              'client_id': AppConfig.mcpOauthClientId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (tokenResp.statusCode != 200) {
        throw McpAuthException('Could not finish connecting the AI assistant.');
      }
      await _storeTokenResponse(jsonDecode(tokenResp.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw McpAuthException('Connecting the AI assistant timed out. Please try again.');
    } on McpAuthException {
      rethrow;
    } catch (e) {
      AppLogger.debug('MCP token exchange error: $e');
      throw McpAuthException('Could not finish connecting the AI assistant.');
    }
  }

  Future<void> _storeTokenResponse(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;
    final expiresIn = (data['expires_in'] as num?)?.toInt() ?? 900;

    _token = McpToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    );
    try {
      await _secureStorage.write(key: _tokenKey, value: jsonEncode(_token!.toJson()));
    } catch (e) {
      AppLogger.debug('Error saving MCP token: $e');
    }
    notifyListeners();
  }

  /// Returns a currently-valid MCP access token, refreshing it first if it's
  /// expiring soon. Returns null if [connect] was never completed or the
  /// refresh token was revoked - callers should show the consent step again.
  Future<String?> getValidToken() async {
    await _restoreIfNeeded();
    if (_token == null) return null;

    if (_token!.isExpiringSoon) {
      final refreshed = await _refresh();
      if (!refreshed) return null;
    }
    return _token?.accessToken;
  }

  Future<bool> _refresh() async {
    if (_token == null) return false;
    try {
      final resp = await _client
          .post(
            Uri.parse('${AppConfig.authBaseUrl}/oauth/token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'grant_type': 'refresh_token',
              'refresh_token': _token!.refreshToken,
              'client_id': AppConfig.mcpOauthClientId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode != 200) {
        // Refresh token revoked/expired - the user must reconnect.
        await disconnect();
        return false;
      }
      await _storeTokenResponse(jsonDecode(resp.body) as Map<String, dynamic>);
      return true;
    } catch (e) {
      // Network error/timeout - keep the existing (soon-to-expire) token
      // rather than disconnecting; the next attempt can retry.
      AppLogger.debug('MCP token refresh error: $e');
      return false;
    }
  }

  /// Revokes the refresh token and clears local storage.
  Future<void> disconnect() async {
    final token = _token;
    _token = null;
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      AppLogger.debug('Error clearing MCP token: $e');
    }
    notifyListeners();

    if (token == null || AppConfig.mcpOauthClientId.isEmpty) return;
    try {
      await _client
          .post(
            Uri.parse('${AppConfig.authBaseUrl}/oauth/revoke'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'token': token.refreshToken,
              'client_id': AppConfig.mcpOauthClientId,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      AppLogger.debug('MCP token revoke error: $e');
    }
  }
}
