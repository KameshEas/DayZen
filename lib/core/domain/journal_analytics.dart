import '../../features/journal/models/journal_entry.dart';

/// Pure, stateless journal analytics.
///
/// Extracted from `JournalController` — see `TaskAnalytics` for the
/// rationale, which applies identically here.
class JournalAnalytics {
  JournalAnalytics._();

  /// Count of [entries] logged in the current calendar week (Mon–Sun).
  static int thisWeekCount(List<JournalEntry> entries) {
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return entries.where((e) {
      final d = e.timestamp;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(monday);
    }).length;
  }
}
