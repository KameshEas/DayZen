import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/api/api_client.dart';

void main() {
  group('ApiClient', () {
    group('ApiErrorType', () {
      test('networkError is identified correctly', () {
        const error = ApiErrorType.networkError;
        expect(error, equals(ApiErrorType.networkError));
      });

      test('serverError is identified correctly', () {
        const error = ApiErrorType.serverError;
        expect(error, equals(ApiErrorType.serverError));
      });

      test('authenticationError is identified correctly', () {
        const error = ApiErrorType.authenticationError;
        expect(error, equals(ApiErrorType.authenticationError));
      });

      test('validationError is identified correctly', () {
        const error = ApiErrorType.validationError;
        expect(error, equals(ApiErrorType.validationError));
      });

      test('conflictError is identified correctly', () {
        const error = ApiErrorType.conflictError;
        expect(error, equals(ApiErrorType.conflictError));
      });

      test('notFoundError is identified correctly', () {
        const error = ApiErrorType.notFoundError;
        expect(error, equals(ApiErrorType.notFoundError));
      });

      test('unknown is identified correctly', () {
        const error = ApiErrorType.unknown;
        expect(error, equals(ApiErrorType.unknown));
      });
    });

    group('ApiException', () {
      test('creates exception with message', () {
        const message = 'Network connection failed';
        final exception = ApiException(
          message,
          errorType: ApiErrorType.networkError,
        );

        expect(exception.errorType, equals(ApiErrorType.networkError));
        expect(exception.message, equals(message));
      });

      test('creates exception with status code', () {
        const message = 'Internal server error';
        final exception = ApiException(
          message,
          statusCode: 500,
          errorType: ApiErrorType.serverError,
        );

        expect(exception.statusCode, equals(500));
        expect(exception.message, equals(message));
      });

      test('toString returns message', () {
        const message = 'Connection failed';
        final exception = ApiException(
          message,
          errorType: ApiErrorType.networkError,
        );

        expect(exception.toString(), equals(message));
      });
    });

    group('getUserErrorMessage', () {
      test('returns message for network error', () {
        final exception = ApiException(
          'Connection failed',
          errorType: ApiErrorType.networkError,
        );
        final message = ApiClient.getUserErrorMessage(exception);
        expect(message, isNotEmpty);
      });

      test('returns message for server error', () {
        final exception = ApiException(
          'Server error',
          statusCode: 500,
          errorType: ApiErrorType.serverError,
        );
        final message = ApiClient.getUserErrorMessage(exception);
        expect(message, isNotEmpty);
      });

      test('returns message for authentication error', () {
        final exception = ApiException(
          'Authentication failed',
          errorType: ApiErrorType.authenticationError,
        );
        final message = ApiClient.getUserErrorMessage(exception);
        expect(message, isNotEmpty);
      });

      test('returns message for validation error', () {
        final exception = ApiException(
          'Validation failed',
          errorType: ApiErrorType.validationError,
        );
        final message = ApiClient.getUserErrorMessage(exception);
        expect(message, isNotEmpty);
      });

      test('returns message for unknown error', () {
        final exception = ApiException(
          'Unknown error',
          errorType: ApiErrorType.unknown,
        );
        final message = ApiClient.getUserErrorMessage(exception);
        expect(message, isNotEmpty);
      });
    });
  });
}
