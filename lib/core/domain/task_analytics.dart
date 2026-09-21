import '../../features/home/models/task_model.dart';

/// Pure, stateless task analytics — completion rates, focus time, and
/// weekly summaries derived from a list of tasks.
///
/// Extracted from `TaskController` (Phase 3.1 of docs/DEVELOPMENT_PLAN.md)
/// so business rules are testable in isolation from `ChangeNotifier`/state-
/// holding concerns. Every function takes the task list explicitly — no
/// hidden state, no controller dependency. `TaskController` keeps thin
/// delegating methods with the same names/signatures as before, so no UI
/// call site changes as a result of this extraction.
///
/// Note: this intentionally does its own private date/week filtering
/// (`_forDate`/`_forWeek`) rather than depending on
/// `TaskController.forDate`/`forWeek` — those remain controller-level UI
/// queries (see docs/DATABASE_SCHEMA.md's Phase 2.5 scoping note on why
/// they stay in-memory), while these are a separate, private computation
/// detail. A few lines of overlap between the two is preferable to coupling
/// a pure domain class back to the stateful controller it was extracted
/// out of.
class TaskAnalytics {
  TaskAnalytics._();

  static List<DzTask> _forDate(List<DzTask> tasks, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return tasks.where((t) => t.isSameDay(day)).toList()
      ..sort((a, b) {
        final am = a.startTime.hour * 60 + a.startTime.minute;
        final bm = b.startTime.hour * 60 + b.startTime.minute;
        return am.compareTo(bm);
      });
  }

  static List<DzTask> _forWeek(List<DzTask> tasks, DateTime weekStart) {
    final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
    return tasks.where((t) {
      final diff = t.date.difference(monday).inDays;
      return diff >= 0 && diff < 7;
    }).toList();
  }

  /// Completion fraction for [date] (0.0–1.0), scoped to [tasks].
  static double completionFraction(List<DzTask> tasks, DateTime date) {
    final dayTasks = _forDate(tasks, date);
    if (dayTasks.isEmpty) return 0;
    return dayTasks.where((t) => t.isCompleted).length / dayTasks.length;
  }

  /// Productivity score (0–100) for [date].
  static int score(List<DzTask> tasks, DateTime date) =>
      (completionFraction(tasks, date) * 100).round();

  /// Sum of completed-task durations for [date], in minutes.
  static int focusMinutes(List<DzTask> tasks, DateTime date) {
    int total = 0;
    for (final t in _forDate(tasks, date).where((t) => t.isCompleted)) {
      final start = t.startTime.hour * 60 + t.startTime.minute;
      final end = t.endTime.hour * 60 + t.endTime.minute;
      if (end > start) total += end - start;
    }
    return total;
  }

  /// Human-readable focus duration label (e.g. `"1h 30m"`, `"0m"`).
  static String focusLabel(List<DzTask> tasks, DateTime date) {
    final m = focusMinutes(tasks, date);
    if (m == 0) return '0m';
    final h = m ~/ 60;
    final mn = m % 60;
    return h > 0 ? '${h}h ${mn}m' : '${mn}m';
  }

  /// Completion fractions for each day Mon–Sun of the week containing
  /// [anchor].
  static List<double> weekBarFractions(List<DzTask> tasks, DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(
        7, (i) => completionFraction(tasks, monday.add(Duration(days: i))));
  }

  /// Count of completed tasks in the week containing [anchor].
  static int weekCompletedCount(List<DzTask> tasks, DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return _forWeek(tasks, monday).where((t) => t.isCompleted).length;
  }

