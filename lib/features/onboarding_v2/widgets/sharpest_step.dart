import 'package:flutter/material.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/rhythm/energy_profile.dart';
import '../onboarding_controller.dart';
import 'onboarding_scaffold.dart';

/// Step 2: "When are you sharpest?" — four options; the answer becomes the
/// Rhythm prior.
class SharpestStep extends StatelessWidget {
  const SharpestStep({super.key, required this.controller});
  final OnboardingController controller;

  static const _options = <(RhythmPrior, String, String, IconData)>[
    (RhythmPrior.morning, OnboardingV2Copy.sharpestMorning,
        OnboardingV2Copy.sharpestMorningHint, Icons.wb_twilight_rounded),
    (RhythmPrior.midday, OnboardingV2Copy.sharpestMidday,
        OnboardingV2Copy.sharpestMiddayHint, Icons.wb_sunny_outlined),
    (RhythmPrior.evening, OnboardingV2Copy.sharpestEvening,
        OnboardingV2Copy.sharpestEveningHint, Icons.nights_stay_outlined),
    (RhythmPrior.notSure, OnboardingV2Copy.sharpestNotSure,
        OnboardingV2Copy.sharpestNotSureHint, Icons.help_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return OnboardingStepFrame(
      stepNumber: 2,
      title: OnboardingV2Copy.sharpestTitle,
      body: OnboardingV2Copy.sharpestBody,
      onBack: c.back,
      actions: DzPrimaryButton(
        label: OnboardingV2Copy.next,
        onPressed: c.prior == null ? null : c.continueFromSharpest,
        width: double.infinity,
      ),
      child: Column(
        children: [
          for (final (prior, label, hint, icon) in _options) ...[
            _OptionCard(
              label: label,
              hint: hint,
              icon: icon,
              selected: c.prior == prior,
              onTap: () => c.choosePrior(prior),
            ),
            const SizedBox(height: DzSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '$label. $hint',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.10)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(DzRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(DzRadius.card),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(
                horizontal: DzSpacing.md, vertical: DzSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DzRadius.card),
              border: Border.all(
                color: selected ? scheme.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: selected ? scheme.primary : scheme.onSurfaceVariant),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: DzTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          )),
                      Text(hint,
                          style: DzTextStyles.caption
                              .copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
