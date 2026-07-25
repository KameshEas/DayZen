import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../settings_controller.dart';
import 'settings_shared_widgets.dart';

/// The "APPEARANCE" card on the Settings page â€” theme mode, accent color,
/// and font size.
class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionLabel('APPEARANCE'),
        const SizedBox(height: DzSpacing.sm),
        DzCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconBg: DzColors.indigoTint,
                iconColor: DzColors.indigo,
                title: 'Light/Dark Mode',
                subtitle: ctrl.themeModeLabel,
                onTap: () => _showThemeModeSheet(context, ctrl),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.palette_rounded,
                iconBg: DzColors.successTint,
                iconColor: DzColors.zenGreen,
                title: 'Theme Accent',
                subtitle: '${ctrl.accent} selected',
                onTap: () => _showAccentSheet(context, ctrl),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.format_size_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'Font size',
                subtitle: ctrl.fontSize,
                onTap: () => showSettingsOptionSheet(
                    context,
                    'Font Size',
                    SettingsController.fontSizeOptions,
                    ctrl.fontSize,
                    (v) => ctrl.setFontSize(v)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showThemeModeSheet(BuildContext context, SettingsController ctrl) {
    final options = {
      'System default': ThemeMode.system,
      'Light': ThemeMode.light,
      'Dark': ThemeMode.dark,
    };
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => SettingsOptionListSheet<ThemeMode>(
        title: 'Theme Mode',
        options: options.keys.toList(),
        selected: options.entries
            .firstWhere((e) => e.value == ctrl.themeMode)
            .key,
        onSelect: (label) {
          ctrl.setThemeMode(options[label]!);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAccentSheet(BuildContext context, SettingsController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSheetHandle(),
            const SizedBox(height: DzSpacing.md),
            Text('Theme Accent',
                style:
                    DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: DzSpacing.md),
            ...SettingsController.accentOptions.map((opt) {
              final color = SettingsController.accentColorMap[opt]!;
              final isSelected = opt == ctrl.accent;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: DzColors.textPrimary, width: 2.5)
                        : null,
                  ),
                ),
                title: Text(opt, style: DzTextStyles.body),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: color, size: 22)
                    : const Icon(Icons.circle_outlined,
                        color: DzColors.borderLight, size: 22),
                onTap: () {
                  ctrl.setAccent(opt);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: DzSpacing.sm),
          ],
        ),
      ),
    );
  }
}


