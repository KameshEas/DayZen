import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'auth_controller.dart';
import 'widgets/signup_form_card.dart';

/// SignUpPage â€” composes SignUpFormCard under features/auth/widgets/.
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

  void _submit() {
    final email = _emailCtrl.text.trim();
    _controller.signUp(
      fullName: _nameCtrl.text,
      email: email,
      password: _passwordCtrl.text,
      onSuccess: () => widget.onSignedUp(email),
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
                vertical: DzSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // â”€â”€ Top nav â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const DzLogo(),
                    ],
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // â”€â”€ Avatar icon â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: DzColors.signUpAvatarBg, // mint green circle
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: DzColors.signUpAvatarIcon,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // â”€â”€ Heading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  const Center(
                    child: Text(
                      'Create Account',
                      style: DzTextStyles.heading1,
                    ),
                  ),
                  const SizedBox(height: DzSpacing.xs),
                  Center(
                    child: Text(
                      'Optional, for backup & sync',
                      style: DzTextStyles.body.copyWith(
                        color: DzColors.zenGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.lg),

                  // â”€â”€ Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  SignUpFormCard(
                    controller: _controller,
                    nameCtrl: _nameCtrl,
                    emailCtrl: _emailCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscurePassword: _obscurePassword,
                    onToggleObscurePassword: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    canGoBack: widget.canGoBack,
                    onContinueOffline: widget.onContinueOffline,
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // â”€â”€ End-to-end encrypted badge â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 14,
                          color: DzColors.textSecondary,
                        ),
                        const SizedBox(width: DzSpacing.xs),
                        Text(
                          'END-TO-END ENCRYPTED',
                          style: DzTextStyles.caption.copyWith(
                            color: DzColors.textSecondary,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // â”€â”€ Log in link â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: RichText(
                        text: TextSpan(
                          style: DzTextStyles.body.copyWith(
                            color: DzColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: DzTextStyles.body.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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


