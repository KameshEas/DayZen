import 'package:dayzen/core/domain/task_analytics.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Wednesday 16 Sep 2026; its week runs Mon 14 - Sun 20.
final _wed = DateTime(2026, 9, 16);

DzTask _task(
  DateTime date, {
  int startHour = 9,
  int minutes = 60,
  bool done = true,
  TaskPriority priority = TaskPriority.routine,
  TaskCategory category = TaskCategory.work,
}) {
  final end = startHour * 60 + minutes;
  return DzTask(
    id: '${date.microsecondsSinceEpoch}-$startHour-$priority-$category-$done',
    title: 't',
    startTime: TimeOfDay(hour: startHour, minute: 0),
    endTime: TimeOfDay(hour: end ~/ 60, minute: end % 60),
    priority: priority,
    category: category,
    isCompleted: done,
    date: date,
  );
}

DateTime _daysAgo(int n) => DateTime(_wed.year, _wed.month, _wed.day - n);

void main() {
  group('streakDays', () {
    test('counts consecutive days that each have a completed task', () {
      final tasks = [_task(_wed), _task(_daysAgo(1)), _task(_daysAgo(2))];
      expect(TaskAnalytics.streakDays(tasks, _wed), 3);
    });

    test('an unfinished today does not break the streak', () {
      final tasks = [_task(_wed, done: false), _task(_daysAgo(1)), _task(_daysAgo(2))];
      expect(TaskAnalytics.streakDays(tasks, _wed), 2);
    });

    test('a missed day ends it', () {
      final tasks = [_task(_wed), _task(_daysAgo(1)), _task(_daysAgo(3))];
      expect(TaskAnalytics.streakDays(tasks, _wed), 2);
    });

    test('is zero with no tasks, or with none completed', () {
      expect(TaskAnalytics.streakDays([], _wed), 0);
      expect(TaskAnalytics.streakDays([_task(_wed, done: false)], _wed), 0);
    });

    test('a streak that ended two days ago is over', () {
      expect(TaskAnalytics.streakDays([_task(_daysAgo(2))], _wed), 0);
    });

    test('several tasks in one day count as one day', () {
      final tasks = [_task(_wed), _task(_wed, startHour: 14), _task(_daysAgo(1))];
      expect(TaskAnalytics.streakDays(tasks, _wed), 2);
    });
  });

  group('week focus', () {
    test('sums completed minutes per weekday, Monday first', () {
      final tasks = [
        _task(DateTime(2026, 9, 14), minutes: 60),
        _task(DateTime(2026, 9, 14), startHour: 11, minutes: 30),
        _task(DateTime(2026, 9, 16), minutes: 45),
      ];
      expect(TaskAnalytics.weekFocusMinutes(tasks, _wed), [90, 0, 45, 0, 0, 0, 0]);
    });

    test('ignores unfinished tasks and other weeks', () {
      final tasks = [
        _task(DateTime(2026, 9, 14), done: false),
        _task(DateTime(2026, 9, 7)),
        _task(DateTime(2026, 9, 21)),
      ];
      expect(TaskAnalytics.weekFocusMinutes(tasks, _wed), everyElement(0));
    });

    test('fractions are relative to the busiest day', () {
      final tasks = [
        _task(DateTime(2026, 9, 14), minutes: 90),
        _task(DateTime(2026, 9, 15), minutes: 45),
      ];
      final f = TaskAnalytics.weekFocusFractions(tasks, _wed);
      expect(f[0], 1.0);
      expect(f[1], closeTo(0.5, 1e-9));
      expect(f.sublist(2), everyElement(0.0));
    });

    test('an empty week is all zeros, not NaN', () {
      expect(TaskAnalytics.weekFocusFractions([], _wed), everyElement(0.0));
    });

    test('a task that ends before it starts adds nothing', () {
      final t = DzTask(
        id: 'x',
        title: 't',
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 9, minute: 0),
        isCompleted: true,
        date: _wed,
      );
      expect(TaskAnalytics.weekFocusMinutes([t], _wed)[2], 0);
    });
  });

  group('formatMinutes', () {
    test('formats hours and minutes', () {
      expect(TaskAnalytics.formatMinutes(0), '0m');
      expect(TaskAnalytics.formatMinutes(45), '45m');
      expect(TaskAnalytics.formatMinutes(60), '1h');
      expect(TaskAnalytics.formatMinutes(95), '1h 35m');
    });
  });

  group('topCategory', () {
    test('is the category with the most completed tasks this week', () {
      final tasks = [
        _task(_wed, category: TaskCategory.work),
        _task(_wed, startHour: 11, category: TaskCategory.study),
        _task(_wed, startHour: 13, category: TaskCategory.study),
        _task(_wed, startHour: 15, category: TaskCategory.study, done: false),
      ];
      final top = TaskAnalytics.topCategory(tasks, _wed)!;
      expect(top.category, TaskCategory.study);
      expect((top.completed, top.planned), (2, 3));
      expect(top.fraction, closeTo(2 / 3, 1e-9));
    });

    test('falls back to the most planned when nothing is done yet', () {
      final tasks = [
        _task(_wed, done: false, category: TaskCategory.personal),
        _task(_wed, startHour: 11, done: false, category: TaskCategory.personal),
        _task(_wed, startHour: 13, done: false, category: TaskCategory.work),
      ];
      expect(TaskAnalytics.topCategory(tasks, _wed)!.category, TaskCategory.personal);
    });

    test('is null for a week with no tasks, and ignores other weeks', () {
      expect(TaskAnalytics.topCategory([], _wed), isNull);
      expect(TaskAnalytics.topCategory([_task(DateTime(2026, 9, 7))], _wed), isNull);
    });
  });

  group('mindfulProgress', () {
    test('counts zen-priority and mindful-category tasks once each', () {
      final tasks = [
        _task(_wed, priority: TaskPriority.zen),
        _task(_wed, startHour: 11, category: TaskCategory.mindful, done: false),
        _task(_wed, startHour: 13, priority: TaskPriority.zen, category: TaskCategory.mindful),
        _task(_wed, startHour: 15),
      ];
      final p = TaskAnalytics.mindfulProgress(tasks, _wed);
      expect((p.done, p.planned), (2, 3));
    });

    test('is 0 of 0 with none planned', () {
      final p = TaskAnalytics.mindfulProgress([_task(_wed)], _wed);
      expect((p.done, p.planned), (0, 0));
    });
  });

  group('peakWindow', () {
    List<DzTask> completed(List<int> hours) => [
          for (var i = 0; i < hours.length; i++) _task(_daysAgo(i), startHour: hours[i]),
        ];

    test('needs at least three completed tasks before saying anything', () {
      expect(TaskAnalytics.peakWindow(completed([9, 9]), _wed), isNull);
      expect(TaskAnalytics.peakWindow(completed([9, 9, 9]), _wed), isNotNull);
    });

    test('finds the part of the day with the most completions', () {
      final peak = TaskAnalytics.peakWindow(completed([8, 9, 10, 14]), _wed)!;
      expect(peak.part, DayPart.morning);
      expect((peak.completed, peak.total), (3, 4));
    });

    test('noon is afternoon and 5pm is evening', () {
      expect(TaskAnalytics.peakWindow(completed([12, 12, 12]), _wed)!.part, DayPart.afternoon);
      expect(TaskAnalytics.peakWindow(completed([17, 17, 17]), _wed)!.part, DayPart.evening);
    });

    test('ignores unfinished tasks and tasks older than the window', () {
      final tasks = [
        _task(_daysAgo(1), startHour: 20, done: false),
        _task(_daysAgo(2), startHour: 20, done: false),
        _task(_daysAgo(3), startHour: 20, done: false),
        _task(_daysAgo(40), startHour: 20),
        _task(_daysAgo(41), startHour: 20),
        _task(_daysAgo(42), startHour: 20),
      ];
      expect(TaskAnalytics.peakWindow(tasks, _wed), isNull);
    });
  });
}
