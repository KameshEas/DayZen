import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/api/auth_service.dart';

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

    group('HTTP Request/Response with MockClient', () {
      late _MockAuthService mockAuthService;

      setUp(() {
        mockAuthService = _MockAuthService();
      });

      test('GET request returns parsed JSON on 200 OK', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, contains('/test'));
          return http.Response('{"result": "success"}', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.get('/test');

        expect(response, equals({'result': 'success'}));
      });

      test('POST request sends JSON body', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.body, contains('test_data'));
          return http.Response('{"id": "123"}', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.post('/create', {'test_data': 'value'});

        expect(response, equals({'id': '123'}));
      });

      test('PUT request updates resource', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('PUT'));
          return http.Response('{"updated": true}', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.put('/update/1', {'updated': true});

        expect(response, equals({'updated': true}));
      });

      test('DELETE request removes resource', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('DELETE'));
          return http.Response('{"deleted": true}', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.delete('/resource/1');

        expect(response, equals({'deleted': true}));
      });

      test('publicGet request works without auth', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.headers.containsKey('Authorization'), isFalse);
          return http.Response('{"quote": "Success"}', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.publicGet('/quotes/daily');

        expect(response, equals({'quote': 'Success'}));
      });

      test('400 status code throws validationError', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Invalid input"}', 400);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.get('/test'),
          throwsA(isA<ApiException>().having(
            (e) => e.errorType,
            'errorType',
            ApiErrorType.validationError,
          )),
        );
      });

      test('401 status code throws authenticationError', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Unauthorized"}', 401);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.get('/protected'),
          throwsA(isA<ApiException>().having(
            (e) => e.errorType,
            'errorType',
            ApiErrorType.authenticationError,
          )),
        );
      });

      test('404 status code throws notFoundError', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Not found"}', 404);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.get('/missing'),
          throwsA(isA<ApiException>().having(
            (e) => e.errorType,
            'errorType',
            ApiErrorType.notFoundError,
          )),
        );
      });

      test('409 status code throws conflictError', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Conflict"}', 409);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.post('/sync', {'data': 'test'}),
          throwsA(isA<ApiException>().having(
            (e) => e.errorType,
            'errorType',
            ApiErrorType.conflictError,
          )),
        );
      });

      test('500+ status code throws serverError', () async {
        final mockClient = MockClient((request) async {
          return http.Response('{"detail": "Server error"}', 500);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.get('/error'),
          throwsA(isA<ApiException>().having(
            (e) => e.errorType,
            'errorType',
            ApiErrorType.serverError,
          )),
        );
      });

      test('empty response body returns success map', () async {
        final mockClient = MockClient((request) async {
          return http.Response('', 204);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);
        final response = await apiClient.delete('/resource/1');

        expect(response, equals({'success': true}));
      });

      test('invalid JSON throws exception', () async {
        final mockClient = MockClient((request) async {
          return http.Response('invalid json', 200);
        });

        final apiClient = ApiClient(client: mockClient, authService: mockAuthService);

        expect(
          () => apiClient.get('/test'),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}

class _MockAuthService extends ChangeNotifier implements AuthService {
  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => 'mock-token';

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    return {'Authorization': 'Bearer mock-token'};
  }

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async => null;

  @override
  Future<UserCredential?> signUpWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {}

  @override
  void clearCachedToken() {}

  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => true;

  @override
  String? get userId => 'mock-user-id';

  @override
  String? get userEmail => 'test@example.com';

  @override
  bool get isTokenValid => true;

  @override
  DateTime? get tokenExpiryTime => DateTime.now().add(const Duration(hours: 1));
}
