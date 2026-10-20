import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Text/badge shared widgets used across onboarding slides. Split out of
// onboarding_shared_widgets.dart, which exceeded the Phase 5.1 ~300-line
// target — see docs/DEVELOPMENT_PLAN.md and
// onboarding_decoration_widgets.dart (the other half of that split).
// ─────────────────────────────────────────────────────────────────────────────

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
          style: TextStyle(
            fontFamily: 'InterDisplay',
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.15,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: DzSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: DzTextStyles.body.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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

enum OnboardingPillStyle { gray, green, blue, amber, purple, red, teal }

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

  Color _getBackgroundColor(OnboardingPillStyle style) {
    switch (style) {
      case OnboardingPillStyle.green:
        return DzColors.zenGreen.withValues(alpha: 0.15);
      case OnboardingPillStyle.blue:
        return DzColors.navy.withValues(alpha: 0.15);
      case OnboardingPillStyle.amber:
        return DzColors.sunriseDeep.withValues(alpha: 0.15);
      case OnboardingPillStyle.purple:
        return DzColors.lavender.withValues(alpha: 0.15);
      case OnboardingPillStyle.red:
        return DzColors.error.withValues(alpha: 0.15);
      case OnboardingPillStyle.teal:
        return DzColors.forestGreen.withValues(alpha: 0.15);
      case OnboardingPillStyle.gray:
        return DzColors.onboardingPillBg;
    }
  }

  Color _getTextColor(OnboardingPillStyle style) {
    switch (style) {
      case OnboardingPillStyle.green:
        return DzColors.zenGreen;
      case OnboardingPillStyle.blue:
        return DzColors.navy;
      case OnboardingPillStyle.amber:
        return DzColors.sunriseDeep;
      case OnboardingPillStyle.purple:
        return DzColors.lavender;
      case OnboardingPillStyle.red:
        return DzColors.error;
      case OnboardingPillStyle.teal:
        return DzColors.forestGreen;
      case OnboardingPillStyle.gray:
        return DzColors.slate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(style);
    final textColor = _getTextColor(style);
    final isGray = style == OnboardingPillStyle.gray;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: DzTextStyles.small.copyWith(
              color: isGray ? Theme.of(context).colorScheme.onSurface : textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: isGray ? 1.1 : 0.2,
            ),
          ),
        ],
      ),
    );
  }
}



