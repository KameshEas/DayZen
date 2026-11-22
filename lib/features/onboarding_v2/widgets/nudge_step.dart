import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';
import '../onboarding_controller.dart';
import 'onboarding_scaffold.dart';

/// Step 4: "Gentle nudge?" The system permission dialog only appears after
/// "Yes" (plan M-1.7).
class NudgeStep extends StatelessWidget {
  const NudgeStep({super.key, required this.controller});
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final scheme = Theme.of(context).colorScheme;
    return OnboardingStepFrame(
      stepNumber: 4,
      title: OnboardingV2Copy.nudgeTitle,
      body: OnboardingV2Copy.nudgeBody,
      onBack: c.saving ? null : c.back,
      actions: Column(
        children: [
          DzPrimaryButton(
            label: OnboardingV2Copy.nudgeYes,
            isLoading: c.saving && c.wantsNudge == true,
            onPressed: c.saving ? null : () => c.finish(wantsNudge: true),
            width: double.infinity,
          ),
          const SizedBox(height: DzSpacing.sm),
          DzSecondaryButton(
            label: OnboardingV2Copy.nudgeNo,
            isLoading: c.saving && c.wantsNudge == false,
            onPressed: c.saving ? null : () => c.finish(wantsNudge: false),
            width: double.infinity,
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xl),
          child: ExcludeSemantics(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.notifications_none_rounded,
                  size: 56, color: scheme.primary),
            ),
          ),
        ),
      ),
    );
  }
}
