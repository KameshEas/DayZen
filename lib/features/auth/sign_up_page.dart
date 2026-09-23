import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'auth_controller.dart';
import 'widgets/auth_shared_widgets.dart';
import 'widgets/signup_form_card.dart';

/// SignUpPage — composes SignUpFormCard under features/auth/widgets/.
/// Split from a single 309-line file in Phase 5.1 of
/// docs/DEVELOPMENT_PLAN.md.
class SignUpPage extends StatefulWidget {
  /// Called when account is successfully created, with the email used.
  final ValueChanged<String> onSignedUp;

  /// Called when the user opts to continue offline instead.
  final VoidCallback onContinueOffline;

  /// When true, hides the "Use Offline Instead" button (user is already offline).
  final bool canGoBack;

  const SignUpPage({
    super.key,
    required this.onSignedUp,
    required this.onContinueOffline,
    this.canGoBack = false,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _controller = AuthController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    _controller.signUp(
      fullName: _nameCtrl.text,
      email: email,
      password: _passwordCtrl.text,
      onSuccess: () {
        SettingsScope.of(context).setSignedIn(true, email);
        widget.onSignedUp(email);
      },
    );
    if (ok != true || !mounted) return;
    widget.onSignedUp(email);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.lg,
                vertical: DzSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Top bar: back, logo centred ───────────────────
                  Row(
                    children: [
                      AuthBackButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const Expanded(child: Center(child: DzLogo(width: 132))),
                      // Balances the back button so the logo sits in the middle.
                      const SizedBox(width: DzSizing.minTouchTarget),
                    ],
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // ── Hero ──────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: DzColors.signUpAvatarBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: DzColors.signUpAvatarIcon,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.md),
                  const Text(
                    AppConfig.signupTitle,
                    textAlign: TextAlign.center,
                    style: DzTextStyles.heading1,
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  Text(
                    'Back up your days and keep them in sync across devices. '
                    'An account is optional.',
                    textAlign: TextAlign.center,
                    style: DzTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── Form ──────────────────────────────────────────
                  SignUpFormCard(
                    controller: _controller,
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscurePassword: _obscurePassword,
                    onToggleObscurePassword: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // ── Offline alternative ───────────────────────────
                  if (!widget.canGoBack) ...[
                    const AuthOrDivider(label: 'or keep it private', italic: true),
                    const SizedBox(height: DzSpacing.md),
                    DzSecondaryButton(
                      label: 'Use offline instead',
                      icon: const Icon(Icons.cloud_off_rounded, size: 18),
                      onPressed: widget.onContinueOffline,
                    ),
                    const SizedBox(height: DzSpacing.lg),
                  ],

                  // ── Log in link ───────────────────────────────────
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, DzSizing.minTouchTarget),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: DzTextStyles.body.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: DzTextStyles.body.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
