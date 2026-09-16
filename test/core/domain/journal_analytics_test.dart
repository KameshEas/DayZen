import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/domain/journal_analytics.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';

void main() {
  JournalEntry entry({required String id, required DateTime timestamp}) =>
      JournalEntry(
        id: id,
        title: 'Entry $id',
        body: 'Body',
        mood: JournalMood.peaceful,
        timestamp: timestamp,
      );

  group('JournalAnalytics.thisWeekCount', () {
    test('returns 0 for no entries', () {
      expect(JournalAnalytics.thisWeekCount([]), 0);
    });

    test('counts only entries from today back to Monday', () {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final beforeMonday = monday.subtract(const Duration(days: 1));

      final entries = [
        entry(id: '1', timestamp: now),
        entry(id: '2', timestamp: monday),
        entry(id: '3', timestamp: beforeMonday),
      ];

      expect(JournalAnalytics.thisWeekCount(entries), 2);
    });
  });
}
