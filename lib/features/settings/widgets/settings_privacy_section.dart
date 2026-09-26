import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/app_prefs.dart';
import '../../../core/design_system/design_system.dart';
import '../../app_data.dart';
import '../../biometric/biometric_setup_guide_page.dart';
import '../../pin/pin_setup_page.dart';
import '../settings_controller.dart';
import 'settings_shared_widgets.dart';

/// The "PRIVACY" card on the Settings page â€” PIN lock, biometric lock, data
/// export, and clear-history.
class SettingsPrivacySection extends StatefulWidget {
  const SettingsPrivacySection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  State<SettingsPrivacySection> createState() => _SettingsPrivacySectionState();
}

class _SettingsPrivacySectionState extends State<SettingsPrivacySection> {
  bool _hasPin = false;
  bool _loadingPin = true;

  SettingsController get ctrl => widget.ctrl;

  @override
  void initState() {
    super.initState();
    _loadPinState();
  }

  Future<void> _loadPinState() async {
    final hasPin = await AppPrefs.hasPin();
    if (!mounted) return;
    setState(() {
      _hasPin = hasPin;
      _loadingPin = false;
    });
  }

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
              SettingsTile(
                icon: Icons.pin_rounded,
                iconBg: const Color(0xFFFEE2E2),
                iconColor: DzColors.error,
                title: 'PIN Lock',
                subtitle: _loadingPin
                    ? 'â€”'
                    : (_hasPin ? 'Enabled' : 'Disabled â€” app opens without a PIN'),
                onTap: _loadingPin ? () {} : () => _showPinLockSheet(context),
              ),
              const SettingsDivider(),
              if (_hasPin && ctrl.deviceHasBiometrics) ...[
                SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  iconBg: DzColors.errorTint,
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
                iconBg: DzColors.errorTint,
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

  void _showPinLockSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => _PinLockSheet(
        hasPin: _hasPin,
        onEnable: () async {
          final navigator = Navigator.of(context);
          final didSet = await navigator.push<bool>(
            MaterialPageRoute(
              builder: (_) => PinSetupPage(
                onPinSet: (ctx) => Navigator.of(ctx).pop(true),
              ),
            ),
          );
          if (didSet == true && mounted) {
            setState(() => _hasPin = true);
          }
        },
        onDisable: () async {
          await AppPrefs.clearPin();
          await AppPrefs.setPinOptedOut(true);
          // Biometric lock falls back to the PIN screen, so it can't stay
          // enabled once there's no PIN to fall back to.
          if (ctrl.biometricEnabled) {
            ctrl.setBiometricEnabled(false);
          }
          if (mounted) setState(() => _hasPin = false);
        },
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
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final tasks = TaskScope.of(context);
              final journal = JournalScope.of(context);
              ctx.pop();
              await DzProgress.run<void>(
                context,
                message: 'Clearing your history…',
                successMessage: 'History cleared',
                alwaysShow: true,
                task: () async {
                  await tasks.clearAll();
                  await journal.clearAll();
                },
              );
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
      String errorMsg = 'Biometric error. Please try again.';

      if (e.toString().contains('no_fragment_activity')) {
        errorMsg = 'Biometric setup required. Please restart the app.';
      } else if (e.toString().contains('NotEnrolledException')) {
        errorMsg = 'No biometric enrolled. Set up biometric in device settings.';
      } else if (e.toString().contains('HardwareUnavailableException')) {
        errorMsg = 'Biometric hardware not available.';
      }

      setState(() {
        _checking = false;
        _error = errorMsg;
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
                const DzSunLoader(width: 40)
              else
                Switch.adaptive(
                  value: widget.ctrl.biometricEnabled,
                  onChanged: _toggleBiometric,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: DzSpacing.md),
            Container(
              padding: const EdgeInsets.all(DzSpacing.md),
              decoration: BoxDecoration(
                color: DzColors.errorTint,
                borderRadius: BorderRadius.circular(DzRadius.card),
                border: Border.all(color: DzColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: DzColors.error, size: 20),
                  const SizedBox(width: DzSpacing.sm),
                  Expanded(
                    child: Text(
                      _error!,
                      style: DzTextStyles.caption.copyWith(color: DzColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (!widget.ctrl.biometricEnabled) ...[
            const SizedBox(height: DzSpacing.md),
            Container(
              padding: const EdgeInsets.all(DzSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DzRadius.card),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: DzSpacing.sm),
                  Expanded(
                    child: Text(
                      'Enable biometric to secure your data with face or fingerprint',
                      style: DzTextStyles.caption
                          .copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.ctrl.biometricEnabled) ...[
            const SizedBox(height: DzSpacing.lg),
            Text('Lock after inactivity',
                style: DzTextStyles.caption
                    .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                            : DzColors.appBackground,
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
                              : Theme.of(context).colorScheme.onSurfaceVariant,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PIN lock sheet â€” PIN is optional; lets the user turn it on (set a new
// PIN) or off (clear it) entirely.
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PinLockSheet extends StatefulWidget {
  const _PinLockSheet({
    required this.hasPin,
    required this.onEnable,
    required this.onDisable,
  });

  final bool hasPin;
  final Future<void> Function() onEnable;
  final Future<void> Function() onDisable;

  @override
  State<_PinLockSheet> createState() => _PinLockSheetState();
}

class _PinLockSheetState extends State<_PinLockSheet> {
  bool _busy = false;

  Future<void> _toggle(bool enable) async {
    if (enable) {
      // Closing the sheet first — PIN setup pushes its own full-screen page.
      Navigator.of(context).pop();
      await widget.onEnable();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DzRadius.card),
        ),
        title: const Text('Turn Off PIN Lock?'),
        content: const Text(
            'Anyone with access to your device will be able to open DayZen without entering a PIN.'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Turn Off', style: TextStyle(color: DzColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    await widget.onDisable();
    if (mounted) Navigator.of(context).pop();
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
          Text('PIN Lock',
              style: DzTextStyles.heading3
                  .copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: DzSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Require PIN to open DayZen', style: DzTextStyles.body),
              if (_busy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: widget.hasPin,
                  onChanged: _toggle,
                  activeTrackColor: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Container(
            padding: const EdgeInsets.all(DzSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DzRadius.card),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: DzSpacing.sm),
                Expanded(
                  child: Text(
                    'PIN Lock is optional. You can use DayZen without a PIN, or turn it '
                    'on any time to require a code before the app opens.',
                    style: DzTextStyles.caption
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DzSpacing.lg),
        ],
      ),
    );
  }
}

