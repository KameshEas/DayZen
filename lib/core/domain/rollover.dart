import '../../features/home/models/task_model.dart';

/// Gentle Rollover: unfinished tasks from past days move to today instead of
/// piling up behind you.
///
/// Rules:
/// - Only `active` tasks dated before [today] move. Done and released tasks
///   stay on their day.
/// - The task's date becomes [today]. Its start and end times are kept.
/// - `rolloverCount` grows by one per calendar day missed, so a task left
///   for three days gains 3, the same as opening the app every day. It is
///   capped at [maxRolloverCount].
/// - `originalDate` is set to the old date the first time a task moves.
///
/// Days are counted on calendar dates, not 24-hour periods, so a daylight
/// saving change (a 23 or 25 hour day) never adds or loses a day. Running it
/// again on the same day changes nothing, and two devices that roll the same
/// task over get the same result, so sync sees no conflict.
class Rollover {
  Rollover._();

  static const int maxRolloverCount = 99;

  /// The tasks that change, already updated. Unchanged tasks are left out.
  static List<DzTask> apply(Iterable<DzTask> tasks, DateTime today) {
    final todayDate = _calendarDay(today);
    final moved = <DzTask>[];
    for (final task in tasks) {
      if (task.status != TaskStatus.active) continue;
      final missed = todayDate.difference(_calendarDay(task.date)).inDays;
      if (missed <= 0) continue;
      moved.add(task.copyWith(
        date: DateTime(today.year, today.month, today.day),
        rolloverCount:
            (task.rolloverCount + missed).clamp(0, maxRolloverCount),
        originalDate: task.originalDate ?? task.date,
      ));
    }
    return moved;
  }

  /// The date as a UTC midnight: day differences between two of these are
  /// always whole days, whatever the local time zone does.
  static DateTime _calendarDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
