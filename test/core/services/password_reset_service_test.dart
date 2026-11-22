import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dayzen/core/services/password_reset_service.dart';

/// "Forgot password?" used to call /auth/request-password-reset, which the
/// DayZen API never had. These pin the three real calls and how each server
/// answer maps to a failure the UI can explain.
void main() {
  late List<http.Request> requests;

  PasswordResetService service(http.Response Function(http.Request) respond) =>
      PasswordResetService(
        baseUrl: 'http://api.test/api/v1/dayzen',
        client: MockClient((r) async {
          requests.add(r);
          return respond(r);
        }),
      );

  http.Response json(int status, Map<String, dynamic> body) =>
      http.Response(jsonEncode(body), status);

  setUp(() => requests = []);

  test('requestCode posts the email to /auth/forgot-password, signed out',
      () async {
    await service((_) => json(202, {'success': true, 'message': 'sent'}))
        .requestCode('  a@b.co ');

    final r = requests.single;
    expect(r.url.path, '/api/v1/dayzen/auth/forgot-password');
    expect(r.headers['Authorization'], isNull);
    expect(r.headers['X-App-ID'], 'dayzen');
    expect(jsonDecode(r.body), {'email': 'a@b.co', 'app_id': 'dayzen'});
  });

  test('verifyCode returns the reset token', () async {
    final token = await service(
            (_) => json(200, {'reset_token': 'tok', 'expires_in': 600}))
        .verifyCode('a@b.co', ' 123456 ');

    expect(token, 'tok');
    expect(requests.single.url.path, endsWith('/auth/reset-password/verify-otp'));
    expect(jsonDecode(requests.single.body)['otp'], '123456');
  });

  test('resetPassword sends the token and new password', () async {
    await service((_) => json(200, {'success': true, 'message': 'ok'}))
        .resetPassword('tok', 'new-password');

    expect(requests.single.url.path, endsWith('/auth/reset-password'));
    expect(jsonDecode(requests.single.body),
        {'reset_token': 'tok', 'new_password': 'new-password', 'app_id': 'dayzen'});
  });

  Future<PasswordResetFailure> failureOf(Future<void> call) async {
    try {
      await call;
    } on PasswordResetException catch (e) {
      expect(e.message, isNotEmpty);
      return e.reason;
    }
    fail('expected a PasswordResetException');
  }

  test('a wrong code is invalidCode', () async {
    final s = service((_) => json(400, {'detail': 'Invalid or expired code'}));
    expect(await failureOf(s.verifyCode('a@b.co', '000000')),
        PasswordResetFailure.invalidCode);
  });

  test('an expired reset session is sessionExpired', () async {
    final s = service((_) =>
        json(400, {'detail': 'This reset session is invalid or has expired'}));
    expect(await failureOf(s.resetPassword('tok', 'long-enough')),
        PasswordResetFailure.sessionExpired);
  });

  test('a password the server refuses is weakPassword, with its message',
      () async {
    final s = service((_) => json(
        400, {'detail': 'New password must be at least 8 characters long'}));
    try {
      await s.resetPassword('tok', 'short');
      fail('expected an exception');
    } on PasswordResetException catch (e) {
      expect(e.reason, PasswordResetFailure.weakPassword);
      expect(e.message, 'New password must be at least 8 characters long');
    }
  });

  test('429 is tooManyAttempts; 5xx is server; no connection is offline',
      () async {
    expect(await failureOf(service((_) => json(429, {})).requestCode('a@b.co')),
        PasswordResetFailure.tooManyAttempts);
    expect(
        await failureOf(
            service((_) => http.Response('oops', 500)).requestCode('a@b.co')),
        PasswordResetFailure.server);
    final offline = PasswordResetService(
      baseUrl: 'http://api.test',
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    expect(await failureOf(offline.requestCode('a@b.co')),
        PasswordResetFailure.offline);
  });
}
