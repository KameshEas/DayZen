import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../auth_controller.dart';
import 'auth_shared_widgets.dart';

/// The white card on the Sign Up page — name/email/password fields,
/// create-account button, and (when not pushed from a canGoBack context)
/// the offline alternative.
class SignUpFormCard extends StatelessWidget {
  const SignUpFormCard({
    super.key,
    required this.controller,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscurePassword,
    required this.onSubmit,
    required this.canGoBack,
    required this.onContinueOffline,
  });

  final AuthController controller;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onSubmit;
  final bool canGoBack;
  final VoidCallback onContinueOffline;

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
          // ── Full Name ───────────────────────────────
          const Text('Full Name', style: DzTextStyles.label),
          const SizedBox(height: DzSpacing.sm),
          DzTextField(
            controller: nameCtrl,
            hint: 'Alex Doe',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(
              Icons.person_outline_rounded,
              size: 20,
            ),
            onChanged: (_) => controller.clearError(),
          ),
          const SizedBox(height: DzSpacing.md),

          // ── Email ───────────────────────────────────
          const Text('Email Address', style: DzTextStyles.label),
          const SizedBox(height: DzSpacing.sm),
          DzTextField(
            controller: emailCtrl,
            hint: 'alex@example.com',
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
          const Text('Password', style: DzTextStyles.label),
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
            suffixIcon: Semantics(
              label: obscurePassword ? 'Show password' : 'Hide password',
              button: true,
              enabled: true,
              onTap: onToggleObscurePassword,
              child: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                onPressed: onToggleObscurePassword,
              ),
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

          // ── Create Account button ───────────────────
          DzPrimaryButton(
            label: 'Create Account',
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: DzColors.white,
              size: 18,
            ),
            isLoading: controller.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: DzSpacing.lg),

          // ── "or choose privacy" divider ─────────────
          if (!canGoBack) ...[
            const AuthOrDivider(label: 'or choose privacy', italic: true),
            const SizedBox(height: DzSpacing.lg),
            DzSecondaryButton(
              label: 'Use Offline Instead',
              icon: const Icon(
                Icons.cloud_off_rounded,
                size: 18,
              ),
              onPressed: onContinueOffline,
            ),
          ],
        ],
      ),
    );
  }
}
