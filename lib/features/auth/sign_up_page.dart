import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'auth_controller.dart';

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
                  // ── Top nav ──────────────────────────────────────
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

                  // ── Avatar icon ───────────────────────────────────
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6EE7B7), // mint green circle
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF065F46),
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.md),

                  // ── Heading ────────────────────────────────────────
                  Center(
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

                  // ── Card ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(DzSpacing.xl),
                    decoration: BoxDecoration(
                      color: DzColors.cardBackground,
                      borderRadius: BorderRadius.circular(DzRadius.card),
                      boxShadow: DzShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Full Name ───────────────────────────────
                        Text('Full Name', style: DzTextStyles.label),
                        const SizedBox(height: DzSpacing.sm),
                        DzTextField(
                          controller: _nameCtrl,
                          hint: 'Alex Doe',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                          ),
                          onChanged: (_) => _controller.clearError(),
                        ),
                        const SizedBox(height: DzSpacing.md),

                        // ── Email ───────────────────────────────────
                        Text('Email Address', style: DzTextStyles.label),
                        const SizedBox(height: DzSpacing.sm),
                        DzTextField(
                          controller: _emailCtrl,
                          hint: 'alex@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(
                            Icons.mail_outline_rounded,
                            size: 20,
                          ),
                          onChanged: (_) => _controller.clearError(),
                        ),
                        const SizedBox(height: DzSpacing.md),

                        // ── Password ────────────────────────────────
                        Text('Password', style: DzTextStyles.label),
                        const SizedBox(height: DzSpacing.sm),
                        DzTextField(
                          controller: _passwordCtrl,
                          hint: '••••••••',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          onSubmitted: (_) => _submit(),
                          onChanged: (_) => _controller.clearError(),
                        ),

                        // ── Error ───────────────────────────────────
                        if (_controller.error != null) ...[
                          const SizedBox(height: DzSpacing.sm),
                          Text(
                            _controller.error!,
                            style: DzTextStyles.caption.copyWith(
                              color: DzColors.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: DzSpacing.xl),

                        // ── Create Account button ───────────────────
                        DzPrimaryButton(
                          label: 'Create Account',
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: DzColors.white,
                            size: 18,
                          ),
                          isLoading: _controller.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: DzSpacing.lg),

                        // ── "or choose privacy" divider ─────────────
                        if (!widget.canGoBack) ...[
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DzSpacing.md,
                              ),
                              child: Text(
                                'or choose privacy',
                                style: DzTextStyles.caption.copyWith(
                                  color: DzColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: DzSpacing.lg),

                        // ── Use Offline Instead ─────────────────────
                        DzSecondaryButton(
                          label: 'Use Offline Instead',
                          icon: const Icon(
                            Icons.cloud_off_rounded,
                            size: 18,
                          ),
                          onPressed: widget.onContinueOffline,
                        ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // ── End-to-end encrypted badge ─────────────────────
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
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

                  // ── Log in link ────────────────────────────────────
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
