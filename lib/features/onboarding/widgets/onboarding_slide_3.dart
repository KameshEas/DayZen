import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_decoration_widgets.dart';
import 'onboarding_text_widgets.dart';

/// Slide 3 — "Ready to Plan Your Day?" (final)
class OnboardingSlide3 extends StatelessWidget {
  const OnboardingSlide3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          // Hero: task card with floating circular badges
          SizedBox(
            height: 240,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Center(
                  child: OnboardingWhiteCard(
                    width: 280,
                    height: 190,
                    child: Padding(
                      padding: EdgeInsets.all(DzSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OnboardingTaskLine(width: 140, color: DzColors.mutedBorder),
                          SizedBox(height: DzSpacing.sm),
                          OnboardingTaskLine(width: 180, color: DzColors.mutedBorder),
                          SizedBox(height: DzSpacing.sm),
                          OnboardingTaskLine(width: 110, color: DzColors.onboardingTaskLineTeal),
                        ],
                      ),
                    ),
                  ),
                ),
                // Green check — top right
                const Positioned(
                  top: 8,
                  right: 10,
                  child: OnboardingBadgeCircle(
                    size: 44,
                    color: DzColors.brightGreen,
                    icon: Icons.check_rounded,
                    iconColor: Colors.white,
                  ),
                ),
                // Blue clock — bottom right of card
                Positioned(
                  bottom: 14,
                  right: 42,
                  child: OnboardingBadgeCircle(
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.schedule_rounded,
                    iconColor: Colors.white,
                  ),
                ),
                // Small muted circle — left side
                const Positioned(
                  left: 6,
                  bottom: 46,
                  child: OnboardingBadgeCircle(
                    size: 34,
                    color: DzColors.primaryTint,
                    icon: Icons.done_all_rounded,
                    iconColor: DzColors.onboardingCardIcon,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const OnboardingSlideText(
            title: 'Ready to Plan\nYour Day?',
            subtitle: 'Start offline instantly or enable sync anytime.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const OnboardingPillBadge(
            icon: Icons.shield_rounded,
            label: 'YOUR DATA STAYS ON DEVICE',
            style: OnboardingPillStyle.gray,
          ),
        ],
      ),
    );
  }
}
