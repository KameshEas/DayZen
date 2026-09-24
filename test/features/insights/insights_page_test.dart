import 'package:dayzen/core/domain/task_analytics.dart';
import 'package:dayzen/core/services/jwt_auth_service.dart';
import 'package:dayzen/features/ai_optimization_controller.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights/insights_page.dart';
import 'package:dayzen/features/insights/widgets/insights_data.dart';
import 'package:dayzen/features/insights/widgets/insights_focus_trend_card.dart';
import 'package:dayzen/features/insights/widgets/insights_greeting.dart';
import 'package:dayzen/features/insights/widgets/insights_mindfulness_card.dart';
import 'package:dayzen/features/insights/widgets/insights_productivity_score_card.dart';
import 'package:dayzen/features/insights/widgets/insights_sync_indicator.dart';
import 'package:dayzen/features/insights/widgets/insights_top_category_card.dart';
import 'package:dayzen/features/insights_controller.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Sunday 20 Sep 2026: the last day of the week that starts Mon 14.
final _today = DateTime(2026, 9, 20);
DateTime _ago(int n) => DateTime(_today.year, _today.month, _today.day - n);

DzTask _task(
  DateTime date, {
  int hour = 9,
  int minutes = 60,
  bool done = true,
  TaskPriority priority = TaskPriority.routine,
  TaskCategory category = TaskCategory.work,
}) {
  final end = hour * 60 + minutes;
  return DzTask(
    id: '${date.day}-$hour-$priority-$category-$done',
    title: 't',
    startTime: TimeOfDay(hour: hour, minute: 0),
    endTime: TimeOfDay(hour: end ~/ 60, minute: end % 60),
    priority: priority,
    category: category,
    isCompleted: done,
    date: date,
  );
}

InsightsData _data(List<DzTask> tasks) =>
    InsightsData.fromTasks(tasks, journalCount: 0, now: _today);

class _SeededTasks extends TaskController {
  _SeededTasks(this._tasks);
  final List<DzTask> _tasks;
  @override
  List<DzTask> get all => _tasks;
}

Widget _host(Widget child) => MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

Widget _page(List<DzTask> tasks) => MaterialApp(
      home: AppScopes(
        tasks: _SeededTasks(tasks),
        journal: JournalController(),
        settings: SettingsController(),
        insights: InsightsController(),
        aiOptimization: AIOptimizationController(),
        notifications: NotificationController(),
        child: const Scaffold(body: InsightsPage()),
      ),
    );

