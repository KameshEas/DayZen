import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../core/services/password_reset_service.dart';
import 'password_reset_controller.dart';
import 'widgets/auth_shared_widgets.dart';

/// "Forgot password?": email -> 6-digit code -> new password.
///
/// Pops with the account's email when the password was changed, so the
/// sign-in page can prefill it; pops with null if the user backs out.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = '', this.controller});

  final String initialEmail;

  /// Injectable for tests.
  final PasswordResetController? controller;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final PasswordResetController _ctrl =
      widget.controller ?? PasswordResetController(initialEmail: widget.initialEmail);
  late final _emailCtrl = TextEditingController(text: widget.initialEmail);
  final _codeCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Repaints the "Resend in Ns" countdown.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _ctrl.step == PasswordResetStep.code) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    if (widget.controller == null) _ctrl.dispose();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    if (await _ctrl.sendCode(_emailCtrl.text)) _codeCtrl.clear();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    await _ctrl.verifyCode(_codeCtrl.text);
  }

  Future<void> _setPassword() async {
    FocusScope.of(context).unfocus();
    final ok = await _ctrl.setNewPassword(_passwordCtrl.text, _confirmCtrl.text);
    if (ok && mounted) Navigator.of(context).pop(_ctrl.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _ctrl,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.lg, vertical: DzSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthBackButton(onPressed: () => Navigator.of(context).maybePop()),
                const SizedBox(height: DzSpacing.xl),
                DzCard(
                  padding: const EdgeInsets.all(DzSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._stepContent(context),
                      if (_ctrl.error != null) ...[
                        const SizedBox(height: DzSpacing.md),
                        AuthErrorBanner(message: _ctrl.error!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _stepContent(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget title(String text) => Semantics(
          header: true,
          child: Text(text, style: DzTextStyles.heading2),
        );
    Widget body(String text) => Text(
          text,
          style: DzTextStyles.body.copyWith(color: muted, height: 1.4),
        );

    switch (_ctrl.step) {
      case PasswordResetStep.email:
        return [
          title('Reset your password'),
          const SizedBox(height: DzSpacing.sm),
          body("Enter your account's email. We'll send you a 6-digit code."),
          const SizedBox(height: DzSpacing.lg),
          DzTextField(
            key: const Key('reset-email-field'),
            controller: _emailCtrl,
            label: 'Email address',
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            autofocus: _emailCtrl.text.isEmpty,
            onSubmitted: (_) => _sendCode(),
          ),
          const SizedBox(height: DzSpacing.lg),
          DzPrimaryButton(
            key: const Key('reset-send-code'),
            label: 'Send code',
            loadingLabel: 'Sending…',
            isLoading: _ctrl.isBusy,
            width: double.infinity,
            onPressed: _ctrl.isBusy ? null : _sendCode,
          ),
        ];

      case PasswordResetStep.code:
        final wait = _ctrl.resendInSeconds;
        return [
          title('Check your email'),
          const SizedBox(height: DzSpacing.sm),
          body('If ${_ctrl.email} has a DayZen account, we sent it a '
              '${PasswordResetService.codeLength}-digit code. It expires in '
              '10 minutes.'),
          const SizedBox(height: DzSpacing.lg),
          DzTextField(
            key: const Key('reset-code-field'),
            controller: _codeCtrl,
            label: '6-digit code',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.pin_outlined),
            autofocus: true,
            onSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: DzSpacing.lg),
          DzPrimaryButton(
            key: const Key('reset-verify-code'),
            label: 'Continue',
            loadingLabel: 'Checking…',
            isLoading: _ctrl.isBusy,
            width: double.infinity,
            onPressed: _ctrl.isBusy ? null : _verify,
          ),
          const SizedBox(height: DzSpacing.sm),
          // Wrap, not Row: with large text or a narrow phone the two
          // buttons don't fit side by side (overflowed on a 1080px device).
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: DzSpacing.sm,
            children: [
              TextButton(
                key: const Key('reset-resend-code'),
                onPressed: wait > 0 || _ctrl.isBusy ? null : _ctrl.resendCode,
                child: Text(wait > 0 ? 'Resend code in ${wait}s' : 'Resend code'),
              ),
              TextButton(
                onPressed: _ctrl.isBusy ? null : _ctrl.startOver,
                child: const Text('Different email'),
              ),
            ],
          ),
        ];

      case PasswordResetStep.newPassword:
      case PasswordResetStep.done:
        return [
          title('Choose a new password'),
          const SizedBox(height: DzSpacing.sm),
          body('At least ${PasswordResetService.minPasswordLength} characters. '
              "You'll be signed out on your other devices."),
          const SizedBox(height: DzSpacing.lg),
          DzTextField(
            key: const Key('reset-password-field'),
            controller: _passwordCtrl,
            label: 'New password',
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            autofocus: true,
            suffixIcon: IconButton(
              tooltip: _obscure ? 'Show password' : 'Hide password',
              icon: Icon(_obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: DzSpacing.md),
          DzTextField(
            key: const Key('reset-confirm-field'),
            controller: _confirmCtrl,
            label: 'Confirm new password',
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            onSubmitted: (_) => _setPassword(),
          ),
          const SizedBox(height: DzSpacing.lg),
          DzPrimaryButton(
            key: const Key('reset-save-password'),
            label: 'Save new password',
            loadingLabel: 'Saving…',
            isLoading: _ctrl.isBusy,
            width: double.infinity,
            onPressed: _ctrl.isBusy ? null : _setPassword,
          ),
        ];
    }
  }
}
