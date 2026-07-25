import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'auth_controller.dart';
import 'sign_up_page.dart';
import 'widgets/auth_shared_widgets.dart';
import 'widgets/login_form_card.dart';

/// LoginPage — composes LoginFormCard under features/auth/widgets/. Split
/// from a single 389-line file in Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
class LoginPage extends StatefulWidget {
  /// Called when the user successfully signs in, with the email used.
  final ValueChanged<String> onSignedIn;

  /// Called when the user chooses to continue offline.
  final VoidCallback onContinueOffline;

  /// When true, shows a back arrow in the top-left.
  final bool canGoBack;

  const LoginPage({
    super.key,
    required this.onSignedIn,
    required this.onContinueOffline,
    this.canGoBack = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = AuthController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    _controller.signIn(
      email: email,
      password: _passwordCtrl.text,
      onSuccess: () => widget.onSignedIn(email),
    );
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final resetEmailCtrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: resetEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email address',
              hintText: 'name@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                final sent = await _controller.sendPasswordReset(
                  email: resetEmailCtrl.text,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      sent
                          ? 'Password reset email sent. Check your inbox.'
                          : _controller.error ?? 'Failed to send reset email.',
                    ),
                  ),
                );
              },
              child: const Text('Send Reset Email'),
            ),
          ],
        );
      },
    );
    resetEmailCtrl.dispose();
  }

  void _goToSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpPage(
          onSignedUp: widget.onSignedIn,
          onContinueOffline: widget.onContinueOffline,
          canGoBack: widget.canGoBack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DzColors.appBackground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.lg,
                vertical: DzSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button (when pushed from Settings) ────
                  if (widget.canGoBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                  // ── Brand ─────────────────────────────────────────
                  const SizedBox(height: DzSpacing.lg),
                  const Center(child: DzLogo(size: DzLogoSize.large)),
                  const SizedBox(height: DzSpacing.xl),

                  // ── Card ──────────────────────────────────────────
                  LoginFormCard(
                    controller: _controller,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscurePassword: _obscurePassword,
                    onToggleObscurePassword: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    onForgotPassword: () => _showForgotPasswordDialog(context),
                    canGoBack: widget.canGoBack,
                    onContinueOffline: widget.onContinueOffline,
                    onSignUpTap: () => _goToSignUp(context),
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // ── Trust badges ───────────────────────────────────
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AuthTrustBadge(
                        icon: Icons.shield_rounded,
                        label: 'Privacy First',
                      ),
                      SizedBox(width: DzSpacing.xl),
                      AuthTrustBadge(
                        icon: Icons.storage_rounded,
                        label: 'Local Storage',
                      ),
                    ],
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // ── Copyright ──────────────────────────────────────
                  Text(
                    '© 2024 DAYZEN AI. ALL RIGHTS RESERVED.',
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: DzSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
