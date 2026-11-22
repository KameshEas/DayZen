import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';

/// Step 0: what DayZen does, and three ways forward.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.onBegin,
    required this.onRestore,
    required this.onSkip,
  });

  final VoidCallback onBegin;
  final VoidCallback onRestore;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(DzSpacing.sm),
              child: TextButton(
                onPressed: onSkip,
                child: const Text(OnboardingV2Copy.welcomeSkip),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: DzSpacing.xl),
                  const DzLogo(width: 150),
                  const SizedBox(height: DzSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      OnboardingV2Copy.welcomeTitle,
                      style: DzTextStyles.heading1.copyWith(
                        fontSize: 34,
                        height: 1.15,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.md),
                  Text(
                    OnboardingV2Copy.welcomeBody,
                    style: DzTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.md),
            child: Column(
              children: [
                DzPrimaryButton(
                  label: OnboardingV2Copy.welcomeBegin,
                  onPressed: onBegin,
                  width: double.infinity,
                ),
                const SizedBox(height: DzSpacing.sm),
                DzSecondaryButton(
                  label: OnboardingV2Copy.welcomeRestore,
                  onPressed: onRestore,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
