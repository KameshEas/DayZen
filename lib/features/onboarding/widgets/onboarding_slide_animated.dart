import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'onboarding_animations.dart';
import 'onboarding_text_widgets.dart';

/// Animated Slide 1 - Welcome
class AnimatedOnboardingSlideWelcome extends StatelessWidget {
  const AnimatedOnboardingSlideWelcome({
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
          // Illustration with parallax
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: const DzIllustrationWidget(
                illustration: DzIllustration.welcome,
                height: 260,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'Welcome to DayZen',
              subtitle:
                  'Your personal day optimizer. Plan, track, and optimize every moment for maximum focus and productivity.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.psychology_rounded,
              label: 'AI-POWERED INSIGHTS',
              style: OnboardingPillStyle.blue,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Slide 2 - Plan
class AnimatedOnboardingSlidePlan extends StatelessWidget {
  const AnimatedOnboardingSlidePlan({
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
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: ScaleFadeIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 100),
              child: const DzIllustrationWidget(
                illustration: DzIllustration.plan,
                height: 260,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'Smart Planning',
              subtitle:
                  'Set your priorities and let AI help you organize your day. Break down goals into actionable tasks.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.lightbulb_outline_rounded,
              label: 'INTELLIGENT SUGGESTIONS',
              style: OnboardingPillStyle.amber,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Slide 3 - Reflect
class AnimatedOnboardingSlideReflect extends StatelessWidget {
  const AnimatedOnboardingSlideReflect({
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
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: BounceIn(
              duration: const Duration(milliseconds: 900),
              delay: const Duration(milliseconds: 100),
              child: const DzIllustrationWidget(
                illustration: DzIllustration.reflect,
                height: 260,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'Daily Reflection',
              subtitle:
                  'Journal your thoughts and progress. Get insights into your patterns and growth over time.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.auto_awesome_rounded,
              label: 'MINDFUL JOURNALING',
              style: OnboardingPillStyle.purple,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Slide 4 - Grow
class AnimatedOnboardingSlideGrow extends StatelessWidget {
  const AnimatedOnboardingSlideGrow({
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
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: FloatingAnimation(
              duration: const Duration(milliseconds: 3500),
              child: ScaleFadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 100),
                child: const DzIllustrationWidget(
                  illustration: DzIllustration.grow,
                  height: 260,
                ),
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'Continuous Growth',
              subtitle:
                  'Build better habits and track your progress. Watch yourself improve day after day with real-time feedback.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.trending_up_rounded,
              label: 'HABIT TRACKING',
              style: OnboardingPillStyle.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Slide 5 - Privacy
class AnimatedOnboardingSlidePrivacy extends StatelessWidget {
  const AnimatedOnboardingSlidePrivacy({
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
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: BounceIn(
              duration: const Duration(milliseconds: 900),
              delay: const Duration(milliseconds: 100),
              child: const DzIllustrationWidget(
                illustration: DzIllustration.privacy,
                height: 260,
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'Your Privacy First',
              subtitle:
                  'Everything stays on your device. No tracking, no ads, no cloud by default. Your data is yours alone.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.lock_rounded,
              label: 'OFFLINE-FIRST SECURITY',
              style: OnboardingPillStyle.red,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Slide 6 - Ready (Final Slide)
class AnimatedOnboardingSlideReady extends StatelessWidget {
  const AnimatedOnboardingSlideReady({
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
          ParallaxIllustration(
            controller: controller,
            index: index,
            child: FloatingAnimation(
              duration: const Duration(milliseconds: 3000),
              child: ScaleFadeIn(
                duration: const Duration(milliseconds: 900),
                delay: const Duration(milliseconds: 100),
                curve: Curves.elasticOut,
                scale: 0.7,
                child: const DzIllustrationWidget(
                  illustration: DzIllustration.ready,
                  height: 260,
                ),
              ),
            ),
          ),
          const SizedBox(height: DzSpacing.xl),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingSlideText(
              title: 'All Set!',
              subtitle:
                  'You\'re ready to optimize your day. Let\'s get started and make the most of every moment.',
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            duration: const Duration(milliseconds: 800),
            child: const OnboardingPillBadge(
              icon: Icons.check_circle_rounded,
              label: 'READY TO BEGIN',
              style: OnboardingPillStyle.teal,
            ),
          ),
        ],
      ),
    );
  }
}
