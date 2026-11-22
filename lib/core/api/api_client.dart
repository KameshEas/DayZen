/// HTTP client for API communication with retry logic and error handling.
library;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import '../services/jwt_auth_service.dart';
import '../config/app_config.dart';

/// Exception thrown when API communication fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;
  final ApiErrorType errorType;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
    this.errorType = ApiErrorType.unknown,
  });

  @override
  String toString() => message;
}

/// Types of API errors for better error handling
enum ApiErrorType {
  networkError,
  serverError,
  authenticationError,
  validationError,
  conflictError,
  notFoundError,
  unknown,
}

/// Exception thrown when API request times out.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// HTTP client for making API requests with retry logic and JWT auth.
class ApiClient {
  late final http.Client _client;
  late final JwtAuthService _authService;

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-App-ID': AppConfig.appId,
  };

  ApiClient({
    http.Client? client,
    JwtAuthService? authService,
  }) {
    _client = client ?? http.Client();
    // The shared singleton, not a fresh instance — a fresh JwtAuthService()
    // here would never be initialize()'d/signed-in, so every authenticated
    // request would go out with no Authorization header regardless of the
    // user's actual session elsewhere in the app.
    _authService = authService ?? JwtAuthService.instance;
  }

  /// Get the base URL from config
  String get baseUrl => AppConfig.apiBaseUrl;

  /// Get the timeout duration
  Duration get timeout => const Duration(seconds: AppConfig.apiTimeoutSeconds);

  /// Maximum number of retries for failed requests
  static const int maxRetries = 2;

  /// Make a GET request with automatic retry on failure.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) =>
      _send('GET', endpoint, headers: headers);

  /// Make a POST request with automatic retry on failure.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) =>
      _send('POST', endpoint, body: body, headers: headers);

  /// Make a PUT request.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) =>
      _send('PUT', endpoint, body: body, headers: headers);

  /// Make a DELETE request.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) =>
      _send('DELETE', endpoint, headers: headers);

  /// Make a public GET request (no authentication required).
  /// Used for endpoints like /quotes/daily that don't require auth.
  Future<Map<String, dynamic>> publicGet(
    String endpoint, {
    Map<String, String>? headers,
  }) =>
      _send('GET', endpoint, headers: headers, authenticated: false);

  /// One request with the shared policy:
  /// - a connection error is retried up to [maxRetries] times; a timeout or
  ///   an HTTP error response is not.
  /// - writes carry an `Idempotency-Key` that stays the same across those
  ///   retries, so a server that honours it never applies a write twice when
  ///   only the response was lost.
  /// - a 401 on an authenticated request triggers one token refresh and one
  ///   retry before it is reported as an authentication error.
  Future<Map<String, dynamic>> _send(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final payload = body == null ? null : jsonEncode(body);
    final idempotencyKey = method == 'GET' ? null : _newIdempotencyKey();
    var networkRetries = 0;
    var refreshedAfter401 = false;

    while (true) {
      final http.Response response;
      try {
        final authHeaders = authenticated
            ? await _authService.getAuthHeaders()
            : const <String, String>{};
        final request = http.Request(method, url)
          ..headers.addAll({
            ..._defaultHeaders,
            ...authHeaders,
            'Idempotency-Key': ?idempotencyKey,
            ...?headers,
          });
        if (payload != null) request.body = payload;

        response = await _client
            .send(request)
            .then(http.Response.fromStream)
            .timeout(timeout, onTimeout: () {
          throw TimeoutException(
              '$method request to $endpoint timed out after ${timeout.inSeconds}s');
        });
      } on TimeoutException catch (e) {
        throw ApiException(
          e.message,
          originalError: e,
          errorType: ApiErrorType.networkError,
        );
      } catch (e) {
        if (networkRetries < maxRetries) {
          networkRetries++;
          await Future.delayed(Duration(milliseconds: 100 * networkRetries));
          continue;
        }
        throw ApiException(
          '$method request to $endpoint failed: $e',
          originalError: e,
          errorType: ApiErrorType.networkError,
        );
      }

      if (response.statusCode == 401 && authenticated && !refreshedAfter401) {
        refreshedAfter401 = true;
        if (await _authService.refreshAfterUnauthorized()) continue;
      }
      return _handleResponse(response, endpoint, method);
    }
  }

  static final Random _random = Random.secure();

  static String _newIdempotencyKey() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Handle HTTP response and parse JSON.
  /// Categorizes errors by status code for better error handling.
  Map<String, dynamic> _handleResponse(
    http.Response response,
    String endpoint,
    String method,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException(
          'Failed to parse response from $method $endpoint: $e',
          statusCode: response.statusCode,
          errorType: ApiErrorType.unknown,
        );
      }
    }

    // Determine error type from status code
    final errorType = _getErrorType(response.statusCode);

    // Handle error responses
    String errorMessage = 'HTTP ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map) {
        if (errorData.containsKey('detail')) {
          errorMessage = (errorData['detail'] as String?) ?? errorMessage;
        } else if (errorData.containsKey('message')) {
          errorMessage = (errorData['message'] as String?) ?? errorMessage;
        }
      }
    } catch (e) {
      // Use default error message if JSON parsing fails
      // Don't rethrow - we'll use the HTTP status code error message
    }

    throw ApiException(
      '$method $endpoint failed: $errorMessage',
      statusCode: response.statusCode,
      errorType: errorType,
    );
  }

  /// Determine error type from HTTP status code
  ApiErrorType _getErrorType(int statusCode) {
    if (statusCode == 400) {
      return ApiErrorType.validationError;
    } else if (statusCode == 401) {
      return ApiErrorType.authenticationError;
    } else if (statusCode == 404) {
      return ApiErrorType.notFoundError;
    } else if (statusCode == 409) {
      return ApiErrorType.conflictError;
    } else if (statusCode >= 500) {
      return ApiErrorType.serverError;
    }
    return ApiErrorType.unknown;
  }

  /// Get user-friendly error message from ApiException
  static String getUserErrorMessage(ApiException exception) {
    switch (exception.errorType) {
      case ApiErrorType.authenticationError:
        return 'Please sign in again';
      case ApiErrorType.networkError:
        return 'No internet connection. Using offline data.';
      case ApiErrorType.serverError:
        return 'Server error. Please try again later.';
      case ApiErrorType.validationError:
        return 'Invalid input. Please check and try again.';
      case ApiErrorType.conflictError:
        return 'Conflict detected. Refreshing data...';
      case ApiErrorType.notFoundError:
        return 'Resource not found.';
      case ApiErrorType.unknown:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Close the HTTP client.
  void close() {
    _client.close();
  }
}
