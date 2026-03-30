import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import '../biometric/biometric_setup_guide_page.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = AppData.of(context).settings;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => Scaffold(
        backgroundColor: DzColors.appBackground,
        appBar: DzAppBar(
          title: 'Settings',
          automaticallyImplyLeading: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.md, vertical: DzSpacing.md),
          children: [
            // ── Privacy banner ────────────────────────────────────
            _PrivacyBanner(),
            const SizedBox(height: DzSpacing.lg),

            // ── PREFERENCES ──────────────────────────────────────
            _SectionLabel('PREFERENCES'),
            const SizedBox(height: DzSpacing.sm),
            DzCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Notification settings',
                    subtitle: ctrl.quietHours
                        ? 'Quiet hours, focus mode alerts'
                        : 'All notifications enabled',
                    onTap: () => _showNotificationSheet(context, ctrl),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.access_time_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Timezone',
                    subtitle:
                        'Auto-detecting (${DateTime.now().timeZoneName})',
                    onTap: () {},
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.grid_view_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Units',
                    subtitle: ctrl.unitsLabel,
                    onTap: () => _showUnitsSheet(context, ctrl),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DzSpacing.lg),

            // ── APPEARANCE ───────────────────────────────────────
            _SectionLabel('APPEARANCE'),
            const SizedBox(height: DzSpacing.sm),
            DzCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_rounded,
                    iconBg: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF6366F1),
                    title: 'Light/Dark Mode',
                    subtitle: ctrl.themeModeLabel,
                    onTap: () => _showThemeModeSheet(context, ctrl),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.palette_rounded,
                    iconBg: const Color(0xFFD1FAE5),
                    iconColor: DzColors.zenGreen,
                    title: 'Theme Accent',
                    subtitle: '${ctrl.accent} selected',
                    onTap: () => _showAccentSheet(context, ctrl),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.format_size_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Font size',
                    subtitle: ctrl.fontSize,
                    onTap: () =>
                        _showOptionSheet(context, 'Font Size',
                            SettingsController.fontSizeOptions, ctrl.fontSize,
                            (v) => ctrl.setFontSize(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DzSpacing.lg),

            // ── PRIVACY ──────────────────────────────────────────
            _SectionLabel('PRIVACY'),
            const SizedBox(height: DzSpacing.sm),
            DzCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  if (ctrl.deviceHasBiometrics) ...[
                    _SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: DzColors.error,
                      title: 'Biometric Lock',
                      subtitle: ctrl.biometricLabel,
                      onTap: () => _showBiometricSheet(context, ctrl),
                    ),
                    const _Divider(),
                  ],
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Data Export',
                    subtitle: 'Export as JSON or CSV',
                    onTap: () => _exportData(context),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: DzColors.error,
                    title: 'Clear History',
                    subtitle: 'Permanently delete logs',
                    onTap: () => _showClearHistoryDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DzSpacing.lg),

            // ── AI SETTINGS ──────────────────────────────────────
            _SectionLabel('AI SETTINGS'),
            const SizedBox(height: DzSpacing.sm),
            DzCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.auto_awesome_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'AI Personality',
                    subtitle: ctrl.aiPersonality,
                    onTap: () => _showOptionSheet(
                        context,
                        'AI Personality',
                        SettingsController.personalityOptions,
                        ctrl.aiPersonality,
                        (v) => ctrl.setAiPersonality(v)),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.auto_fix_high_rounded,
                    iconBg: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF6366F1),
                    title: 'Frequency of Tips',
                    subtitle: ctrl.tipFrequency,
                    onTap: () => _showOptionSheet(
                        context,
                        'Frequency of Tips',
                        SettingsController.tipFrequencyOptions,
                        ctrl.tipFrequency,
                        (v) => ctrl.setTipFrequency(v)),
                  ),
                  const _Divider(),
                  _SettingsTile(
                    icon: Icons.insights_rounded,
                    iconBg: Theme.of(context).colorScheme.primaryContainer,
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: 'Focus Analysis depth',
                    subtitle: ctrl.analysisDepth,
                    onTap: () => _showOptionSheet(
                        context,
                        'Focus Analysis Depth',
                        SettingsController.analysisDepthOptions,
                        ctrl.analysisDepth,
                        (v) => ctrl.setAnalysisDepth(v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DzSpacing.lg),

            // ── Footer ───────────────────────────────────────────
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: DzSpacing.xl),
                child: Text(
                  'DayZen Offline AI \u2022 Your data stays on this device.',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom sheets ────────────────────────────────────────────────────

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
      builder: (_) => _OptionListSheet<ThemeMode>(
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
            _SheetHandle(),
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

  void _showNotificationSheet(BuildContext context, SettingsController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: DzSpacing.md),
              Text('Notification Settings',
                  style: DzTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: DzSpacing.lg),
              _ToggleRow(
                label: 'Quiet Hours',
                value: ctrl.quietHours,
                onChanged: (v) {
                  ctrl.setQuietHours(v);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.md),
              _ToggleRow(
                label: 'Focus Mode Alerts',
                value: ctrl.focusAlerts,
                onChanged: (v) {
                  ctrl.setFocusAlerts(v);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitsSheet(BuildContext context, SettingsController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHandle(),
              const SizedBox(height: DzSpacing.md),
              Text('Units',
                  style: DzTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: DzSpacing.lg),
              _ToggleRow(
                label: 'Metric Units',
                value: ctrl.metricUnits,
                onChanged: (v) {
                  ctrl.setMetricUnits(v);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.md),
              _ToggleRow(
                label: '24-hour Clock',
                value: ctrl.use24Hour,
                onChanged: (v) {
                  ctrl.setUse24Hour(v);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showBiometricSheet(BuildContext context, SettingsController ctrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => _BiometricSheet(ctrl: ctrl),
    );
  }

  void _showOptionSheet(
    BuildContext context,
    String title,
    List<String> options,
    String current,
    ValueChanged<String> onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => _OptionListSheet<String>(
        title: title,
        options: options,
        selected: current,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DzRadius.card),
        ),
        title: const Text('Clear History'),
        content: const Text(
            'This will permanently delete all your task and journal logs. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final tasks = AppData.of(context).tasks;
              final journal = AppData.of(context).journal;
              await tasks.clearAll();
              await journal.clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All history cleared.')),
                );
              }
            },
            child: Text('Clear',
                style: TextStyle(color: DzColors.error)),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    final data = AppData.of(context);
    final export = {
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': data.tasks.all.map((t) => t.toJson()).toList(),
      'journal': data.journal.all.map((e) => e.toJson()).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(export);

    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data copied to clipboard as JSON.')),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Biometric sheet — requests real biometric auth before enabling
// ─────────────────────────────────────────────────────────────────────────────

class _BiometricSheet extends StatefulWidget {
  const _BiometricSheet({required this.ctrl});
  final SettingsController ctrl;

  @override
  State<_BiometricSheet> createState() => _BiometricSheetState();
}

class _BiometricSheetState extends State<_BiometricSheet> {
  final _auth = LocalAuthentication();
  bool _checking = false;
  String? _error;

  Future<void> _toggleBiometric(bool enable) async {
    if (!enable) {
      widget.ctrl.setBiometricEnabled(false);
      setState(() => _error = null);
      return;
    }

    setState(() {
      _checking = true;
      _error = null;
    });

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        setState(() {
          _checking = false;
          _error = 'Biometrics not available on this device.';
        });
        return;
      }

      // Check if the user has enrolled any biometrics
      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) {
        if (!mounted) return;
        setState(() => _checking = false);
        // Close the bottom sheet, then navigate to the setup guide
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const BiometricSetupGuidePage(),
          ),
        );
        return;
      }

      final didAuth = await _auth.authenticate(
        localizedReason: 'Verify your identity to enable biometric lock',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (didAuth) {
        widget.ctrl.setBiometricEnabled(true);
        setState(() => _checking = false);
      } else {
        setState(() {
          _checking = false;
          _error = 'Authentication failed. Try again.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = 'Biometric error: ${e.toString().split(': ').last}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: DzSpacing.md),
          Text('Biometric Lock',
              style: DzTextStyles.heading3
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: DzSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Enable Biometric Lock', style: DzTextStyles.body),
              if (_checking)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: widget.ctrl.biometricEnabled,
                  onChanged: _toggleBiometric,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: DzSpacing.sm),
            Text(_error!, style: DzTextStyles.caption.copyWith(color: DzColors.error)),
          ],
          if (widget.ctrl.biometricEnabled) ...[
            const SizedBox(height: DzSpacing.lg),
            Text('Lock after inactivity',
                style: DzTextStyles.caption
                    .copyWith(color: DzColors.textSecondary)),
            const SizedBox(height: DzSpacing.sm),
            Row(
              children: [1, 5, 10, 15].map((m) {
                final selected = widget.ctrl.lockTimeout == m;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.ctrl.setLockTimeout(m);
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      duration: DzDuration.fast,
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : DzColors.borderLight,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${m}m',
                        textAlign: TextAlign.center,
                        style: DzTextStyles.small.copyWith(
                          color: selected
                              ? DzColors.white
                              : DzColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: DzSpacing.lg),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: DzTextStyles.caption.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DzRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.md, vertical: DzSpacing.md),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DzTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: DzColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Divider(height: 1, color: DzColors.borderLight),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DzRadius.card),
        gradient: const LinearGradient(
          colors: [Color(0xFFC7D9C0), Color(0xFFA3C4A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Decorative plant icon
          Positioned(
            right: -8,
            bottom: -12,
            child: Opacity(
              opacity: 0.25,
              child: Icon(
                Icons.park_rounded,
                size: 130,
                color: const Color(0xFF2D6A4F),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(DzSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'System Version 2.4.0',
                  style: DzTextStyles.caption.copyWith(
                    color: const Color(0xFF3D5A3D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Privacy Protected',
                  style: DzTextStyles.heading2.copyWith(
                    color: const Color(0xFF1A3D1A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: DzColors.borderLight,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DzTextStyles.body),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

class _OptionListSheet<T> extends StatelessWidget {
  const _OptionListSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetHandle(),
          const SizedBox(height: DzSpacing.md),
          Text(title,
              style:
                  DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: DzSpacing.md),
          ...options.map((opt) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(opt, style: DzTextStyles.body),
                trailing: opt == selected
                    ? Icon(Icons.check_circle_rounded,
                        color: Theme.of(context).colorScheme.primary, size: 22)
                    : const Icon(Icons.circle_outlined,
                        color: DzColors.borderLight, size: 22),
                onTap: () => onSelect(opt),
              )),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}
