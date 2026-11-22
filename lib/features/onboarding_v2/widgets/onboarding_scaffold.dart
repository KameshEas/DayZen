import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';

/// Shared frame for onboarding steps 1–4: back button, step dots, a
/// scrolling body and a pinned bottom action area.
class OnboardingStepFrame extends StatelessWidget {
  const OnboardingStepFrame({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.body,
    required this.child,
    required this.actions,
    this.onBack,
  });

  /// 1 to 4.
  final int stepNumber;
  final String title;
  final String body;
  final Widget child;
  final Widget actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.xs, DzSpacing.xs, DzSpacing.md, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: OnboardingV2Copy.back,
                  onPressed: onBack,
                ),
                const Spacer(),
                _StepDots(current: stepNumber),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  DzSpacing.lg, DzSpacing.sm, DzSpacing.lg, DzSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: DzTextStyles.heading1.copyWith(
                        fontSize: 26,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  Text(
                    body,
                    style: DzTextStyles.body.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DzSpacing.lg),
                  child,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.md),
            child: actions,
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: OnboardingV2Copy.stepLabel.replaceAll('{n}', '$current'),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 1; i <= 4; i++)
              AnimatedContainer(
                duration: DzDuration.fast,
                margin: const EdgeInsets.only(left: 6),
                width: i == current ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= current
                      ? scheme.primary
                      : scheme.onSurfaceVariant.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
