import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../app_data.dart';
import '../settings_controller.dart';
import 'settings_shared_widgets.dart';

/// The "PREFERENCES" card on the Settings page — notification settings,
/// timezone, and units.
class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({super.key, required this.ctrl});

  final SettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionLabel('PREFERENCES'),
        const SizedBox(height: DzSpacing.sm),
        DzCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SettingsTile(
                icon: Icons.notifications_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'Notification settings',
                subtitle: ctrl.quietHours
                    ? 'Quiet hours, focus mode alerts'
                    : 'All notifications enabled',
                onTap: () => _showNotificationSheet(context, ctrl),
              ),
              const SettingsDivider(),
              SettingsTile(
                icon: Icons.access_time_rounded,
                iconBg: Theme.of(context).colorScheme.primaryContainer,
                iconColor: Theme.of(context).colorScheme.primary,
                title: 'Timezone',
                subtitle: 'Auto-detecting (${DateTime.now().timeZoneName})',
                onTap: () {},
              ),
              const SettingsDivider(),
              SettingsTile(
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
      ],
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
              const SettingsSheetHandle(),
              const SizedBox(height: DzSpacing.md),
              Text('Notification Settings',
                  style: DzTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: DzSpacing.lg),
              SettingsToggleRow(
                label: 'Quiet Hours',
                value: ctrl.quietHours,
                onChanged: (v) {
                  ctrl.setQuietHours(v);
                  _syncNotifications(context, ctrl);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.md),
              SettingsToggleRow(
                label: 'Focus Mode Alerts',
                value: ctrl.focusAlerts,
                onChanged: (v) {
                  ctrl.setFocusAlerts(v);
                  _syncNotifications(context, ctrl);
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

  /// Syncs the TaskController notification state with the current settings.
  void _syncNotifications(BuildContext context, SettingsController ctrl) {
    final enabled = ctrl.quietHours || ctrl.focusAlerts;
    TaskScope.of(context).setNotificationsEnabled(enabled);
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
              const SettingsSheetHandle(),
              const SizedBox(height: DzSpacing.md),
              Text('Units',
                  style: DzTextStyles.heading3
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: DzSpacing.lg),
              SettingsToggleRow(
                label: 'Metric Units',
                value: ctrl.metricUnits,
                onChanged: (v) {
                  ctrl.setMetricUnits(v);
                  setSt(() {});
                },
              ),
              const SizedBox(height: DzSpacing.md),
              SettingsToggleRow(
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
}
