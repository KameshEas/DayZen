import 'package:flutter/foundation.dart';

import '../../core/security/password_policy.dart';
import '../../core/services/password_reset_service.dart';

enum PasswordResetStep { email, code, newPassword, done }

/// State for the "Forgot password?" flow: email -> 6-digit code -> new
/// password. Validates locally before calling the server, so simple mistakes
/// don't spend one of the code's limited attempts.
class PasswordResetController extends ChangeNotifier {
  PasswordResetController({
    PasswordResetService? service,
    DateTime Function()? clock,
    String initialEmail = '',
  })  : _service = service ?? PasswordResetService(),
        _now = clock ?? DateTime.now,
        _email = initialEmail.trim();

  /// Matches the server's per-email cooldown between codes.
  static const resendCooldown = Duration(seconds: 60);

  final PasswordResetService _service;
  final DateTime Function() _now;

  PasswordResetStep _step = PasswordResetStep.email;
  String _email;
  String? _resetToken;
  String? _error;
  bool _busy = false;
  DateTime? _canResendAt;

  PasswordResetStep get step => _step;
  String get email => _email;
  String? get error => _error;
  bool get isBusy => _busy;

  /// Seconds until "Resend code" is allowed again (0 = now).
  int get resendInSeconds {
    final at = _canResendAt;
    if (at == null) return 0;
    final left = at.difference(_now()).inMilliseconds;
    return left <= 0 ? 0 : (left / 1000).ceil();
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Step 1. Always moves on when the server accepts the request: it never
  /// says whether the email has an account.
  Future<bool> sendCode(String email) async {
    final trimmed = email.trim();
    if (!_emailPattern.hasMatch(trimmed)) {
      return _fail('Enter the email address you signed up with.');
    }
    final ok = await _run(() => _service.requestCode(trimmed));
    if (!ok) return false;
    _email = trimmed;
    _canResendAt = _now().add(resendCooldown);
    _step = PasswordResetStep.code;
    notifyListeners();
    return true;
  }

  Future<bool> resendCode() async {
    if (resendInSeconds > 0) return false;
    final ok = await _run(() => _service.requestCode(_email));
    if (ok) {
      _canResendAt = _now().add(resendCooldown);
      notifyListeners();
    }
    return ok;
  }

  /// Step 2.
  Future<bool> verifyCode(String code) async {
    final digits = code.replaceAll(RegExp(r'\s'), '');
    if (!RegExp('^\\d{${PasswordResetService.codeLength}}\$').hasMatch(digits)) {
      return _fail(
          'Enter the ${PasswordResetService.codeLength}-digit code from the email.');
    }
    String? token;
    final ok = await _run(() async {
      token = await _service.verifyCode(_email, digits);
    });
    if (!ok) return false;
    _resetToken = token;
    _step = PasswordResetStep.newPassword;
    notifyListeners();
    return true;
  }

  /// Step 3.
  Future<bool> setNewPassword(String password, String confirmation) async {
    final policyError = passwordPolicyError(password, subject: 'New password');
    if (policyError != null) return _fail(policyError);
    if (password != confirmation) {
      return _fail("The two passwords don't match.");
    }
    final token = _resetToken;
    if (token == null) return _restart(PasswordResetFailure.sessionExpired);

    PasswordResetFailure? failure;
    final ok = await _run(() => _service.resetPassword(token, password),
        onFailure: (f) => failure = f);
    if (!ok) {
      // The token is gone: the only way forward is a new code.
      if (failure == PasswordResetFailure.sessionExpired) {
        return _restart(PasswordResetFailure.sessionExpired);
      }
      return false;
    }
    _resetToken = null;
    _step = PasswordResetStep.done;
    notifyListeners();
    return true;
  }

  /// "Use a different email" from the code step.
  void startOver() {
    _step = PasswordResetStep.email;
    _resetToken = null;
    _error = null;
    notifyListeners();
  }

  bool _restart(PasswordResetFailure reason) {
    _step = PasswordResetStep.email;
    _resetToken = null;
    _error = PasswordResetException(reason).message;
    notifyListeners();
    return false;
  }

  bool _fail(String message) {
    _error = message;
    notifyListeners();
    return false;
  }

  Future<bool> _run(
    Future<void> Function() call, {
    void Function(PasswordResetFailure)? onFailure,
  }) async {
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await call();
      return true;
    } on PasswordResetException catch (e) {
      _error = e.message;
      onFailure?.call(e.reason);
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
