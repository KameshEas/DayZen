import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Decorative shared widgets used across onboarding slides (cards, icon
// tiles, badges). Split out of onboarding_shared_widgets.dart, which
// exceeded the Phase 5.1 ~300-line target â€” see docs/DEVELOPMENT_PLAN.md.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// White elevated card container.
class OnboardingWhiteCard extends StatelessWidget {
  const OnboardingWhiteCard({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DzRadius.modal + 4),
        boxShadow: DzShadows.elevated,
      ),
      child: child,
    );
  }
}

/// Hero card shell (slide 1).
class OnboardingHeroCardShell extends StatelessWidget {
  const OnboardingHeroCardShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DzSpacing.xl,
        vertical: DzSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DzRadius.modal + 4),
        boxShadow: DzShadows.elevated,
      ),
      child: Center(child: child),
    );
  }
}

/// Square or circle icon tile (slide 1 hero).
class OnboardingIconTile extends StatelessWidget {
  const OnboardingIconTile({
    super.key,
    required this.color,
    required this.shape,
    required this.icon,
    required this.iconColor,
    this.radius = 0,
  });

  final Color color;
  final BoxShape shape;
  final IconData icon;
  final Color iconColor;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(radius)
            : null,
      ),
      child: Icon(icon, size: 52, color: iconColor),
    );
  }
}

/// Floating chip badge (slide 1, top-right of hero).
class OnboardingFloatingChip extends StatelessWidget {
  const OnboardingFloatingChip({
    super.key,
    required this.bgColor,
    required this.icon,
  });

  final Color bgColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: DzShadows.soft,
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

/// Circular floating badge (slide 3 hero).
class OnboardingBadgeCircle extends StatelessWidget {
  const OnboardingBadgeCircle({
    super.key,
    required this.size,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final double size;
  final Color color;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: DzShadows.soft,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.44),
    );
  }
}

/// Task skeleton line (slide 3 hero card).
class OnboardingTaskLine extends StatelessWidget {
  const OnboardingTaskLine({super.key, required this.width, required this.color});
  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

/// Animated dot page indicators.
class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({super.key, required this.total, required this.current});
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: DzDuration.fast,
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Theme.of(context).colorScheme.primary : DzColors.mutedBorder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}



