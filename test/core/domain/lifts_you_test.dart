import 'dart:math' as math;

import 'package:dayzen/core/domain/journal_analytics.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2027, 1, 1);

  JournalEntry entry(DateTime day, JournalMood mood,
          {String title = 'Note', int hour = 21}) =>
      JournalEntry(
        id: '${day.toIso8601String()}-$title-$hour',
        title: title,
        body: '',
        mood: mood,
        timestamp: DateTime(day.year, day.month, day.day, hour),
      );

  DzTask done(DateTime day, TaskCategory c) => DzTask(
        id: '${day.toIso8601String()}-${c.name}',
        title: c.label,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        category: c,
        status: TaskStatus.done,
        date: day,
      );

  /// [days] days: study done every other day and those days feel inspired;
  /// other days get a mixed mood.
  ({List<JournalEntry> entries, List<DzTask> tasks}) simulate(int days, {int seed = 1}) {
    final rng = math.Random(seed);
    final entries = <JournalEntry>[];
    final tasks = <DzTask>[];
    const others = [JournalMood.happy, JournalMood.peaceful, JournalMood.overwhelmed];
    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      tasks.add(done(day, TaskCategory.work));
      if (i.isEven) {
        tasks.add(done(day, TaskCategory.study));
        entries.add(entry(day, rng.nextDouble() < 0.8 ? JournalMood.inspired : JournalMood.peaceful));
      } else {
        entries.add(entry(day, others[rng.nextInt(others.length)]));
      }
    }
    return (entries: entries, tasks: tasks);
  }

  test('finds the real pattern: study days feel inspired', () {
    final d = simulate(30);
    final insights = JournalAnalytics.liftsYou(d.entries, d.tasks);
    expect(insights, isNotEmpty);
    final top = insights.first;
    expect(top.category, TaskCategory.study);
    expect(top.mood, JournalMood.inspired);
    expect(top.sentence, 'Study days tend to feel inspired.');
    expect(top.days, greaterThanOrEqualTo(JournalAnalytics.liftMinDays));
  });

  test('says nothing below the threshold (n < 8)', () {
    final d = simulate(13); // study on 7 days
    expect(JournalAnalytics.liftsYou(d.entries, d.tasks), isEmpty);
  });

  test('a category done every day has no lift over the baseline', () {
    final d = simulate(30);
    final work = JournalAnalytics.liftsYou(d.entries, d.tasks)
        .where((i) => i.category == TaskCategory.work);
    expect(work, isEmpty, reason: 'work days are all days: no difference to report');
  });

  test('never reports a negative mood, even when it is the strongest link', () {
    final entries = <JournalEntry>[];
    final tasks = <DzTask>[];
    for (var i = 0; i < 20; i++) {
      final day = start.add(Duration(days: i));
      if (i.isEven) {
        tasks.add(done(day, TaskCategory.personal));
        entries.add(entry(day, JournalMood.overwhelmed));
      } else {
        entries.add(entry(day, JournalMood.happy));
      }
    }
    final insights = JournalAnalytics.liftsYou(entries, tasks);
    expect(insights.where((i) => i.mood == JournalMood.overwhelmed), isEmpty);
  });

  test("a day's Close the Day reflection wins over other entries that day", () {
    final entries = <JournalEntry>[];
    final tasks = <DzTask>[];
    for (var i = 0; i < 20; i++) {
      final day = start.add(Duration(days: i));
      if (i.isEven) {
        tasks.add(done(day, TaskCategory.mindful));
        // A later plain note says overwhelmed; the reflection says peaceful.
        entries
          ..add(entry(day, JournalMood.peaceful, title: 'Evening reflection', hour: 20))
          ..add(entry(day, JournalMood.overwhelmed, hour: 23));
      } else {
        entries.add(entry(day, JournalMood.happy));
      }
    }
    final top = JournalAnalytics.liftsYou(entries, tasks).single;
    expect(top.category, TaskCategory.mindful);
    expect(top.mood, JournalMood.peaceful);
  });

  test('no entries, no insights', () {
    expect(JournalAnalytics.liftsYou(const [], [done(start, TaskCategory.study)]), isEmpty);
  });
}
