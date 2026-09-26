/// The span of dates the Planner lets you browse, and the week arithmetic for
/// its swipeable week strip. Pure and clock-free (`today` is passed in), so it
/// is testable, and every calculation is calendar-based (`DateTime(y, m, d + n)`),
/// never `+ Duration(days: n)`, which lands on the wrong day across a daylight
/// saving change.
library;

/// Midnight of [d]: the date with no time.
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// The Monday of the week containing [d].
DateTime mondayOf(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// [d] moved by [days] calendar days.
DateTime addDays(DateTime d, int days) => DateTime(d.year, d.month, d.day + days);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// How far ahead you can plan.
const int plannerYearsAhead = 2;

/// Weeks of the Planner, Monday to Sunday: from the week you started using the
/// app to [plannerYearsAhead] years after [today].
class PlannerRange {
  PlannerRange._(this.firstDay, this.lastDay, this._firstMonday);

  /// [earliest] is the first day worth showing (when the user started, or their
  /// oldest task, whichever is older). A null or future [earliest] means
  /// "starting today".
  factory PlannerRange.from({required DateTime today, DateTime? earliest}) {
    final t = dayOnly(today);
    final start = earliest == null || dayOnly(earliest).isAfter(t) ? t : dayOnly(earliest);
    final last = DateTime(t.year + plannerYearsAhead, t.month, t.day);
    return PlannerRange._(start, last, mondayOf(start));
  }

  /// First and last selectable days.
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime _firstMonday;

  /// Number of weeks (pages of the strip).
  int get weekCount =>
      (dayOnly(addDays(mondayOf(lastDay), 7)).difference(_firstMonday).inHours / 24 / 7)
          .round();

  /// Monday of week [index] (0 is the first week).
  DateTime weekStart(int index) => addDays(_firstMonday, index * 7);

  /// The week (page) that holds [date], clamped into range.
  int weekIndexOf(DateTime date) {
    final days = (mondayOf(date).difference(_firstMonday).inHours / 24).round();
    return (days ~/ 7).clamp(0, weekCount - 1);
  }

  /// [date] moved into the selectable range.
  DateTime clamp(DateTime date) {
    final d = dayOnly(date);
    if (d.isBefore(firstDay)) return firstDay;
    if (d.isAfter(lastDay)) return lastDay;
    return d;
  }

  bool contains(DateTime date) {
    final d = dayOnly(date);
    return !d.isBefore(firstDay) && !d.isAfter(lastDay);
  }

  /// The same weekday as [selected], in week [index] (used when swiping weeks).
  DateTime sameWeekdayIn(int index, DateTime selected) =>
      clamp(addDays(weekStart(index), selected.weekday - 1));
}
