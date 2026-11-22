import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/services/password_reset_service.dart';
import 'package:dayzen/features/auth/password_reset_controller.dart';

class FakeResetService implements PasswordResetService {
  final calls = <String>[];
  PasswordResetFailure? failRequest;
  PasswordResetFailure? failVerify;
  PasswordResetFailure? failReset;
  String? lastPassword;

  @override
  Future<void> requestCode(String email) async {
    calls.add('request:$email');
    if (failRequest != null) throw PasswordResetException(failRequest!);
  }

  @override
  Future<String> verifyCode(String email, String code) async {
    calls.add('verify:$email:$code');
    if (failVerify != null) throw PasswordResetException(failVerify!);
    return 'reset-token';
  }

  @override
  Future<void> resetPassword(String resetToken, String newPassword) async {
    calls.add('reset:$resetToken');
    lastPassword = newPassword;
    if (failReset != null) throw PasswordResetException(failReset!);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeResetService service;
  late DateTime now;
  late PasswordResetController ctrl;

  setUp(() {
    service = FakeResetService();
    now = DateTime(2026, 11, 22, 12);
    ctrl = PasswordResetController(service: service, clock: () => now);
  });

  test('happy path: email -> code -> new password -> done', () async {
    expect(await ctrl.sendCode(' a@b.co '), isTrue);
    expect(ctrl.step, PasswordResetStep.code);
    expect(ctrl.email, 'a@b.co');

    expect(await ctrl.verifyCode('123 456'), isTrue);
    expect(ctrl.step, PasswordResetStep.newPassword);

    expect(await ctrl.setNewPassword('new-password', 'new-password'), isTrue);
    expect(ctrl.step, PasswordResetStep.done);
    expect(service.calls,
        ['request:a@b.co', 'verify:a@b.co:123456', 'reset:reset-token']);
    expect(service.lastPassword, 'new-password');
  });

  test('local checks run before any request (codes have few attempts)',
      () async {
    expect(await ctrl.sendCode('not-an-email'), isFalse);
    expect(ctrl.error, isNotNull);

    await ctrl.sendCode('a@b.co');
    expect(await ctrl.verifyCode('12345'), isFalse); // 5 digits
    expect(await ctrl.verifyCode('12a456'), isFalse);
    await ctrl.verifyCode('123456');

    expect(await ctrl.setNewPassword('short', 'short'), isFalse);
    expect(await ctrl.setNewPassword('        ', '        '), isFalse);
    expect(await ctrl.setNewPassword('new-password', 'other-password'), isFalse);
    expect(service.calls, ['request:a@b.co', 'verify:a@b.co:123456']);
  });

  test('a wrong code keeps you on the code step with a message', () async {
    await ctrl.sendCode('a@b.co');
    service.failVerify = PasswordResetFailure.invalidCode;
    expect(await ctrl.verifyCode('000000'), isFalse);
    expect(ctrl.step, PasswordResetStep.code);
    expect(ctrl.error, contains("didn't work"));
  });

  test('an expired reset session sends you back to request a new code',
      () async {
    await ctrl.sendCode('a@b.co');
    await ctrl.verifyCode('123456');
    service.failReset = PasswordResetFailure.sessionExpired;

    expect(await ctrl.setNewPassword('new-password', 'new-password'), isFalse);
    expect(ctrl.step, PasswordResetStep.email);
    expect(ctrl.error, contains('new code'));
  });

  test('a password the server refuses keeps you on the password step',
      () async {
    await ctrl.sendCode('a@b.co');
    await ctrl.verifyCode('123456');
    service.failReset = PasswordResetFailure.weakPassword;
    expect(await ctrl.setNewPassword('new-password', 'new-password'), isFalse);
    expect(ctrl.step, PasswordResetStep.newPassword);
  });

  test('resend waits out the 60 s cooldown', () async {
    await ctrl.sendCode('a@b.co');
    expect(ctrl.resendInSeconds, 60);
    expect(await ctrl.resendCode(), isFalse);

    now = now.add(const Duration(seconds: 59, milliseconds: 500));
    expect(ctrl.resendInSeconds, 1);

    now = now.add(const Duration(seconds: 1));
    expect(ctrl.resendInSeconds, 0);
    expect(await ctrl.resendCode(), isTrue);
    expect(service.calls.where((c) => c.startsWith('request:')), hasLength(2));
    expect(ctrl.resendInSeconds, 60);
  });

  test('offline on step 1 stays on step 1 and explains', () async {
    service.failRequest = PasswordResetFailure.offline;
    expect(await ctrl.sendCode('a@b.co'), isFalse);
    expect(ctrl.step, PasswordResetStep.email);
    expect(ctrl.error, contains('connection'));
    expect(ctrl.isBusy, isFalse);
  });

  test('startOver returns to the email step', () async {
    await ctrl.sendCode('a@b.co');
    ctrl.startOver();
    expect(ctrl.step, PasswordResetStep.email);
  });
}
