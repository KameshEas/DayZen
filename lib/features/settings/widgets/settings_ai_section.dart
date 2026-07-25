import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../settings_controller.dart';
import 'settings_shared_widgets.dart';

/// The "AI SETTINGS" card on the Settings page â€” AI personality, tip
/// frequency, and focus analysis depth.
class SettingsAiSection extends StatelessWidget {
  const SettingsAiSection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionLabel('AI SETTINGS'),
        const SizedBox(height: DzSpacing.sm),
        DzCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.auto_awesome_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'AI Personality',
                subtitle: ctrl.aiPersonality,
                onTap: () => showSettingsOptionSheet(
                    context,
                    'AI Personality',
                    SettingsController.personalityOptions,
                    ctrl.aiPersonality,
                    (v) => ctrl.setAiPersonality(v)),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.auto_fix_high_rounded,
                iconBg: DzColors.indigoTint,
                iconColor: DzColors.indigo,
                title: 'Frequency of Tips',
                subtitle: ctrl.tipFrequency,
                onTap: () => showSettingsOptionSheet(
                    context,
                    'Frequency of Tips',
                    SettingsController.tipFrequencyOptions,
                    ctrl.tipFrequency,
                    (v) => ctrl.setTipFrequency(v)),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.insights_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'Focus Analysis depth',
                subtitle: ctrl.analysisDepth,
                onTap: () => showSettingsOptionSheet(
                    context,
                    'Focus Analysis Depth',
                    SettingsController.analysisDepthOptions,
                    ctrl.analysisDepth,
                    (v) => ctrl.setAnalysisDepth(v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}



