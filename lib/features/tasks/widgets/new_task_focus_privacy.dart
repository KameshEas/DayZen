import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Current Focus card
// ─────────────────────────────────────────────────────────────────────────────

class CurrentFocusCard extends StatelessWidget {
  const CurrentFocusCard({
    super.key,
    required this.label,
    required this.initials,
    required this.color,
  });
  final String label;
  final String initials;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: DzDuration.normal,
      padding: const EdgeInsets.all(DzSpacing.md),
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
      ),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                initials,
                style: DzTextStyles.body.copyWith(
                  color: DzColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: DzSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT FOCUS',
                style: DzTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: DzTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: DzColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Privacy note
// ─────────────────────────────────────────────────────────────────────────────

class PrivacyNote extends StatelessWidget {
  const PrivacyNote({super.key, required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DzSpacing.md,
        vertical: DzSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: primary, size: 18),
          const SizedBox(width: DzSpacing.sm),
          Expanded(
            child: Text(
              'Your data is stored locally and stays private.',
              style: DzTextStyles.caption.copyWith(
                color: primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
