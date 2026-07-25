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
}
