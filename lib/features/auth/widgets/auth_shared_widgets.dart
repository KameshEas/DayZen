import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

/// Small icon+label pill used on the Login page's trust-badge row.
class AuthTrustBadge extends StatelessWidget {
  const AuthTrustBadge({super.key, required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: DzSpacing.xs),
        Text(
          label,
          style: DzTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// "OR" / "or choose privacy"-style divider shared by the Login and
/// Sign Up cards.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label, this.italic = false});
  final String label;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Text(
            label,
            style: DzTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: italic ? null : 1.2,
              fontStyle: italic ? FontStyle.italic : null,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// A failed sign-in / sign-up, shown above the button: icon, tinted background
/// and the reason in full. Announced to screen readers as it appears.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.md, vertical: DzSpacing.sm + 2),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(DzRadius.button),
          border: Border.all(color: DzColors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.error_outline_rounded, size: 18, color: DzColors.error),
            ),
            const SizedBox(width: DzSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: DzTextStyles.caption.copyWith(
                  color: scheme.onErrorContainer,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round, bordered back button for the top of auth pages.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Back',
      button: true,
      child: Material(
        color: scheme.surface,
        shape: CircleBorder(side: BorderSide(color: scheme.outline)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: DzSizing.minTouchTarget,
            height: DzSizing.minTouchTarget,
            child: Icon(Icons.arrow_back_rounded, size: 20, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}
