import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Text/badge shared widgets used across onboarding slides. Split out of
// onboarding_shared_widgets.dart, which exceeded the Phase 5.1 ~300-line
// target â€” see docs/DEVELOPMENT_PLAN.md and
// onboarding_decoration_widgets.dart (the other half of that split).
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class OnboardingSlideText extends StatelessWidget {
  const OnboardingSlideText({
    super.key,
    required this.title,
    required this.subtitle,
    this.accent,
  });

  final String title;
  final String subtitle;
  final String? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'InterDisplay',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: DzColors.textPrimary,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DzSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: DzTextStyles.body.copyWith(
            color: DzColors.textSecondary,
            height: 1.6,
          ),
        ),
        if (accent != null) ...[
          const SizedBox(height: DzSpacing.xs),
          Text(
            accent!,
            textAlign: TextAlign.center,
            style: DzTextStyles.body.copyWith(
              color: DzColors.zenGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

enum OnboardingPillStyle { gray, green }

class OnboardingPillBadge extends StatelessWidget {
  const OnboardingPillBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final OnboardingPillStyle style;

  @override
  Widget build(BuildContext context) {
    final isGreen = style == OnboardingPillStyle.green;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: isGreen
            ? DzColors.zenGreen.withValues(alpha: 0.15)
            : DzColors.onboardingPillBg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isGreen ? DzColors.zenGreen : DzColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: DzTextStyles.small.copyWith(
              color: isGreen ? DzColors.zenGreen : DzColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: isGreen ? 0.2 : 1.1,
            ),
          ),
        ],
      ),
    );
  }
}