  /// Most-used priority in the week containing [anchor] (or `null` if no
  /// tasks that week).
  static TaskPriority? topPriority(List<DzTask> tasks, DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    final weekTasks = _forWeek(tasks, monday);
    if (weekTasks.isEmpty) return null;
    final counts = <TaskPriority, int>{};
    for (final t in weekTasks) {
      counts[t.priority] = (counts[t.priority] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Zen (mindfulness) tasks in the week containing [anchor].
  static List<DzTask> zenTasksThisWeek(List<DzTask> tasks, DateTime anchor) {
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return _forWeek(tasks, monday)
        .where((t) => t.priority == TaskPriority.zen)
        .toList();
  }

  // ── Insights ─────────────────────────────────────────────────────────
  // Everything the Insights screen shows is computed here from the user's own
  // tasks; nothing on that screen is a placeholder.

  static DateTime _mondayOf(DateTime anchor) {
    final d = DateTime(anchor.year, anchor.month, anchor.day);
    return DateTime(d.year, d.month, d.day - (d.weekday - 1));
  }

  static int _minutes(DzTask t) {
    final start = t.startTime.hour * 60 + t.startTime.minute;
    final end = t.endTime.hour * 60 + t.endTime.minute;
    return end > start ? end - start : 0;
  }

  /// Consecutive days, ending [today], on which at least one task was
  /// completed. A day that isn't finished yet doesn't break the streak: if
  /// nothing is done today the count runs back from yesterday.
  static int streakDays(List<DzTask> tasks, DateTime today) {
    final done = <DateTime>{
      for (final t in tasks)
        if (t.isCompleted) t.date,
    };
    var day = DateTime(today.year, today.month, today.day);
    if (!done.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
    var count = 0;
    while (done.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  /// Completed focus minutes for each day Mon-Sun of the week containing
  /// [anchor].
  static List<int> weekFocusMinutes(List<DzTask> tasks, DateTime anchor) {
    final monday = _mondayOf(anchor);
    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      return tasks
          .where((t) => t.isCompleted && t.isSameDay(day))
          .fold<int>(0, (sum, t) => sum + _minutes(t));
    });
  }

  /// Each day's focus time as a fraction of the week's busiest day (0-1), so
  /// the tallest bar is always full. All zeros when nothing was completed.
  static List<double> weekFocusFractions(List<DzTask> tasks, DateTime anchor) {
    final minutes = weekFocusMinutes(tasks, anchor);
    final peak = minutes.fold<int>(0, (a, b) => b > a ? b : a);
    return [for (final m in minutes) peak == 0 ? 0.0 : m / peak];
  }

  /// "1h 30m" / "45m" / "0m".
  static String formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return h > 0 ? (m > 0 ? '${h}h ${m}m' : '${h}h') : '${m}m';
  }

  /// The category with the most completed tasks in the week containing
  /// [anchor]; if none are completed yet, the one with the most planned.
  /// Null when the week has no tasks.
  static CategoryStat? topCategory(List<DzTask> tasks, DateTime anchor) {
    final week = _forWeek(tasks, _mondayOf(anchor));
    if (week.isEmpty) return null;
    final stats = <TaskCategory, CategoryStat>{};
    for (final t in week) {
      final prev = stats[t.category];
      stats[t.category] = CategoryStat(
        t.category,
        (prev?.completed ?? 0) + (t.isCompleted ? 1 : 0),
        (prev?.planned ?? 0) + 1,
      );
    }
    final list = stats.values.toList()
      ..sort((a, b) {
        final byDone = b.completed.compareTo(a.completed);
        return byDone != 0 ? byDone : b.planned.compareTo(a.planned);
      });
    return list.first;
  }

  /// Mindful sessions (zen-priority or mindful-category tasks) in the week
  /// containing [anchor]: how many are done out of how many were planned.
  static ({int done, int planned}) mindfulProgress(
      List<DzTask> tasks, DateTime anchor) {
    final mindful = _forWeek(tasks, _mondayOf(anchor)).where(
      (t) =>
          t.priority == TaskPriority.zen || t.category == TaskCategory.mindful,
    );
    return (
      done: mindful.where((t) => t.isCompleted).length,
      planned: mindful.length,
    );
  }

  /// The part of the day in which the most tasks were completed over the last
  /// [days] days. Null until there are at least [minCompleted] completed tasks:
  /// a pattern from one or two tasks is noise, not advice.
  static PeakWindow? peakWindow(
    List<DzTask> tasks,
    DateTime today, {
    int days = 30,
    int minCompleted = 3,
  }) {
    final end = DateTime(today.year, today.month, today.day);
    final start = DateTime(end.year, end.month, end.day - days);
    final counts = <DayPart, int>{};
    var total = 0;
    for (final t in tasks) {
      if (!t.isCompleted || t.date.isBefore(start) || t.date.isAfter(end)) {
        continue;
      }
      final hour = t.startTime.hour;
      final part = hour < 12
          ? DayPart.morning
          : (hour < 17 ? DayPart.afternoon : DayPart.evening);
      counts[part] = (counts[part] ?? 0) + 1;
      total++;
    }
    if (total < minCompleted) return null;
    final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return PeakWindow(best.key, best.value, total);
  }
}

/// How one category fared in a week.
class CategoryStat {
  const CategoryStat(this.category, this.completed, this.planned);
  final TaskCategory category;
  final int completed;
  final int planned;

  /// Completed / planned (0-1).
  double get fraction => planned == 0 ? 0 : completed / planned;
}

enum DayPart { morning, afternoon, evening }

/// When in the day tasks most often get done.
class PeakWindow {
  const PeakWindow(this.part, this.completed, this.total);
  final DayPart part;

  /// Tasks completed in [part], out of [total] completed in the period.
  final int completed;
  final int total;
}
