import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../auth_controller.dart';
import 'auth_shared_widgets.dart';

/// The white card on the Login page — email/password fields, sign-in
/// button, and (when not pushed from Settings) the offline/sign-up
/// alternatives.
class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.controller,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscurePassword,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.canGoBack,
    required this.onContinueOffline,
    required this.onSignUpTap,
  });

  final AuthController controller;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final bool canGoBack;
  final VoidCallback onContinueOffline;
  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Center(
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
          const Text('Email address', style: DzTextStyles.label),
          const SizedBox(height: DzSpacing.sm),
          DzTextField(
            controller: emailCtrl,
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              size: 20,
            ),
            onChanged: (_) => controller.clearError(),
          ),
          const SizedBox(height: DzSpacing.md),

          // ── Password ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Password', style: DzTextStyles.label),
              GestureDetector(
                onTap: onForgotPassword,
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
            controller: passwordCtrl,
            hint: '••••••••',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: onToggleObscurePassword,
            ),
            onSubmitted: (_) => onSubmit(),
            onChanged: (_) => controller.clearError(),
          ),

          // ── Error ───────────────────────────────────
          if (controller.error != null) ...[
            const SizedBox(height: DzSpacing.sm),
            Text(
              controller.error!,
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
            isLoading: controller.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: DzSpacing.lg),

          // ── OR divider + Continue Offline ────────
          if (!canGoBack) ...[
            const AuthOrDivider(label: 'OR'),
            const SizedBox(height: DzSpacing.lg),
            DzSecondaryButton(
              label: 'Continue Offline',
              icon: const Icon(
                Icons.cloud_off_rounded,
                size: 18,
              ),
              onPressed: onContinueOffline,
            ),
          ],
          const SizedBox(height: DzSpacing.xl),

          // ── Sign Up link ────────────────────────────
          Center(
            child: _SignUpLink(onTap: onSignUpTap),
          ),
        ],
      ),
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
