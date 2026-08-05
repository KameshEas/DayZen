/// HTTP client for API communication with retry logic and error handling.
library;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
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
  };

  ApiClient({
    http.Client? client,
    JwtAuthService? authService,
  }) {
    _client = client ?? http.Client();
    _authService = authService ?? JwtAuthService();
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
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _authService.getAuthHeaders();
      final mergedHeaders = {
        ..._defaultHeaders,
        ...authHeaders,
        ...?headers,
      };

      final response = await _client
          .get(url, headers: mergedHeaders)
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('GET request to $endpoint timed out after ${timeout.inSeconds}s');
      });

      return _handleResponse(response, endpoint, 'GET');
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        return get(endpoint, headers: headers, retryCount: retryCount + 1);
      }
      throw ApiException(
        'GET request to $endpoint failed: $e',
        originalError: e,
        errorType: ApiErrorType.networkError,
      );
    }
  }

  /// Make a POST request with automatic retry on failure.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _authService.getAuthHeaders();
      final mergedHeaders = {
        ..._defaultHeaders,
        ...authHeaders,
        ...?headers,
      };

      final response = await _client
          .post(
            url,
            headers: mergedHeaders,
            body: jsonEncode(body),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('POST request to $endpoint timed out after ${timeout.inSeconds}s');
      });

      return _handleResponse(response, endpoint, 'POST');
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        return post(endpoint, body, headers: headers, retryCount: retryCount + 1);
      }
      throw ApiException(
        'POST request to $endpoint failed: $e',
        originalError: e,
        errorType: ApiErrorType.networkError,
      );
    }
  }

  /// Make a PUT request.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _authService.getAuthHeaders();
      final mergedHeaders = {
        ..._defaultHeaders,
        ...authHeaders,
        ...?headers,
      };

      final response = await _client
          .put(
            url,
            headers: mergedHeaders,
            body: jsonEncode(body),
          )
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('PUT request to $endpoint timed out after ${timeout.inSeconds}s');
      });

      return _handleResponse(response, endpoint, 'PUT');
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        return put(endpoint, body, headers: headers, retryCount: retryCount + 1);
      }
      throw ApiException(
        'PUT request to $endpoint failed: $e',
        originalError: e,
        errorType: ApiErrorType.networkError,
      );
    }
  }

  /// Make a DELETE request.
  /// Automatically includes JWT authentication token.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final authHeaders = await _authService.getAuthHeaders();
      final mergedHeaders = {
        ..._defaultHeaders,
        ...authHeaders,
        ...?headers,
      };

      final response = await _client
          .delete(url, headers: mergedHeaders)
          .timeout(timeout, onTimeout: () {
        throw TimeoutException('DELETE request to $endpoint timed out after ${timeout.inSeconds}s');
      });

      return _handleResponse(response, endpoint, 'DELETE');
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        return delete(endpoint, headers: headers, retryCount: retryCount + 1);
      }
      throw ApiException(
        'DELETE request to $endpoint failed: $e',
        originalError: e,
        errorType: ApiErrorType.networkError,
      );
    }
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

  /// Make a public GET request (no authentication required).
  /// Used for endpoints like /quotes/daily that don't require auth.
  Future<Map<String, dynamic>> publicGet(
    String endpoint, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {
        ..._defaultHeaders,
        ...?headers,
      };

      final response = await _client
          .get(url, headers: mergedHeaders)
          .timeout(timeout, onTimeout: () {
        throw TimeoutException(
            'Public GET request to $endpoint timed out after ${timeout.inSeconds}s');
      });

      return _handleResponse(response, endpoint, 'GET');
    } on TimeoutException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)));
        return publicGet(endpoint, headers: headers, retryCount: retryCount + 1);
      }
      throw ApiException(
        'Public GET request to $endpoint failed: $e',
        originalError: e,
        errorType: ApiErrorType.networkError,
      );
    }
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
