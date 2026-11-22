import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/settings_controller.dart';
import '../data/checkin_repository.dart';
import '../domain/rhythm/checkin_planner.dart';
import '../logging/app_logger.dart';
import '../notification_service.dart';
import 'counters_service.dart';

/// Applies the gentle, non-task prompts from Settings: the evening Close the
/// Day reminder (M-1.10) and the energy check-ins (M-2.5).
///
/// Call [apply] at startup, on resume and whenever a related setting
/// changes. It is idempotent: the same day always gives the same check-in
/// times, so re-applying never shuffles them.
class GentlePrompts {
  GentlePrompts({required this.settings, CheckinRepository? checkins})
      : _checkins = checkins ?? const CheckinRepository();

  /// Set once at startup by main.dart.
  static GentlePrompts? instance;

  final SettingsController settings;
  final CheckinRepository _checkins;

  static const _promptedDaysKey = 'checkin_prompted_days';
  static const _countedDayKey = 'checkin_prompts_counted_day';

  Future<void> apply({DateTime? now}) async {
    final at = now ?? DateTime.now();
    try {
      await NotificationService.instance.setCloseDayReminder(
        enabled: settings.closeDayEnabled,
        minuteOfDay: settings.closeDayMinute,
      );
      await NotificationService.instance.setCheckinPrompts(
        await checkinTimesFor(at),
      );
    } catch (e) {
      AppLogger.warning('Gentle prompts not applied: $e');
    }
  }

  /// Today's check-in prompts still ahead of [now] (empty when check-ins are
  /// off or paused). Records today as a prompted day.
  Future<List<DateTime>> checkinTimesFor(DateTime now) async {
    if (!settings.checkinsEnabled) return const [];
    final today = DateTime(now.year, now.month, now.day);
    final prefs = await SharedPreferences.getInstance();
    final prompted = _promptedDays(prefs);
    final answered =
        await _checkins.answeredDays(today.subtract(const Duration(days: 30)));
    final streak = CheckinPlanner.ignoredStreak(
      today: today,
      promptedDays: prompted,
      answeredDays: answered,
    );
    final ahead = CheckinPlanner.timesFor(
      day: today,
      quietWindow: settings.quietWindow,
      ignoredStreak: streak,
    ).where((t) => t.isAfter(now)).toList();

    if (ahead.isNotEmpty && !prompted.contains(today)) {
      await prefs.setStringList(_promptedDaysKey, [
        ...{...prompted, today}
            .where((d) => today.difference(d).inDays <= 30)
            .map((d) => d.toIso8601String()),
      ]);
    }
    if (ahead.isNotEmpty && prefs.getString(_countedDayKey) != today.toIso8601String()) {
      await prefs.setString(_countedDayKey, today.toIso8601String());
      await CountersService.instance
          .increment(CountersService.checkinPrompts, by: ahead.length);
    }
    return ahead;
  }

  /// Whether check-ins are currently paused for being ignored.
  Future<bool> isPaused({DateTime? now}) async {
    final at = now ?? DateTime.now();
    final today = DateTime(at.year, at.month, at.day);
    final prefs = await SharedPreferences.getInstance();
    final answered =
        await _checkins.answeredDays(today.subtract(const Duration(days: 30)));
    return CheckinPlanner.isPaused(CheckinPlanner.ignoredStreak(
      today: today,
      promptedDays: _promptedDays(prefs),
      answeredDays: answered,
    ));
  }

  static Set<DateTime> _promptedDays(SharedPreferences prefs) => {
        for (final s in prefs.getStringList(_promptedDaysKey) ?? const <String>[])
          ?DateTime.tryParse(s),
      };
}