void main() {
  group('greeting subtitle is drawn from real data', () {
    test('a streak of two or more days is celebrated with its real length', () {
      final d = _data([_task(_today), _task(_ago(1)), _task(_ago(2))]);
      expect(d.greetingSubtitle, "You're on a 3-day streak. Keep it going.");
    });

    test('it never claims a streak that does not exist', () {
      final d = _data([_task(_today, done: false)]);
      expect(d.greetingSubtitle, isNot(contains('streak')));
      expect(d.streakDays, 0);
    });

    test('says so when nothing is planned', () {
      expect(_data([]).greetingSubtitle, contains('Nothing planned'));
    });

    test('says where today stands', () {
      expect(_data([_task(_today, done: false)]).greetingSubtitle,
          '1 task planned for today. Start with one.');
      expect(
          _data([_task(_today, done: false), _task(_today, hour: 11, done: false)])
              .greetingSubtitle,
          '2 tasks planned for today. Start with one.');
      expect(
          _data([_task(_today), _task(_today, hour: 11, done: false)]).greetingSubtitle,
          '1 of 2 tasks done today. Keep going.');
      expect(_data([_task(_today)]).greetingSubtitle,
          "All 1 of today's tasks are done. Well done.");
    });
  });

  group('InsightsData', () {
    test('today summary uses singular and plural', () {
      expect(_data([]).todaySummary, isNull);
      expect(_data([_task(_today)]).todaySummary, '1 of 1 task done today');
      expect(_data([_task(_today), _task(_today, hour: 12, done: false)]).todaySummary,
          '1 of 2 tasks done today');
    });

    test('week focus total is the whole week, not just today', () {
      final d = _data([
        _task(_today, minutes: 30),
        _task(_ago(2), minutes: 60),
        _task(_ago(6), minutes: 90),
        _task(_ago(7), minutes: 500), // last week: excluded
      ]);
      expect(d.weekFocusMinutes, 180);
      expect(d.weekFocusLabel, '3h');
      expect(d.hasFocusTime, isTrue);
    });

    test('focus and completion charts are different data', () {
      final d = _data([
        _task(_today, minutes: 120),
        _task(_ago(1), minutes: 30),
        _task(_ago(1), hour: 12, minutes: 30, done: false),
      ]);
      expect(d.focusBars[6], 1.0); // Sunday: 120 of 120 minutes
      expect(d.focusBars[5], closeTo(0.25, 1e-9)); // Saturday: 30 of 120 minutes
      expect(d.completionBars[5], closeTo(0.5, 1e-9)); // Saturday: 1 of 2 tasks
      expect(d.focusBars, isNot(equals(d.completionBars)));
    });

    test('todayIndex marks Sunday as the last bar', () {
      expect(_data([]).todayIndex, 6);
    });

    test('there is no suggestion until there is a pattern', () {
      expect(_data([_task(_today), _task(_ago(1))]).suggestion, isNull);
    });

    test('the suggestion quotes the real numbers', () {
      final d = _data([
        _task(_today, hour: 8),
        _task(_ago(1), hour: 9),
        _task(_ago(2), hour: 10),
        _task(_ago(3), hour: 15),
      ]);
      expect(d.suggestion, contains('in the morning'));
      expect(d.suggestion, contains('3 of your last 4'));
    });

    test('top category and mindful progress come from the tasks', () {
      final d = _data([
        _task(_today, category: TaskCategory.study),
        _task(_today, hour: 11, category: TaskCategory.study),
        _task(_ago(1), priority: TaskPriority.zen, category: TaskCategory.mindful),
        _task(_ago(2), category: TaskCategory.mindful, done: false),
      ]);
      expect(d.topCategory!.category, TaskCategory.study);
      expect((d.mindfulDone, d.mindfulPlanned), (1, 2));
    });
  });

  group('small helpers', () {
    test('greets by first name, email name, or "there"', () {
      expect(InsightsGreeting.nameFor(null), 'there');
      expect(InsightsGreeting.nameFor(AuthUser(id: '1', email: 'a@b.co', name: 'Kamesh A S')), 'Kamesh');
      expect(InsightsGreeting.nameFor(AuthUser(id: '1', email: 'kamesh@b.co')), 'kamesh');
      expect(InsightsGreeting.nameFor(AuthUser(id: '1', email: 'kamesh@b.co', name: '  ')), 'kamesh');
    });

    test('rewords the sync status', () {
      String d(String s, {bool syncing = false}) =>
          InsightsSyncIndicator.describe(s, isSyncing: syncing);
      expect(d('Never synced'), 'Not synced yet');
      expect(d('Just now'), 'Synced just now');
      expect(d('5 min ago'), 'Synced 5 min ago');
      expect(d('Sync error'), "Couldn't sync");
      expect(d('5 min ago', syncing: true), 'Syncing…');
    });
  });

  group('cards', () {
    testWidgets('the score message is outside the ring, and nothing overflows on a narrow phone',
        (tester) async {
      tester.view.physicalSize = const Size(640, 1200); // 320 wide at 2x
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_host(InsightsProductivityScoreCard(data: _data([_task(_today)]))));

      expect(find.text('100'), findsOneWidget);
      expect(find.text('out of 100'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty week shows a hint instead of a blank chart', (tester) async {
      await tester.pumpWidget(_host(InsightsFocusTrendCard(data: _data([_task(_today, done: false)]))));
      expect(find.text('0m'), findsOneWidget);
      expect(find.textContaining('Complete a task'), findsOneWidget);
      // Seven day labels are still drawn.
      expect(find.text('MON'), findsOneWidget);
      expect(find.text('SUN'), findsOneWidget);
    });

    testWidgets('a week with focus time shows the total and no hint', (tester) async {
      await tester.pumpWidget(_host(InsightsFocusTrendCard(data: _data([_task(_today, minutes: 90)]))));
      expect(find.text('1h 30m'), findsOneWidget);
      expect(find.textContaining('Complete a task'), findsNothing);
    });

    testWidgets('top category is hidden when the week has no tasks', (tester) async {
      await tester.pumpWidget(_host(InsightsTopCategoryCard(data: _data([]))));
      expect(find.text('TOP CATEGORY'), findsNothing);
    });

    testWidgets('top category names the real category and its counts', (tester) async {
      await tester.pumpWidget(_host(InsightsTopCategoryCard(
        data: _data([
          _task(_today, category: TaskCategory.study),
          _task(_today, hour: 11, category: TaskCategory.study, done: false),
        ]),
      )));
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('1 of 2 tasks done this week'), findsOneWidget);
      expect(find.text('Health & Wellness'), findsNothing);
    });

    testWidgets('mindfulness says when none are planned', (tester) async {
      await tester.pumpWidget(_host(InsightsMindfulnessCard(data: _data([_task(_today)]))));
      expect(find.text('None planned this week'), findsOneWidget);
    });
  });

  group('the page', () {
    testWidgets('with no data it shows the empty state and no invented cards', (tester) async {
      await tester.pumpWidget(_page(const []));
      await tester.pump();

      expect(find.text('Create a Task'), findsOneWidget);
      expect(find.text('PRODUCTIVITY SCORE'), findsNothing);
      expect(find.textContaining('4 days'), findsNothing);
    });

    testWidgets('signed out, there is no sync status or "Sync now" button', (tester) async {
      await tester.pumpWidget(_page([_task(DateTime.now(), done: false)]));
      await tester.pump();

      expect(find.text('PRODUCTIVITY SCORE'), findsOneWidget);
      expect(find.text('Sync now'), findsNothing);
      expect(find.text('Insights Status'), findsNothing);
    });

    testWidgets('never shows the old made-up figures', (tester) async {
      await tester.pumpWidget(_page([_task(DateTime.now())]));
      await tester.pump();

      for (final invented in [
        'calm focus for 4 days',
        'Health & Wellness',
        'Adjust My Planner',
        'Deep Work',
      ]) {
        expect(find.textContaining(invented), findsNothing, reason: invented);
      }
    });
  });

  test('TaskAnalytics is used for the streak (sanity)', () {
    expect(TaskAnalytics.streakDays([_task(_today)], _today), 1);
  });
}
