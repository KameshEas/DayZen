import 'package:flutter/foundation.dart';
import '../../core/domain/planner_dates.dart';

/// The day the Planner is showing.
///
/// Held outside the page so that it survives switching tabs, and so the centre
/// "+" button (which lives in the shell, not in the Planner) can start a new task
/// on the day you are looking at instead of always on today.
class PlannerSelection extends ValueNotifier<DateTime> {
  PlannerSelection([DateTime? initial]) : super(dayOnly(initial ?? DateTime.now()));

  static final PlannerSelection instance = PlannerSelection();

  /// Back to today (also used when the app starts a new day).
  void reset([DateTime? now]) => value = dayOnly(now ?? DateTime.now());
}
