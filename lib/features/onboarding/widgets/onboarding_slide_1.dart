import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_decoration_widgets.dart';
import 'onboarding_text_widgets.dart';

/// Slide 1 â€” "DayZen / Plan simply. Stay focused."
class OnboardingSlide1 extends StatelessWidget {
  const OnboardingSlide1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          OnboardingHeroCardShell(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OnboardingIconTile(
                      color: DzColors.onboardingIconTileBg,
                      shape: BoxShape.rectangle,
                      radius: 28,
                      icon: Icons.calendar_month_rounded,
                      iconColor: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: DzSpacing.md),
                    const OnboardingIconTile(
                      color: DzColors.brightGreen,
                      shape: BoxShape.circle,
                      icon: Icons.eco_rounded,
                      iconColor: Colors.white,
                    ),
                  ],
                ),
                const Positioned(
                  top: -20,
                  right: -28,
                  child: OnboardingFloatingChip(
                    bgColor: DzColors.warning,
                    icon: Icons.done_all_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const OnboardingSlideText(
            title: 'DayZen',
            subtitle: 'Plan simply. Stay focused.',
            accent: 'Live calm.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const OnboardingPillBadge(
            icon: Icons.shield_rounded,
            label: '100% OFFLINE AI',
            style: OnboardingPillStyle.gray,
          ),
        ],
      ),
    );
  }
}



