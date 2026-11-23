import 'package:flutter/material.dart';
import '../../../core/domain/quiet_window.dart';
import '../../../core/notification_service.dart';
import '../../../core/config/copy/close_day_copy.dart';
import '../../../core/services/gentle_prompts.dart';
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
                subtitle: _notificationSummary(context, ctrl),
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

  static String _time(BuildContext context, SettingsController ctrl, int minutes) =>
      MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
        alwaysUse24HourFormat: ctrl.use24Hour,
      );

  static String _notificationSummary(BuildContext context, SettingsController ctrl) {
    if (!ctrl.remindersEnabled) return 'Task reminders off';
    final w = ctrl.quietWindow;
    if (w == null) return 'Task reminders on';
    return 'Reminders on · quiet ${_time(context, ctrl, w.startMinutes)}–'
        '${_time(context, ctrl, w.endMinutes)}';
  }

  void _showNotificationSheet(BuildContext context, SettingsController ctrl) {
    final tasks = TaskScope.of(context);
    void apply() => tasks.applyReminderSettings(
          enabled: ctrl.remindersEnabled,
          quietWindow: ctrl.quietWindow,
        );
    // Close the Day and check-ins follow their own switches (and the quiet
    // window), independent of task reminders.
    void applyGentle() => GentlePrompts.instance?.apply();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) {
          final window = ctrl.quietWindow;
          final muted = Theme.of(ctx).colorScheme.onSurfaceVariant;

          Future<void> pickTime({required bool start}) async {
            final w = ctrl.quietWindow ?? QuietWindow.defaultWindow;
            final current = start ? w.startMinutes : w.endMinutes;
            final picked = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
              helpText: start ? 'Quiet hours start' : 'Quiet hours end',
              // Match the app's Units setting, not the phone's, so the
              // picker and the From/To rows show the same clock.
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: ctrl.use24Hour),
                child: child!,
              ),
            );
            if (picked == null) return;
            final minutes = picked.hour * 60 + picked.minute;
            ctrl.setQuietWindow(QuietWindow(
              startMinutes: start ? minutes : w.startMinutes,
              endMinutes: start ? w.endMinutes : minutes,
            ));
            apply();
            setSt(() {});
          }

          Future<void> pickCloseDayTime() async {
            final current = ctrl.closeDayMinute;
            final picked = await showTimePicker(
              context: ctx,
              initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
              helpText: 'Close your day prompt',
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(alwaysUse24HourFormat: ctrl.use24Hour),
                child: child!,
              ),
            );
            if (picked == null) return;
            ctrl.setCloseDayReminder(minuteOfDay: picked.hour * 60 + picked.minute);
            applyGentle();
            setSt(() {});
          }

          return SingleChildScrollView(
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
                  key: const Key('reminders-toggle'),
                  label: 'Task reminders',
                  value: ctrl.remindersEnabled,
                  onChanged: (v) {
                    ctrl.setRemindersEnabled(v);
                    apply();
                    setSt(() {});
                    // New installs are never prompted at startup (M-1.7),
                    // so turning reminders on is where the OS asks.
                    if (v) NotificationService.instance.requestPermission();
                  },
                ),
                Text('5 minutes before and when each task starts.',
                    style: DzTextStyles.caption.copyWith(color: muted)),
                const SizedBox(height: DzSpacing.md),
                SettingsToggleRow(
                  key: const Key('quiet-hours-toggle'),
                  label: 'Quiet hours',
                  value: window != null,
                  onChanged: ctrl.remindersEnabled
                      ? (v) {
                          ctrl.setQuietWindow(v ? QuietWindow.defaultWindow : null);
                          apply();
                          setSt(() {});
                        }
                      : null,
                ),
                Text(
                  'Reminders that fall inside quiet hours are skipped, '
                  'not delivered later.',
                  style: DzTextStyles.caption.copyWith(color: muted),
                ),
                if (window != null && ctrl.remindersEnabled) ...[
                  const SizedBox(height: DzSpacing.sm),
                  ListTile(
                    key: const Key('quiet-start'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('From'),
                    trailing: Text(_time(ctx, ctrl, window.startMinutes),
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    onTap: () => pickTime(start: true),
                  ),
                  ListTile(
                    key: const Key('quiet-end'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('To'),
                    trailing: Text(_time(ctx, ctrl, window.endMinutes),
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    onTap: () => pickTime(start: false),
                  ),
                ],
                const Divider(height: DzSpacing.xl),
                SettingsToggleRow(
                  key: const Key('close-day-toggle'),
                  label: CloseDayCopy.settingsReminder,
                  value: ctrl.closeDayEnabled,
                  onChanged: (v) {
                    ctrl.setCloseDayReminder(enabled: v);
                    applyGentle();
                    setSt(() {});
                  },
                ),
                Text(CloseDayCopy.settingsReminderHint,
                    style: DzTextStyles.caption.copyWith(color: muted)),
                if (ctrl.closeDayEnabled)
                  ListTile(
                    key: const Key('close-day-time'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('At'),
                    trailing: Text(_time(ctx, ctrl, ctrl.closeDayMinute),
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    onTap: pickCloseDayTime,
                  ),
                const SizedBox(height: DzSpacing.md),
                SettingsToggleRow(
                  key: const Key('checkins-toggle'),
                  label: 'Energy check-ins',
                  value: ctrl.checkinsEnabled,
                  onChanged: (v) {
                    ctrl.setCheckinsEnabled(v);
                    applyGentle();
                    setSt(() {});
                  },
                ),
                Text(
                  'At most two one-tap questions a day, outside quiet hours. '
                  'They pause by themselves if you ignore them for a few days.',
                  style: DzTextStyles.caption.copyWith(color: muted),
                ),
                const SizedBox(height: DzSpacing.lg),
              ],
            ),
          );
        },
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
