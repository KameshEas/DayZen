import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
          context.pop();
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
      builder: (_) => _AccentPickerSheet(ctrl: ctrl),
    );
  }
}

/// Enhanced accent picker with live preview and spring-physics selection.
class _AccentPickerSheet extends StatefulWidget {
  const _AccentPickerSheet({required this.ctrl});
  final SettingsController ctrl;

  @override
  State<_AccentPickerSheet> createState() => _AccentPickerSheetState();
}

class _AccentPickerSheetState extends State<_AccentPickerSheet>
    with SingleTickerProviderStateMixin {
  late String _previewAccent;
  late AnimationController _scaleController;
  late Map<String, Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _previewAccent = widget.ctrl.accent;
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _buildScaleAnimations();
  }

  void _buildScaleAnimations() {
    _scaleAnimations = {
      for (var opt in SettingsController.accentOptions)
        opt: Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        ),
    };
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onAccentTap(String accent) {
    HapticFeedback.lightImpact();
    setState(() => _previewAccent = accent);
    _scaleController.forward(from: 0);
  }

  void _onAccentConfirm() {
    widget.ctrl.setAccent(_previewAccent);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          // Live preview card
          Container(
            padding: const EdgeInsets.all(DzSpacing.md),
            decoration: BoxDecoration(
              color: SettingsController.accentColorMap[_previewAccent]
                  ?.withValues(alpha: 0.1),
              border: Border.all(
                color: SettingsController.accentColorMap[_previewAccent]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(DzRadius.card),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: SettingsController.accentColorMap[_previewAccent],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: DzSpacing.sm),
                Text(
                  'Preview: $_previewAccent',
                  style: DzTextStyles.caption.copyWith(
                    color: SettingsController.accentColorMap[_previewAccent],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.md),
          // Swatch list
          ...SettingsController.accentOptions.map((opt) {
            final color = SettingsController.accentColorMap[opt]!;
            final isSelected = opt == _previewAccent;
            return Padding(
              padding: const EdgeInsets.only(bottom: DzSpacing.sm),
              child: AnimatedBuilder(
                animation: _scaleAnimations[opt]!,
                builder: (context, child) => Transform.scale(
                  scale: isSelected ? _scaleAnimations[opt]!.value : 1.0,
                  child: GestureDetector(
                    onTap: () => _onAccentTap(opt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DzSpacing.md,
                        vertical: DzSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? color : DzColors.borderLight,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(DzRadius.button),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: DzSpacing.md),
                          Expanded(
                            child: Text(opt, style: DzTextStyles.body),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded,
                                color: color, size: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: DzSpacing.md),
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onAccentConfirm,
              child: const Text('Apply Theme'),
            ),
          ),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}


