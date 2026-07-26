import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/design_system/components/dz_illustration.dart';
import 'onboarding_decoration_widgets.dart';
import 'onboarding_text_widgets.dart';

/// Slide 1 â€” "DayZen / Plan simply. Stay focused."
class OnboardingSlide1 extends StatelessWidget {
  const OnboardingSlide1({super.key, required this.controller, required this.index});

  final PageController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          OnboardingParallax(
            controller: controller,
            index: index,
            child: const DzIllustrationWidget(
              illustration: DzIllustration.focusPlanning,
              height: 260,
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          OnboardingSlideText(
            title: 'DayZen',
            subtitle: AppConfig.onboardingSlide1Subtitle,
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



