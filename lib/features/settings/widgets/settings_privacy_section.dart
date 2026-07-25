import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/design_system/design_system.dart';
import '../../app_data.dart';
import '../../biometric/biometric_setup_guide_page.dart';
import '../settings_controller.dart';
import 'settings_shared_widgets.dart';

/// The "PRIVACY" card on the Settings page â€” biometric lock, data export,
/// and clear-history.
class SettingsPrivacySection extends StatelessWidget {
  const SettingsPrivacySection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionLabel('PRIVACY'),
        const SizedBox(height: DzSpacing.sm),
        DzCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (ctrl.deviceHasBiometrics) ...[
                SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  iconBg: const Color(0xFFFEE2E2),
                  iconColor: DzColors.error,
                  title: 'Biometric Lock',
                  subtitle: ctrl.biometricLabel,
                  onTap: () => _showBiometricSheet(context, ctrl),
                ),
                const SettingsDivider(),
              ],
              SettingsTile(
                icon: Icons.download_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'Data Export',
                subtitle: 'Export as JSON or CSV',
                onTap: () => _exportData(context),
              ),
              const SettingsDivider(),
              SettingsTile(
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
      ],
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
              final tasks = TaskScope.of(context);
              final journal = JournalScope.of(context);
              await tasks.clearAll();
              await journal.clearAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All history cleared.')),
                );
              }
            },
            child: const Text('Clear',
                style: TextStyle(color: DzColors.error)),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) {
    final export = {
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': TaskScope.of(context).all.map((t) => t.toJson()).toList(),
      'journal': JournalScope.of(context).all.map((e) => e.toJson()).toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(export);

    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data copied to clipboard as JSON.')),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Biometric sheet â€” requests real biometric auth before enabling
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
          const SettingsSheetHandle(),
          const SizedBox(height: DzSpacing.md),
          Text('Biometric Lock',
              style: DzTextStyles.heading3
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: DzSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Enable Biometric Lock', style: DzTextStyles.body),
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

