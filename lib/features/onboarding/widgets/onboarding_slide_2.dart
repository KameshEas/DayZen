import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_decoration_widgets.dart';
import 'onboarding_text_widgets.dart';

/// Slide 2 â€” "Your Data Stays With You"
class OnboardingSlide2 extends StatelessWidget {
  const OnboardingSlide2({
    super.key,
    required this.controller,
    required this.index,
  });

  final PageController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Column(
        children: [
          // Hero: two overlapping offset white cards
          SizedBox(
            height: 260,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Back card â€” slightly rotated left
                Positioned(
                  left: 20,
                  top: 0,
                  child: Transform.rotate(
                    angle: -0.06,
                    child: const OnboardingWhiteCard(
                      width: 200,
                      height: 230,
                      child: Center(
                        child: Icon(
                          Icons.phone_iphone_rounded,
                          size: 72,
                          color: DzColors.onboardingCardIcon,
                        ),
                      ),
                    ),
                  ),
                ),
                // Front card â€” bottom-right, lock icon
                Positioned(
                  right: 20,
                  bottom: 0,
                  child: OnboardingWhiteCard(
                    width: 160,
                    height: 160,
                    child: Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          const OnboardingSlideText(
            title: 'Your Data Stays\nWith You',
            subtitle:
                'Everything is stored locally. No tracking. No cloud by default. Experience productivity with total peace of mind.',
          ),
          const SizedBox(height: DzSpacing.lg),
          const OnboardingPillBadge(
            icon: Icons.verified_user_rounded,
            label: 'Offline-First Security',
            style: OnboardingPillStyle.green,
          ),
        ],
      ),
    );
  }
}



