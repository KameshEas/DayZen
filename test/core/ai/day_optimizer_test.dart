import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/ai/day_optimizer.dart';
import 'package:dayzen/core/config/app_config.dart';
import 'package:dayzen/features/home/models/task_model.dart';

DzTask _task({
  required String id,
  required String title,
  TaskPriority priority = TaskPriority.routine,
  TaskCategory category = TaskCategory.work,
  bool isCompleted = false,
  TimeOfDay? start,
  TimeOfDay? end,
}) =>
    DzTask(
      id: id,
      title: title,
      // No scheduled times unless given — start == end so _estimateDuration
      // falls through to the priority-based default, matching how a task
      // created without a specific slot behaves.
      startTime: start ?? const TimeOfDay(hour: 0, minute: 0),
      endTime: end ?? start ?? const TimeOfDay(hour: 0, minute: 0),
      priority: priority,
      category: category,
      isCompleted: isCompleted,
    );

void main() {
  group('DayOptimizer.optimise', () {
    test('an empty day gets a friendly no-op result, not an empty crash', () {
      final result = DayOptimizer.optimise([]);

      expect(result.suggestions, isEmpty);
      expect(result.summary, contains('No tasks scheduled'));
      expect(result.focusTimeMinutes, 0);
      expect(result.breakRecommendation, isNotEmpty);
    });

    test('orders by priority: high, then zen, then routine, then low', () {
      final tasks = [
        _task(id: '1', title: 'Low', priority: TaskPriority.low),
        _task(id: '2', title: 'Routine', priority: TaskPriority.routine),
        _task(id: '3', title: 'High', priority: TaskPriority.high),
        _task(id: '4', title: 'Zen', priority: TaskPriority.zen),
      ];

      final result = DayOptimizer.optimise(tasks);

      expect(
        result.suggestions.map((s) => s.task.title).toList(),
        ['High', 'Zen', 'Routine', 'Low'],
      );
    });

    test('incomplete tasks are scheduled before completed ones, regardless of priority', () {
      final tasks = [
        _task(id: '1', title: 'Done but high', priority: TaskPriority.high, isCompleted: true),
        _task(id: '2', title: 'Pending but low', priority: TaskPriority.low),
      ];

      final result = DayOptimizer.optimise(tasks);

      expect(result.suggestions.first.task.title, 'Pending but low');
      expect(result.suggestions.last.task.title, 'Done but high');
      expect(result.suggestions.last.reason, contains('Already done'));
    });

    test('a task with real scheduled times keeps its own duration instead of the priority default', () {
      // 90 minutes, same as the high-priority default, so this alone isn't
      // conclusive — paired with the slot-label test below it confirms the
      // actual clock times (not just the duration) came from the task.
      final tasks = [
        _task(
          id: '1',
          title: 'Standup',
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 10, minute: 30),
        ),
      ];

      final result = DayOptimizer.optimise(tasks);

      // First slot always starts at AppConfig.optimizerStartHour regardless
      // of the task's own scheduled time — the optimizer repacks the day
      // from a fixed start, it doesn't preserve original clock times.
      expect(result.suggestions.single.suggestedSlot, '8:00 AM – 9:30 AM');
    });

    test('falls back to a priority-based default duration when start == end', () {
      final tasks = [_task(id: '1', title: 'Undated', priority: TaskPriority.zen)];

      final result = DayOptimizer.optimise(tasks);

      // 8:00 AM + zenDurationMinutes (60) = 9:00 AM.
      expect(result.suggestions.single.suggestedSlot, '8:00 AM – 9:00 AM');
    });

    test('back-to-back slots respect the gap after each task', () {
      final tasks = [
        _task(id: '1', title: 'First', priority: TaskPriority.high), // 90 min + 10 min gap
        _task(id: '2', title: 'Second', priority: TaskPriority.high),
      ];

      final result = DayOptimizer.optimise(tasks);

      expect(result.suggestions[0].suggestedSlot, '8:00 AM – 9:30 AM');
      // 9:30 + 10 min gap = 9:40 start, + 90 min = 11:10.
      expect(result.suggestions[1].suggestedSlot, '9:40 AM – 11:10 AM');
    });

    test('mindful category gets its own rationale even at routine/low priority', () {
      final tasks = [
        _task(id: '1', title: 'Meditate', priority: TaskPriority.routine, category: TaskCategory.mindful),
      ];

      final result = DayOptimizer.optimise(tasks);

      expect(result.suggestions.single.reason, contains('Mindful'));
    });

    test('all tasks complete gets the congratulatory summary, not a workload summary', () {
      final tasks = [_task(id: '1', title: 'Done', isCompleted: true)];

      final result = DayOptimizer.optimise(tasks);

      expect(result.summary, contains('exceptional focus'));
      expect(result.focusTimeMinutes, 0, reason: 'completed tasks do not count toward focus time');
    });

    test('more than two incomplete high-priority tasks triggers the front-loaded summary', () {
      final tasks = List.generate(
        3,
        (i) => _task(id: '$i', title: 'High $i', priority: TaskPriority.high),
      );

      final result = DayOptimizer.optimise(tasks);

      expect(result.summary, contains('front-loaded'));
    });

    test('a heavy but not high-priority-stacked day gets the "heavy day" summary', () {
      // 3 routine tasks with no scheduled times default to 30 min each = 90 min,
      // too short to cross the heavy-workload threshold (240) on their own —
      // use zen (60 min) x5 = 300 min instead, with at most 2 high-priority.
      final tasks = List.generate(
        5,
        (i) => _task(id: '$i', title: 'Zen $i', priority: TaskPriority.zen),
      );

      final result = DayOptimizer.optimise(tasks);

      expect(result.focusTimeMinutes, greaterThan(AppConfig.heavyWorkloadThresholdMinutes));
      expect(result.summary, contains('Heavy day ahead'));
    });

    test('a light day gets the balanced-day summary', () {
      final tasks = [_task(id: '1', title: 'One thing', priority: TaskPriority.low)];

      final result = DayOptimizer.optimise(tasks);

      expect(result.summary, contains('Balanced day'));
    });

    test('break recommendation escalates with total focus time', () {
      DayOptimizationResult forFocusMinutes(int focusMinutes) => DayOptimizer.optimise(
            List.generate(
              (focusMinutes / AppConfig.zenDurationMinutes).ceil(),
              (i) => _task(id: '$i', title: 'T$i', priority: TaskPriority.zen),
            ),
          );

      final light = forFocusMinutes(60);
      final medium = forFocusMinutes(AppConfig.breakRecommendationMediumThreshold + 30);
      final high = forFocusMinutes(AppConfig.breakRecommendationHighThreshold + 30);

      expect(light.breakRecommendation, AppConfig.breakRecommendationLight);
      expect(medium.breakRecommendation, AppConfig.breakRecommendationMedium);
      expect(high.breakRecommendation, AppConfig.breakRecommendationHigh);
    });
  });
}
