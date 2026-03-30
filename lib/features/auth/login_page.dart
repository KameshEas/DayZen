import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'auth_controller.dart';
import 'sign_up_page.dart';

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
                        // ── Heading ─────────────────────────────────
                        Center(
                          child: Text(
                            'Welcome Back',
                            style: DzTextStyles.heading1,
                          ),
                        ),
                        const SizedBox(height: DzSpacing.sm),
                        Center(
                          child: Text(
                            'Continue your calm planning',
                            style: DzTextStyles.body.copyWith(
                              color: DzColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: DzSpacing.xl),

                        // ── Email ───────────────────────────────────
                        Text('Email address', style: DzTextStyles.label),
                        const SizedBox(height: DzSpacing.sm),
                        DzTextField(
                          controller: _emailCtrl,
                          hint: 'name@example.com',
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Password', style: DzTextStyles.label),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to forgot-password flow
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset coming soon.'),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: DzTextStyles.label.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
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

                        // ── Sign In button ──────────────────────────
                        DzPrimaryButton(
                          label: 'Sign In',
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: DzColors.white,
                            size: 18,
                          ),
                          isLoading: _controller.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: DzSpacing.lg),

                        // ── OR divider + Continue Offline ────────
                        if (!widget.canGoBack) ...[
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DzSpacing.md,
                              ),
                              child: Text(
                                'OR',
                                style: DzTextStyles.caption.copyWith(
                                  color: DzColors.textSecondary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: DzSpacing.lg),

                        // ── Continue Offline button ─────────────────
                        DzSecondaryButton(
                          label: 'Continue Offline',
                          icon: const Icon(
                            Icons.cloud_off_rounded,
                            size: 18,
                          ),
                          onPressed: widget.onContinueOffline,
                        ),
                        ],
                        const SizedBox(height: DzSpacing.xl),

                        // ── Sign Up link ────────────────────────────
                        Center(
                          child: _SignUpLink(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => SignUpPage(
                                        onSignedUp: widget.onSignedIn,
                                        onContinueOffline:
                                            widget.onContinueOffline,
                                        canGoBack: widget.canGoBack,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DzSpacing.xl),

                  // ── Trust badges ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TrustBadge(
                        icon: Icons.shield_rounded,
                        label: 'Privacy First',
                      ),
                      const SizedBox(width: DzSpacing.xl),
                      _TrustBadge(
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

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: DzColors.textSecondary),
        const SizedBox(width: DzSpacing.xs),
        Text(
          label,
          style: DzTextStyles.caption.copyWith(color: DzColors.textSecondary),
        ),
      ],
    );
  }
}

class _SignUpLink extends StatelessWidget {
  final VoidCallback onTap;
  const _SignUpLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
          children: [
            const TextSpan(text: "Don't have an account? "),
            TextSpan(
              text: 'Start your journey',
              style: DzTextStyles.body.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
