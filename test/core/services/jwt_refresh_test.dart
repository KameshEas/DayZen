import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/services/jwt_auth_service.dart';

/// Regression tests for docs/MOBILE_PROJECT_PLAN.md P0-3: a failed token
/// refresh used to clear the session on *any* error, so opening the app
/// offline near token expiry signed the user out.

String _jwt(DateTime exp) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'none'})}.${b64({'exp': exp.millisecondsSinceEpoch ~/ 1000})}.sig';
}

/// Seeds secure storage with a session whose access token is about to expire.
void _seedExpiringSession() {
  FlutterSecureStorage.setMockInitialValues({
    'jwt_token': jsonEncode({
      'accessToken': _jwt(DateTime.now().add(const Duration(minutes: 1))),
      'refreshToken': 'refresh-1',
      'expiresAt': DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
    }),
    'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
  });
}

http.Response _tokens(String access) => http.Response(
    jsonEncode({'access_token': access, 'refresh_token': 'refresh-2'}), 200);

void main() {
  setUp(_seedExpiringSession);

  test('refresh that cannot reach the server keeps the session', () async {
    final auth = JwtAuthService(
      httpClient: MockClient((_) async => throw const SocketException('offline')),
    );
    await auth.initialize();

    expect(auth.isAuthenticated, isTrue);
    expect(await const FlutterSecureStorage().read(key: 'jwt_token'), isNotNull);
  });

  test('a 5xx on refresh keeps the session', () async {
    final auth = JwtAuthService(
      httpClient: MockClient((_) async => http.Response('down', 503)),
    );
    await auth.initialize();
    expect(auth.isAuthenticated, isTrue);
  });

  test('a rejected refresh token (401) signs out', () async {
    final auth = JwtAuthService(
      httpClient: MockClient((_) async => http.Response('nope', 401)),
    );
    await auth.initialize();

    expect(auth.isAuthenticated, isFalse);
    expect(await const FlutterSecureStorage().read(key: 'jwt_token'), isNull);
  });

  test('concurrent callers share a single refresh request', () async {
    var refreshCalls = 0;
    final gate = Completer<void>();
    final auth = JwtAuthService(
      httpClient: MockClient((r) async {
        refreshCalls++;
        await gate.future;
        return _tokens(_jwt(DateTime.now().add(const Duration(hours: 1))));
      }),
    );
    // A session that is not near expiry, so initialize() doesn't refresh.
    FlutterSecureStorage.setMockInitialValues({
      'jwt_token': jsonEncode({
        'accessToken': _jwt(DateTime.now().add(const Duration(hours: 1))),
        'refreshToken': 'refresh-1',
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      }),
      'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
    });
    await auth.initialize();
    expect(refreshCalls, 0);

    // Three requests all got a 401 at once.
    final waiting = [
      auth.refreshAfterUnauthorized(),
      auth.refreshAfterUnauthorized(),
      auth.refreshAfterUnauthorized(),
    ];
    gate.complete();
    expect(await Future.wait(waiting), [true, true, true]);
    expect(refreshCalls, 1);
  });

  test('ApiClient refreshes once on 401 and retries with the new token',
      () async {
    final fresh = _jwt(DateTime.now().add(const Duration(hours: 1)));
    final auth = JwtAuthService(
      httpClient: MockClient((r) async => _tokens(fresh)),
    );
    FlutterSecureStorage.setMockInitialValues({
      'jwt_token': jsonEncode({
        'accessToken': 'stale',
        'refreshToken': 'refresh-1',
      }),
      'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
    });
    await auth.initialize();

    final seenAuth = <String?>[];
    final api = ApiClient(
      authService: auth,
      client: MockClient((r) async {
        seenAuth.add(r.headers['Authorization']);
        return r.headers['Authorization'] == 'Bearer $fresh'
            ? http.Response('{"ok": true}', 200)
            : http.Response('{"detail": "expired"}', 401);
      }),
    );

    expect(await api.get('/tasks'), {'ok': true});
    expect(seenAuth, ['Bearer stale', 'Bearer $fresh']);
  });

  test('a write retried after a dropped connection reuses its Idempotency-Key',
      () async {
    final keys = <String?>[];
    var attempts = 0;
    final api = ApiClient(
      authService: JwtAuthService(httpClient: MockClient((_) async => http.Response('', 500))),
      client: MockClient((r) async {
        keys.add(r.headers['Idempotency-Key']);
        if (++attempts == 1) throw http.ClientException('connection reset');
        return http.Response('{}', 200);
      }),
    );

    await api.post('/tasks/sync', {'tasks': []});
    expect(keys, hasLength(2));
    expect(keys.first, isNotNull);
    expect(keys.first, keys.last);
  });

  group('signOut', () {
    test('revokes the refresh token on the server after clearing locally',
        () async {
      final calls = <http.Request>[];
      final auth = JwtAuthService(
        httpClient: MockClient((r) async {
          calls.add(r);
          return http.Response('{"success": true}', 200);
        }),
      );
      FlutterSecureStorage.setMockInitialValues({
        'jwt_token': jsonEncode({
          'accessToken': _jwt(DateTime.now().add(const Duration(hours: 1))),
          'refreshToken': 'refresh-1',
        }),
        'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
      });
      await auth.initialize();

      await auth.signOut();

      expect(auth.isAuthenticated, isFalse);
      expect(await const FlutterSecureStorage().read(key: 'jwt_token'), isNull);
      expect(calls, hasLength(1));
      expect(calls.single.url.path, endsWith('/auth/logout'));
      expect(jsonDecode(calls.single.body), {'refresh_token': 'refresh-1'});
    });

    test('offline: still signs out locally', () async {
      final auth = JwtAuthService(
        httpClient:
            MockClient((_) async => throw const SocketException('offline')),
      );
      FlutterSecureStorage.setMockInitialValues({
        'jwt_token': jsonEncode({
          'accessToken': _jwt(DateTime.now().add(const Duration(hours: 1))),
          'refreshToken': 'refresh-1',
        }),
        'auth_user': jsonEncode({'id': 'u1', 'email': 'a@b.c', 'name': null}),
      });
      await auth.initialize();

      await auth.signOut();

      expect(auth.isAuthenticated, isFalse);
      expect(await const FlutterSecureStorage().read(key: 'jwt_token'), isNull);
    });
  });
}
