import 'package:dayzen/core/domain/rollover.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

DzTask task(
  String id,
  DateTime date, {
  TaskStatus status = TaskStatus.active,
  int rolloverCount = 0,
  DateTime? originalDate,
}) =>
    DzTask(
      id: id,
      title: id,
      startTime: const TimeOfDay(hour: 14, minute: 30),
      endTime: const TimeOfDay(hour: 15, minute: 15),
      status: status,
      rolloverCount: rolloverCount,
      originalDate: originalDate,
      date: date,
    );

void main() {
  final today = DateTime(2027, 1, 12, 7, 45); // first open of the day

  test("moves yesterday's unfinished task to today, keeping its time", () {
    final moved = Rollover.apply([task('a', DateTime(2027, 1, 11))], today);
    expect(moved, hasLength(1));
    final t = moved.single;
    expect(t.date, DateTime(2027, 1, 12));
    expect(t.rolloverCount, 1);
    expect(t.originalDate, DateTime(2027, 1, 11));
    expect(t.startTime, const TimeOfDay(hour: 14, minute: 30));
    expect(t.endTime, const TimeOfDay(hour: 15, minute: 15));
    expect(t.status, TaskStatus.active);
  });

  test('leaves today, future, done and released tasks alone', () {
    final moved = Rollover.apply([
      task('today', DateTime(2027, 1, 12)),
      task('future', DateTime(2027, 1, 20)),
      task('done', DateTime(2027, 1, 10), status: TaskStatus.done),
      task('released', DateTime(2027, 1, 10), status: TaskStatus.released),
    ], today);
    expect(moved, isEmpty);
  });

  test('a 3-day gap adds one per missed day', () {
    final moved = Rollover.apply([task('a', DateTime(2027, 1, 9))], today);
    expect(moved.single.rolloverCount, 3);
    expect(moved.single.originalDate, DateTime(2027, 1, 9));
  });

  test('keeps the first originalDate on later rollovers', () {
    final moved = Rollover.apply([
      task('a', DateTime(2027, 1, 11),
          rolloverCount: 4, originalDate: DateTime(2027, 1, 7)),
    ], today);
    expect(moved.single.rolloverCount, 5);
    expect(moved.single.originalDate, DateTime(2027, 1, 7));
  });

  test('the count is capped', () {
    final moved = Rollover.apply([
      task('a', DateTime(2026, 1, 1), rolloverCount: 90),
    ], today);
    expect(moved.single.rolloverCount, Rollover.maxRolloverCount);
  });

  test('is idempotent: a second resume the same day moves nothing', () {
    final first = Rollover.apply([task('a', DateTime(2027, 1, 10))], today);
    final again = Rollover.apply(first, today.add(const Duration(hours: 9)));
    expect(again, isEmpty);
  });

  test('two devices rolling the same task over agree', () {
    final original = task('a', DateTime(2027, 1, 10));
    final phoneA = Rollover.apply([original], DateTime(2027, 1, 12, 6));
    final phoneB = Rollover.apply([original], DateTime(2027, 1, 12, 23, 59));
    expect(phoneA.single.rolloverCount, phoneB.single.rolloverCount);
    expect(phoneA.single.date, phoneB.single.date);
    expect(phoneA.single.originalDate, phoneB.single.originalDate);
  });

  group('calendar days, not 24-hour periods', () {
    // Local DateTime arithmetic across a DST change gives 23- or 25-hour
    // days; counting must not. (Holds in any test-machine time zone.)
    test('spring-forward weekend counts 2 days', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 3, 27))], DateTime(2027, 3, 29, 0, 5));
      expect(moved.single.rolloverCount, 2);
    });

    test('fall-back weekend counts 2 days', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 10, 30))], DateTime(2027, 11, 1, 0, 5));
      expect(moved.single.rolloverCount, 2);
    });

    test('just after midnight counts as a new day', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 1, 11))], DateTime(2027, 1, 12, 0, 0, 1));
      expect(moved.single.rolloverCount, 1);
    });

    test('just before midnight is still the same day', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 1, 11))], DateTime(2027, 1, 11, 23, 59));
      expect(moved, isEmpty);
    });
  });

  group('travel (time zone change)', () {
    // Rollover compares the task's calendar date with the phone's current
    // calendar date, so only the local date after the trip matters, never
    // the elapsed hours.
    test('flying west and landing on the same calendar day moves nothing', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 1, 12))], DateTime(2027, 1, 12, 20));
      expect(moved, isEmpty);
    });

    test('flying east past midnight rolls over once', () {
      final moved = Rollover.apply(
          [task('a', DateTime(2027, 1, 12))], DateTime(2027, 1, 13, 9));
      expect(moved.single.rolloverCount, 1);
    });
  });
}
