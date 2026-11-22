import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/services/account_deletion_service.dart';
import 'package:dayzen/core/services/jwt_auth_service.dart';

/// "Delete account" calls DELETE /users/me, and
/// only after the server confirms does the app sign out and wipe the device.
/// On any failure nothing local is touched.

String _jwt(DateTime exp) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'none'})}.${b64({'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

void _seedValidSession() {
  final exp = DateTime.now().add(const Duration(hours: 1));
  FlutterSecureStorage.setMockInitialValues({
    'jwt_token': jsonEncode({
      'accessToken': _jwt(exp),
      'refreshToken': 'refresh-1',
      'expiresAt': exp.toIso8601String(),
    }),
    'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
  });
}

void main() {
  late List<http.Request> requests;
  late List<String> steps;
  late JwtAuthService auth;

  setUp(() async {
    _seedValidSession();
    requests = [];
    steps = [];
    // Refresh is rejected: a 401 from the API can't be rescued by a refresh.
    auth = JwtAuthService(
      httpClient: MockClient((_) async => http.Response('nope', 401)),
    );
    await auth.initialize();
  });

  AccountDeletionService service(Future<http.Response> Function() respond,
      {bool failLocalSteps = false}) {
    final api = ApiClient(
      authService: auth,
      client: MockClient((r) async {
        requests.add(r);
        return respond();
      }),
    );
    return AccountDeletionService(
      api: api,
      signOut: () async {
        steps.add('signOut');
        if (failLocalSteps) throw StateError('boom');
      },
      wipeLocalData: () async {
        steps.add('wipe');
        if (failLocalSteps) throw StateError('boom');
      },
    );
  }

  test('204: sends an authenticated DELETE /users/me, then signs out and wipes',
      () async {
    await service(() async => http.Response('', 204)).deleteAccount();

    expect(requests, hasLength(1));
    expect(requests.single.method, 'DELETE');
    expect(requests.single.url.path, endsWith('/users/me'));
    expect(requests.single.headers['Authorization'], startsWith('Bearer '));
    expect(steps, ['signOut', 'wipe']);
  });

  test('local cleanup failures do not surface once the server deleted',
      () async {
    await service(() async => http.Response('', 204), failLocalSteps: true)
        .deleteAccount();
    expect(steps, ['signOut', 'wipe']); // both attempted
  });

  final failures = <String, (Future<http.Response> Function(), AccountDeletionFailure)>{
    'offline': (
      () async => throw const SocketException('offline'),
      AccountDeletionFailure.offline
    ),
    '401 session expired': (
      () async => http.Response('{"detail":"User not found"}', 401),
      AccountDeletionFailure.sessionExpired
    ),
    '429 rate limited': (
      () async => http.Response('{"detail":"Too many"}', 429),
      AccountDeletionFailure.rateLimited
    ),
    '500 server error': (
      () async => http.Response('oops', 500),
      AccountDeletionFailure.server
    ),
  };

  for (final MapEntry(key: name, value: (respond, reason)) in failures.entries) {
    test('$name: throws $reason and touches nothing local', () async {
      await expectLater(
        service(respond).deleteAccount(),
        throwsA(isA<AccountDeletionException>()
            .having((e) => e.reason, 'reason', reason)
            .having((e) => e.message, 'message', isNotEmpty)),
      );
      expect(steps, isEmpty);
    });
  }
}
