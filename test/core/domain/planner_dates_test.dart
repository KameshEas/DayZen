import 'package:dayzen/core/domain/planner_dates.dart';
import 'package:flutter_test/flutter_test.dart';

// Sunday 20 Sep 2026.
final _today = DateTime(2026, 9, 20);

void main() {
  group('date helpers', () {
    test('mondayOf finds the start of the week, across months and years', () {
      expect(mondayOf(DateTime(2026, 9, 20)), DateTime(2026, 9, 14)); // Sunday
      expect(mondayOf(DateTime(2026, 9, 14)), DateTime(2026, 9, 14)); // Monday itself
      expect(mondayOf(DateTime(2026, 10, 1)), DateTime(2026, 9, 28)); // into last month
      expect(mondayOf(DateTime(2027, 1, 1)), DateTime(2026, 12, 28)); // into last year
    });

    test('addDays is calendar arithmetic, not 24-hour steps', () {
      expect(addDays(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 1));
      expect(addDays(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 28));
      expect(addDays(DateTime(2028, 2, 28), 1), DateTime(2028, 2, 29)); // leap year
      expect(addDays(DateTime(2026, 9, 20), 0).hour, 0);
    });

    test('dayOnly drops the time, isSameDay compares dates only', () {
      expect(dayOnly(DateTime(2026, 9, 20, 23, 59)), DateTime(2026, 9, 20));
      expect(isSameDay(DateTime(2026, 9, 20, 1), DateTime(2026, 9, 20, 23)), isTrue);
      expect(isSameDay(DateTime(2026, 9, 20), DateTime(2026, 9, 21)), isFalse);
      expect(isSameDay(DateTime(2026, 9, 20), DateTime(2025, 9, 20)), isFalse);
    });
  });

  group('PlannerRange', () {
    test('with no start date it begins today', () {
      final r = PlannerRange.from(today: _today);
      expect(r.firstDay, _today);
    });

    test('begins on the start date, so earlier months can be browsed', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 3, 12, 15, 30));
      expect(r.firstDay, DateTime(2026, 3, 12));
      expect(r.contains(DateTime(2026, 4, 1)), isTrue);
      expect(r.contains(DateTime(2026, 3, 11)), isFalse);
    });

    test('a start date in the future is ignored', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2027, 1, 1));
      expect(r.firstDay, _today);
    });

    test('extends two years ahead of today', () {
      final r = PlannerRange.from(today: _today);
      expect(r.lastDay, DateTime(2028, 9, 20));
      expect(r.contains(DateTime(2027, 6, 1)), isTrue);
      expect(r.contains(DateTime(2028, 9, 21)), isFalse);
    });

    test('week pages run from the first week to the last week, Monday first', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 9, 1)); // a Tuesday
      expect(r.weekStart(0), DateTime(2026, 8, 31)); // that week's Monday
      expect(r.weekStart(1), DateTime(2026, 9, 7));
      expect(r.weekStart(0).weekday, DateTime.monday);
      expect(r.weekStart(r.weekCount - 1).weekday, DateTime.monday);
      // The last page holds the last selectable day.
      final last = r.weekStart(r.weekCount - 1);
      expect(!r.lastDay.isBefore(last) && r.lastDay.isBefore(addDays(last, 7)), isTrue);
    });

    test('weekIndexOf and weekStart agree for every day in range', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 1, 15));
      for (var d = r.firstDay; !d.isAfter(r.lastDay); d = addDays(d, 1)) {
        final i = r.weekIndexOf(d);
        final start = r.weekStart(i);
        expect(!d.isBefore(start) && d.isBefore(addDays(start, 7)), isTrue, reason: '$d');
      }
    });

    test('today is on a page that starts on the Monday of this week', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 1, 15));
      expect(r.weekStart(r.weekIndexOf(_today)), DateTime(2026, 9, 14));
    });

    test('clamp keeps a date inside the range', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 3, 12));
      expect(r.clamp(DateTime(2020, 1, 1)), DateTime(2026, 3, 12));
      expect(r.clamp(DateTime(2040, 1, 1)), DateTime(2028, 9, 20));
      expect(r.clamp(DateTime(2026, 9, 20, 14)), DateTime(2026, 9, 20));
    });

    test('swiping to another week keeps the same weekday', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 1, 15));
      final thisWeek = r.weekIndexOf(_today);
      // Sunday 20 Sep, swiped one week ahead, is Sunday 27 Sep.
      expect(r.sameWeekdayIn(thisWeek + 1, _today), DateTime(2026, 9, 27));
      // A Wednesday stays a Wednesday.
      expect(r.sameWeekdayIn(thisWeek - 1, DateTime(2026, 9, 16)), DateTime(2026, 9, 9));
    });

    test('swiping into the first, partial week never selects a day before the start', () {
      final r = PlannerRange.from(today: _today, earliest: DateTime(2026, 9, 3)); // a Thursday
      // Monday 31 Aug is in the first week but before the start.
      expect(r.sameWeekdayIn(0, DateTime(2026, 9, 14)), DateTime(2026, 9, 3));
    });

    test('starting today, the weeks still extend two years ahead', () {
      final r = PlannerRange.from(today: _today);
      expect(r.weekCount, greaterThan(100)); // two years ahead
      expect(r.weekIndexOf(_today), 0);
    });

    test('works across a year boundary', () {
      final r = PlannerRange.from(today: DateTime(2026, 12, 30), earliest: DateTime(2026, 12, 1));
      expect(r.weekStart(r.weekIndexOf(DateTime(2027, 1, 1))), DateTime(2026, 12, 28));
    });
  });
}
