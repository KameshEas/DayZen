import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/domain/task_analytics.dart';
import 'package:dayzen/features/home/models/task_model.dart';

void main() {
  // A fixed Monday, so "week containing anchor" is deterministic across
  // every test run regardless of when the suite executes.
  final monday = DateTime(2026, 1, 5);

  DzTask task({
    required String id,
    required DateTime date,
    TaskPriority priority = TaskPriority.routine,
    bool isCompleted = false,
    int startHour = 9,
    int endHour = 10,
  }) =>
      DzTask(
        id: id,
        title: 'Task $id',
        startTime: TimeOfDay(hour: startHour, minute: 0),
        endTime: TimeOfDay(hour: endHour, minute: 0),
        priority: priority,
        isCompleted: isCompleted,
        date: date,
      );

  group('TaskAnalytics.completionFraction', () {
    test('returns 0 for a day with no tasks', () {
      expect(TaskAnalytics.completionFraction([], monday), 0);
    });

    test('returns 0.5 for 1 of 2 tasks completed', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true),
        task(id: '2', date: monday, isCompleted: false),
      ];
      expect(TaskAnalytics.completionFraction(tasks, monday), 0.5);
    });

    test('ignores tasks on other days', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true),
        task(id: '2', date: monday.add(const Duration(days: 1)), isCompleted: false),
      ];
      expect(TaskAnalytics.completionFraction(tasks, monday), 1.0);
    });
  });

  group('TaskAnalytics.score', () {
    test('is completionFraction * 100, rounded', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true),
        task(id: '2', date: monday, isCompleted: true),
        task(id: '3', date: monday, isCompleted: false),
      ];
      // 2/3 = 0.6666... -> 67
      expect(TaskAnalytics.score(tasks, monday), 67);
    });
  });

  group('TaskAnalytics.focusMinutes / focusLabel', () {
    test('sums duration of completed tasks only', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true, startHour: 9, endHour: 10), // 60m
        task(id: '2', date: monday, isCompleted: true, startHour: 14, endHour: 15, ), // 60m
        task(id: '3', date: monday, isCompleted: false, startHour: 16, endHour: 18), // not counted
      ];
      expect(TaskAnalytics.focusMinutes(tasks, monday), 120);
      expect(TaskAnalytics.focusLabel(tasks, monday), '2h 0m');
    });

    test('focusLabel is "0m" with no completed tasks', () {
      final tasks = [task(id: '1', date: monday, isCompleted: false)];
      expect(TaskAnalytics.focusLabel(tasks, monday), '0m');
    });

    test('focusLabel omits hours when under 60 minutes', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true, startHour: 9, endHour: 9),
      ];
      // same start/end hour with 0 duration would be 0m; use a 30-min-ish case instead
      final halfHourTask = DzTask(
        id: '2',
        title: 'Half hour',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 30),
        isCompleted: true,
        date: monday,
      );
      expect(TaskAnalytics.focusLabel([...tasks, halfHourTask], monday), '30m');
    });
  });

  group('TaskAnalytics.weekBarFractions', () {
    test('returns 7 fractions, one per day Mon–Sun', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true),
        task(id: '2', date: monday.add(const Duration(days: 3)), isCompleted: false),
      ];
      final fractions = TaskAnalytics.weekBarFractions(tasks, monday);
      expect(fractions, hasLength(7));
      expect(fractions[0], 1.0); // Monday: 1/1 completed
      expect(fractions[3], 0.0); // Thursday: 0/1 completed
      expect(fractions[1], 0.0); // Tuesday: no tasks -> 0
    });
  });

  group('TaskAnalytics.weekCompletedCount', () {
    test('counts completed tasks across the whole week', () {
      final tasks = [
        task(id: '1', date: monday, isCompleted: true),
        task(id: '2', date: monday.add(const Duration(days: 2)), isCompleted: true),
        task(id: '3', date: monday.add(const Duration(days: 6)), isCompleted: false),
        // Outside the week entirely:
        task(id: '4', date: monday.add(const Duration(days: 8)), isCompleted: true),
      ];
      expect(TaskAnalytics.weekCompletedCount(tasks, monday), 2);
    });
  });

  group('TaskAnalytics.topPriority', () {
    test('returns null for an empty week', () {
      expect(TaskAnalytics.topPriority([], monday), isNull);
    });

    test('returns the most frequent priority in the week', () {
      final tasks = [
        task(id: '1', date: monday, priority: TaskPriority.high),
        task(id: '2', date: monday, priority: TaskPriority.high),
        task(id: '3', date: monday, priority: TaskPriority.low),
      ];
      expect(TaskAnalytics.topPriority(tasks, monday), TaskPriority.high);
    });
  });

  group('TaskAnalytics.zenTasksThisWeek', () {
    test('filters to only zen-priority tasks within the week', () {
      final tasks = [
        task(id: '1', date: monday, priority: TaskPriority.zen),
        task(id: '2', date: monday, priority: TaskPriority.high),
        task(id: '3', date: monday.add(const Duration(days: 10)), priority: TaskPriority.zen),
      ];
      final zenTasks = TaskAnalytics.zenTasksThisWeek(tasks, monday);
      expect(zenTasks, hasLength(1));
      expect(zenTasks.single.id, '1');
    });
  });
}
