import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../auth_controller.dart';
import 'auth_shared_widgets.dart';

/// The white card on the Sign Up page: name, email and password, the reason a
/// sign-up failed (if it did), and the create-account button. The offline
/// alternative and the log-in link live on the page, outside the card.
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
  });

  final AuthController controller;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscurePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DzSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(DzRadius.modal),
        border: Border.all(color: scheme.outline),
        boxShadow: DzShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Full Name ───────────────────────────────
          const _FieldLabel('Full name'),
          DzTextField(
            controller: nameCtrl,
            hint: 'Alex Doe',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            onChanged: (_) => controller.clearError(),
          ),
          const SizedBox(height: DzSpacing.md),

          // ── Email ───────────────────────────────────
          const _FieldLabel('Email address'),
          DzTextField(
            controller: emailCtrl,
            hint: 'alex@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
            onChanged: (_) => controller.clearError(),
          ),
          const SizedBox(height: DzSpacing.md),

          // ── Password ────────────────────────────────
          const _FieldLabel('Password'),
          DzTextField(
            controller: passwordCtrl,
            hint: 'At least 6 characters',
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
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
            const SizedBox(height: DzSpacing.md),
            AuthErrorBanner(message: controller.error!),
          ],
          const SizedBox(height: DzSpacing.lg),

          // ── Create Account button ───────────────────
          DzPrimaryButton(
            label: 'Create account',
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            isLoading: controller.isLoading,
            loadingLabel: 'Creating account…',
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.sm),
      child: Text(
        text,
        style: DzTextStyles.label.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
