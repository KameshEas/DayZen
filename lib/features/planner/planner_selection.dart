import 'package:flutter/foundation.dart';
import '../../core/domain/planner_dates.dart';

/// The day the Planner is showing.
///
/// Held outside the page so that it survives switching tabs, and so the centre
/// "+" button (which lives in the shell, not in the Planner) can start a new task
/// on the day you are looking at instead of always on today.
class PlannerSelection extends ValueNotifier<DateTime> {
  PlannerSelection([DateTime? initial])
      // _lastKnownToday always tracks the real calendar day, independent of
      // whatever [initial] selection was passed in (e.g. a test or deep
      // link putting the selection on a future/past day from the start
      // must not be mistaken for a stale "today").
      : _lastKnownToday = dayOnly(DateTime.now()),
        super(dayOnly(initial ?? DateTime.now()));

  static final PlannerSelection instance = PlannerSelection();

  /// The calendar day this selection last considered "today". Used by
  /// [catchUpToToday] to tell a day that rolled over underneath a
  /// long-lived app session apart from a day the user deliberately browsed to.
  DateTime _lastKnownToday;

  /// Back to today (also used when the app starts a new day).
  void reset([DateTime? now]) {
    final today = dayOnly(now ?? DateTime.now());
    _lastKnownToday = today;
    value = today;
  }

  /// Call on app resume/launch: if the calendar day has moved on since this
  /// was last checked, and the selection was still tracking "today" (never
  /// deliberately changed to a different day), advance it to the new today.
  /// Without this, a session left open or backgrounded overnight keeps
  /// pointing at yesterday, and every task added via the "+" button silently
  /// gets planned for yesterday with the "any other day" default time.
  void catchUpToToday([DateTime? now]) {
    final today = dayOnly(now ?? DateTime.now());
    if (today == _lastKnownToday) return;
    final wasTrackingToday = value == _lastKnownToday;
    _lastKnownToday = today;
    if (wasTrackingToday) value = today;
  }
}
