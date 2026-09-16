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
              color: DzColors.textSecondary,
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
