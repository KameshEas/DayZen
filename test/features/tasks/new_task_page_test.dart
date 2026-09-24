import 'dart:async';

import 'package:dayzen/core/app_prefs.dart';
import 'package:dayzen/features/ai_optimization_controller.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights_controller.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:dayzen/core/domain/planner_dates.dart';
import 'package:dayzen/core/utils/date_formatter.dart';
import 'package:dayzen/features/tasks/new_task_page.dart';
import 'package:dayzen/features/tasks/widgets/new_task_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Counts saves, and can hold each one open (as a real database write does) or fail it.
class _CountingTasks extends TaskController {
  int added = 0;
  Completer<void>? hold;
  Object? failFirstWith;

  @override
  Future<void> addTask(DzTask task) async {
    added++;
    if (failFirstWith != null && added == 1) throw failFirstWith!;
    await hold?.future;
  }
}

Widget _pageWith(TaskController tasks) => MaterialApp(
      home: AppScopes(
        tasks: tasks,
        journal: JournalController(),
        settings: SettingsController(),
        insights: InsightsController(),
        aiOptimization: AIOptimizationController(),
        notifications: NotificationController(),
        child: const NewTaskPage(),
      ),
    );

void main() {
  group('defaultTaskTimes', () {
    String fmt((TimeOfDay, TimeOfDay) t) =>
        '${t.$1.hour}:${t.$1.minute.toString().padLeft(2, '0')}-'
        '${t.$2.hour}:${t.$2.minute.toString().padLeft(2, '0')}';
    final noon = DateTime(2026, 9, 20, 12, 15);

    test('today: the next full hour', () {
      expect(fmt(defaultTaskTimes(DateTime(2026, 9, 20), noon)), '13:00-14:00');
    });

    test('a later day: nine to ten in the morning, whatever time it is now', () {
      expect(fmt(defaultTaskTimes(DateTime(2026, 9, 21), noon)), '9:00-10:00');
      expect(fmt(defaultTaskTimes(DateTime(2027, 3, 1), DateTime(2026, 9, 20, 23, 50))), '9:00-10:00');
    });

    test('an earlier day is treated the same as a later one', () {
      expect(fmt(defaultTaskTimes(DateTime(2026, 9, 1), noon)), '9:00-10:00');
    });

    test('late in the evening it never wraps into the small hours of the same day', () {
      // The old code gave 00:00-01:00 here: hours before now, on the same date.
      expect(fmt(defaultTaskTimes(DateTime(2026, 9, 20), DateTime(2026, 9, 20, 22, 30))), '23:00-23:59');
      expect(fmt(defaultTaskTimes(DateTime(2026, 9, 20), DateTime(2026, 9, 20, 23, 30))), '23:00-23:59');
    });

    test('the end is always after the start', () {
      for (var h = 0; h < 24; h++) {
        final t = defaultTaskTimes(DateTime(2026, 9, 20), DateTime(2026, 9, 20, h, 5));
        final start = t.$1.hour * 60 + t.$1.minute;
        final end = t.$2.hour * 60 + t.$2.minute;
        expect(end, greaterThan(start), reason: 'hour $h');
      }
    });
  });

  group('NewTaskPage', () {
    // Wide enough for the placeholder font that widget tests draw text with (its
    // letters are full-width squares); what is under test here is dates, not layout.
    Future<void> phone(WidgetTester tester) async {
      tester.view.physicalSize = const Size(3000, 3600);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
    }

    testWidgets('opens on the date it is given', (tester) async {
      await phone(tester);
      final day = addDays(dayOnly(DateTime.now()), 40);
      await tester.pumpWidget(MaterialApp(home: NewTaskPage(initialDate: day)));

      final tile = tester.widget<ScheduledTile>(find.byType(ScheduledTile));
      expect(tile.label, startsWith(DateFormatter.formatTaskSchedule(day, 9, 0).split(' at ').first));
      // A day ahead defaults to 9 AM.
      expect(tile.label, endsWith('9:00 AM'));
    });

    testWidgets('with no date it means today', (tester) async {
      await phone(tester);
      await tester.pumpWidget(const MaterialApp(home: NewTaskPage()));
      expect(tester.widget<ScheduledTile>(find.byType(ScheduledTile)).label, startsWith('Today at'));
    });

    group('saving', () {
      testWidgets('a second tap while the first is still saving does not add a second task', (tester) async {
        await phone(tester);
        final tasks = _CountingTasks()..hold = Completer<void>();
        await tester.pumpWidget(_pageWith(tasks));
        await tester.enterText(find.byType(TextField).first, 'ffft');

        // Two quick taps, the second landing while the first save is still in flight.
        await tester.tap(find.text('Add to My Day'));
        await tester.pump();
        await tester.tap(find.text('Add to My Day'));
        await tester.pump();

        expect(tasks.added, 1);
      });

      testWidgets('the keyboard Done and the button together add it once', (tester) async {
        await phone(tester);
        final tasks = _CountingTasks()..hold = Completer<void>();
        await tester.pumpWidget(_pageWith(tasks));
        await tester.enterText(find.byType(TextField).first, 'ffft');

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        await tester.tap(find.text('Add to My Day'));
        await tester.pump();

        expect(tasks.added, 1);
      });

      testWidgets('an empty title saves nothing, and does not lock the button', (tester) async {
        await phone(tester);
        final tasks = _CountingTasks()..hold = Completer<void>();
        await tester.pumpWidget(_pageWith(tasks));

        await tester.tap(find.text('Add to My Day'));
        await tester.pump();
        expect(tasks.added, 0);

        await tester.enterText(find.byType(TextField).first, 'Now it has a title');
        await tester.tap(find.text('Add to My Day'));
        await tester.pump();
        expect(tasks.added, 1);
      });

      testWidgets('a save that fails can be tried again', (tester) async {
        await phone(tester);
        final tasks = _CountingTasks()
          ..failFirstWith = StateError('disk full')
          ..hold = Completer<void>();
        await tester.pumpWidget(_pageWith(tasks));
        await tester.enterText(find.byType(TextField).first, 'ffft');

        // The failure is rethrown so it is reported, not swallowed: catch it here.
        final errors = <Object>[];
        await runZonedGuarded(() async {
          await tester.tap(find.text('Add to My Day'));
          await tester.pump();
        }, (error, _) => errors.add(error));
        expect(errors.single, isA<StateError>());
        expect(tasks.added, 1);

        await tester.tap(find.text('Add to My Day'));
        await tester.pump();
        expect(tasks.added, 2, reason: 'the button was not left dead by the failure');
      });
    });

    for (final days in [-400, -10, -2, 0, 100, 800]) {
      testWidgets('the date picker opens for a task $days days from today', (tester) async {
        // The picker asserts that its initial date is inside its range. It used to
        // start the range at yesterday, so any earlier day crashed it.
        await phone(tester);
        final day = addDays(dayOnly(DateTime.now()), days);
        await tester.pumpWidget(MaterialApp(home: NewTaskPage(initialDate: day)));

        await tester.tap(find.byType(ScheduledTile));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    }
  });

  group('relativeDayLabel', () {
    final today = DateTime(2026, 9, 20);
    String label(DateTime d) => DateFormatter.relativeDayLabel(d, today);

    test('names today, tomorrow and yesterday', () {
      expect(label(DateTime(2026, 9, 20)), 'Today');
      expect(label(DateTime(2026, 9, 20, 23, 59)), 'Today');
      expect(label(DateTime(2026, 9, 21)), 'Tomorrow');
      expect(label(DateTime(2026, 9, 19)), 'Yesterday');
    });

    test('any other day is its weekday', () {
      expect(label(DateTime(2026, 9, 24)), 'Thu');
      expect(label(DateTime(2026, 9, 14)), 'Mon');
      expect(label(DateTime(2027, 9, 20)), 'Mon');
    });

    test('works across a month and a year boundary', () {
      expect(DateFormatter.relativeDayLabel(DateTime(2026, 10, 1), DateTime(2026, 9, 30)), 'Tomorrow');
      expect(DateFormatter.relativeDayLabel(DateTime(2026, 12, 31), DateTime(2027, 1, 1)), 'Yesterday');
    });
  });

  group('first use date', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('is unknown until it has been recorded', () async {
      expect(await AppPrefs.firstUseDate(), isNull);
    });

    test('stores the day, without the time', () async {
      await AppPrefs.recordFirstUse(DateTime(2026, 3, 12, 15, 30));
      expect(await AppPrefs.firstUseDate(), DateTime(2026, 3, 12));
    });

    test('is written only once, so later starts do not move it', () async {
      await AppPrefs.recordFirstUse(DateTime(2026, 3, 12));
      await AppPrefs.recordFirstUse(DateTime(2026, 9, 20));
      expect(await AppPrefs.firstUseDate(), DateTime(2026, 3, 12));
    });

    test('an unreadable stored value counts as unknown, not a crash', () async {
      SharedPreferences.setMockInitialValues({'first_use_date': 'not a date'});
      expect(await AppPrefs.firstUseDate(), isNull);
    });
  });
}
