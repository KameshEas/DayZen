/// HTTP client for API communication with retry logic and error handling.
library;

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// Exception thrown when API communication fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Exception thrown when API request times out.
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

/// HTTP client for making API requests with retry logic.
class ApiClient {
  static const String baseUrl = 'https://api.dayzen.local/v1';
  static const Duration timeout = Duration(seconds: 10);
  static const int maxRetries = 2;

  late final http.Client _client;
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiClient({http.Client? client}) {
    _client = client ?? http.Client();
  }

  /// Make a GET request with automatic retry on failure.
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._defaultHeaders, ...?headers};

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
      );
    }
  }

  /// Make a POST request with automatic retry on failure.
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._defaultHeaders, ...?headers};

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
      );
    }
  }

  /// Make a PUT request.
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._defaultHeaders, ...?headers};

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
      );
    }
  }

  /// Make a DELETE request.
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
    int retryCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final mergedHeaders = {..._defaultHeaders, ...?headers};

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
      );
    }
  }

  /// Handle HTTP response and parse JSON.
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
        );
      }
    }

    // Handle error responses
    String errorMessage = 'HTTP ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('message')) {
        errorMessage = errorData['message'] as String;
      }
    } catch (_) {
      // Use default error message
    }

    throw ApiException(
      '$method $endpoint failed: $errorMessage',
      statusCode: response.statusCode,
    );
  }

  /// Close the HTTP client.
  void close() {
    _client.close();
  }
}
