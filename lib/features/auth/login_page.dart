import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'auth_controller.dart';
import 'forgot_password_page.dart';
import 'sign_up_page.dart';
import 'widgets/auth_shared_widgets.dart';
import 'widgets/login_form_card.dart';

/// LoginPage — composes LoginFormCard under features/auth/widgets/.
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

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final settings = SettingsScope.of(context);
    final ok = await DzProgress.run<bool>(
      context,
      message: 'Signing you in…',
      successMessage: 'Welcome back',
      isSuccess: (ok) => ok,
      task: () => _controller.signIn(
        email: email,
        password: _passwordCtrl.text,
      ),
    );
    if (ok != true || !mounted) return;
    settings.setSignedIn(true, email);
    widget.onSignedIn(email);
  }

  Future<void> _openForgotPassword(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final email = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordPage(initialEmail: _emailCtrl.text.trim()),
      ),
    );
    if (email == null || !mounted) return;
    _emailCtrl.text = email;
    _passwordCtrl.clear();
    messenger.showSnackBar(const SnackBar(
      content: Text('Password updated. Sign in with your new password.'),
    ));
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
                    Semantics(
                      label: 'Go back',
                      button: true,
                      enabled: true,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),

                  // ── Brand ─────────────────────────────────────────
                  const SizedBox(height: DzSpacing.lg),
                  const Center(
                    child: DzLogo(layout: DzLogoLayout.stacked, width: 190),
                  ),
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
                    onForgotPassword: () => _openForgotPassword(context),
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
                        label: 'Works Offline',
                      ),
                    ],
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // ── Copyright ──────────────────────────────────────
                  Text(
                    '© ${DateTime.now().year} DAYZEN',
                    style: DzTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
