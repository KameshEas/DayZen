import 'dart:math' as math;

import '../quiet_window.dart';

/// When to ask for energy check-ins (plan M-2.5). Pure Dart.
///
/// - At most [maxPerDay] prompts a day, at varied times between
///   [earliestMinute] and [latestMinute], at least [minGapMinutes] apart.
/// - Never inside the quiet window.
/// - Times vary day to day (seeded by the date, so the same day always gives
///   the same times and rescheduling is stable), so the model sees many
///   hours instead of the same two.
/// - Pauses itself after [pauseAfterIgnoredDays] days in a row where prompts
///   went out and nothing was answered. Any check-in resumes it.
class CheckinPlanner {
  CheckinPlanner._();

  static const maxPerDay = 2;
  static const earliestMinute = 9 * 60;
  static const latestMinute = 21 * 60;
  static const minGapMinutes = 3 * 60;
  static const pauseAfterIgnoredDays = 3;

  /// Days in a row, ending yesterday, that had prompts but no answer.
  /// [promptedDays] and [answeredDays] are local midnights.
  static int ignoredStreak({
    required DateTime today,
    required Set<DateTime> promptedDays,
    required Set<DateTime> answeredDays,
  }) {
    var streak = 0;
    var d = _day(today).subtract(const Duration(days: 1));
    for (var i = 0; i < 60; i++) {
      if (answeredDays.contains(d)) break;
      if (!promptedDays.contains(d)) break;
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static bool isPaused(int ignoredStreak) =>
      ignoredStreak >= pauseAfterIgnoredDays;

  /// Prompt times for [day] (empty when paused). Past times are kept: the
  /// caller decides what's still schedulable.
  static List<DateTime> timesFor({
    required DateTime day,
    QuietWindow? quietWindow,
    int ignoredStreak = 0,
  }) {
    if (isPaused(ignoredStreak)) return const [];
    final d = _day(day);
    final candidates = <int>[
      for (var m = earliestMinute; m <= latestMinute; m += 15)
        if (quietWindow == null || !quietWindow.contains(m ~/ 60, m % 60)) m,
    ];
    if (candidates.isEmpty) return const [];

    final rng = math.Random(d.year * 10000 + d.month * 100 + d.day);
    final chosen = <int>[];
    final pool = [...candidates]..shuffle(rng);
    for (final m in pool) {
      if (chosen.every((c) => (c - m).abs() >= minGapMinutes)) {
        chosen.add(m);
        if (chosen.length == maxPerDay) break;
      }
    }
    chosen.sort();
    return [
      for (final m in chosen) DateTime(d.year, d.month, d.day, m ~/ 60, m % 60),
    ];
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
}
