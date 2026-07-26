import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import 'widgets/settings_account_section.dart';
import 'widgets/settings_ai_section.dart';
import 'widgets/settings_appearance_section.dart';
import 'widgets/settings_preferences_section.dart';
import 'widgets/settings_privacy_banner.dart';
import 'widgets/settings_privacy_section.dart';

/// Settings page — composes the individual section widgets under
/// features/settings/widgets/. Split from a single 1,048-line file in
/// Phase 5.1 of docs/DEVELOPMENT_PLAN.md; see that document for why the
/// section names here (Account/Preferences/Appearance/Privacy/AI) follow
/// the app's actual visible section headers rather than the plan's
/// original speculative names.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = SettingsScope.of(context);
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => Scaffold(
        backgroundColor: DzColors.appBackground,
        appBar: const DzAppBar(
          title: 'Settings',
          automaticallyImplyLeading: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.md, vertical: DzSpacing.md),
          children: [
            const SettingsPrivacyBanner(),
            const SizedBox(height: DzSpacing.lg),
            SettingsAccountSection(ctrl: ctrl),
            const SizedBox(height: DzSpacing.lg),
            SettingsPreferencesSection(ctrl: ctrl),
            const SizedBox(height: DzSpacing.lg),
            SettingsAppearanceSection(ctrl: ctrl),
            const SizedBox(height: DzSpacing.lg),
            SettingsPrivacySection(ctrl: ctrl),
            const SizedBox(height: DzSpacing.lg),
            SettingsAiSection(ctrl: ctrl),
            const SizedBox(height: DzSpacing.lg),
            _SettingsFooter(),
          ],
        ),
      ),
    );
  }
}

class _SettingsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: DzSpacing.xl),
        child: Text(
          AppConfig.settingsFooter,
          style: DzTextStyles.caption.copyWith(
            color: DzColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
