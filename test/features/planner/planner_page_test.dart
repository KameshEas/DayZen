import 'package:dayzen/core/domain/planner_dates.dart';
import 'package:dayzen/core/design_system/design_system.dart' hide TaskPriority;
import 'package:dayzen/core/routing/route_paths.dart';
import 'package:dayzen/core/utils/date_formatter.dart';
import 'package:dayzen/features/ai_optimization_controller.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights_controller.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/planner/planner_page.dart';
import 'package:dayzen/features/planner/planner_selection.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/shell/main_shell.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SeededTasks extends TaskController {
  _SeededTasks(this._tasks);
  final List<DzTask> _tasks;
  @override
  List<DzTask> get all => _tasks;
  @override
  List<DzTask> forDate(DateTime date) =>
      _tasks.where((t) => t.isSameDay(dayOnly(date))).toList();
}

DzTask _task(DateTime date, {int hour = 9, String title = 'A task', bool done = false}) =>
    DzTask(
      id: '${date.microsecondsSinceEpoch}-$hour-$title',
      title: title,
      startTime: TimeOfDay(hour: hour, minute: 0),
      endTime: TimeOfDay(hour: hour + 1, minute: 0),
      isCompleted: done,
      date: date,
    );

final _today = dayOnly(DateTime.now());
DateTime _in(int days) => addDays(_today, days);

/// A day of the current week that is not today, so it is always on the visible strip.
DateTime get _otherDayThisWeek {
  final monday = mondayOf(_today);
  return _today.weekday == DateTime.monday ? addDays(monday, 1) : monday;
}

AppScopes _scopes(List<DzTask> tasks, Widget child) => AppScopes(
      tasks: _SeededTasks(tasks),
      journal: JournalController(),
      settings: SettingsController(),
      insights: InsightsController(),
      aiOptimization: AIOptimizationController(),
      notifications: NotificationController(),
      child: child,
    );

/// The Planner inside a router that has a stand-in "new task" screen, which shows
/// the date it was opened with.
Widget _plannerApp(List<DzTask> tasks, PlannerSelection selection) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => _scopes(
          tasks,
          Scaffold(body: PlannerPage(selection: selection)),
        ),
      ),
      GoRoute(
        path: RoutePaths.newTask,
        builder: (context, state) => Scaffold(body: Text('NEW TASK ON ${state.extra}')),
      ),
    ],
  );
  return MaterialApp.router(theme: DzTheme.light(), routerConfig: router);
}

Future<void> _phone(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Future<void> _open(WidgetTester tester, Widget app) async {
  await _phone(tester);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'first_use_date': DateTime(_today.year, _today.month - 2, _today.day).toIso8601String(),
    });
    PlannerSelection.instance.reset();
  });

  group('opening the Planner', () {
    testWidgets('opens on today: the header says so and today is the selected day', (tester) async {
      final handle = tester.ensureSemantics();
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      expect(find.textContaining('Today,', findRichText: true), findsOneWidget);

      final todayCell = tester.getSemantics(find.bySemanticsLabel(RegExp(r', today$')));
      // ignore: deprecated_member_use
      expect(todayCell.hasFlag(SemanticsFlag.isSelected), isTrue);
      handle.dispose();
    });

    testWidgets('shows the whole week, Monday to Sunday, without scrolling', (tester) async {
      await _open(tester, _plannerApp([], PlannerSelection()));
      for (final d in ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']) {
        expect(find.text(d), findsOneWidget, reason: d);
      }
    });

    testWidgets('a "Today" button appears only when another day is showing', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));
      expect(find.byTooltip('Previous week'), findsOneWidget);
      expect(find.bySemanticsLabel('Jump to today'), findsNothing);

      selection.value = _otherDayThisWeek;
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Jump to today'), findsOneWidget);
    });
  });

  group('moving around', () {
    testWidgets('tapping a day selects it and retitles the page', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));
      final target = _otherDayThisWeek;

      await tester.tap(find.bySemanticsLabel(RegExp(DateFormatter.formatDateFull(target))));
      await tester.pumpAndSettle();

      expect(selection.value, target);
      expect(find.textContaining('Today,', findRichText: true), findsNothing);
    });

    testWidgets('the header calls tomorrow and yesterday by name', (tester) async {
      final selection = PlannerSelection(_in(1));
      await _open(tester, _plannerApp([], selection));
      expect(find.textContaining('Tomorrow,', findRichText: true), findsOneWidget);

      selection.value = _in(-1);
      await tester.pumpAndSettle();
      expect(find.textContaining('Yesterday,', findRichText: true), findsOneWidget);

      selection.value = _in(3);
      await tester.pumpAndSettle();
      expect(find.textContaining('Today,', findRichText: true), findsNothing);
      expect(find.textContaining('Tomorrow,', findRichText: true), findsNothing);
    });

    testWidgets('the Today button returns to today', (tester) async {
      final selection = PlannerSelection(_in(20));
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.bySemanticsLabel('Jump to today'));
      await tester.pumpAndSettle();

      expect(selection.value, _today);
      expect(find.bySemanticsLabel('Jump to today'), findsNothing);
    });

    testWidgets('the arrows step a week at a time', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.byTooltip('Next week'));
      await tester.pumpAndSettle();
      expect(selection.value, _in(7));

      await tester.tap(find.byTooltip('Previous week'));
      await tester.pumpAndSettle();
      expect(selection.value, _today);
    });

    testWidgets('swiping the strip moves a week and keeps the weekday', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      // A finger drag of about two thirds of the strip's width: one page, not two.
      await tester.fling(find.byType(PageView), const Offset(-250, 0), 1500);
      await tester.pumpAndSettle();

      expect(selection.value, _in(7));
      expect(selection.value.weekday, _today.weekday);
    });

    testWidgets('the calendar opens, and can be dismissed without changing the day', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.bySemanticsLabel(RegExp('^Open calendar')));
      await tester.pumpAndSettle();
      expect(find.text('Jump to a date'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(selection.value, _today);
    });

    testWidgets('picking a date in the calendar jumps there', (tester) async {
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.bySemanticsLabel(RegExp('^Open calendar')));
      await tester.pumpAndSettle();
      // Pick a day in the current month that isn't today; the calendar grid
      // labels days by number, and the day being replaced is the highlighted one.
      final targetDay = _today.day == 15 ? 16 : 15;
      await tester.tap(find.text('$targetDay').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(selection.value.day, targetDay);
      expect(selection.value.month, _today.month);
    });
  });

  group('the range you can browse', () {
    testWidgets('reaches back to the day the app was first used', (tester) async {
      final firstUse = DateTime(_today.year, _today.month - 2, _today.day);
      final selection = PlannerSelection(firstUse);
      await _open(tester, _plannerApp([], selection));

      // The selection was not pushed forward to today: that day is allowed.
      expect(selection.value, firstUse);
      expect(find.textContaining('Today,', findRichText: true), findsNothing);
    });

    testWidgets('reaches back further still to the oldest task', (tester) async {
      final old = _in(-300);
      final selection = PlannerSelection(old);
      await _open(tester, _plannerApp([_task(old, title: 'Old task')], selection));

      expect(find.text('Old task'), findsOneWidget);
    });

    testWidgets('a date before it started is clamped to the first day', (tester) async {
      final firstUse = DateTime(_today.year, _today.month - 2, _today.day);
      final selection = PlannerSelection(_in(-1000));
      await _open(tester, _plannerApp([], selection));

      // Shown as the first day, without crashing.
      expect(find.text(DateFormatter.monthFull(firstUse.month), findRichText: true),
          findsNothing); // month is shown with its year, never bare
      expect(find.textContaining(DateFormatter.monthFull(firstUse.month)), findsWidgets);
    });

    testWidgets('reaches two years ahead, and no further', (tester) async {
      final selection = PlannerSelection(DateTime(_today.year + 5, _today.month, _today.day));
      await _open(tester, _plannerApp([], selection));

      expect(find.textContaining('${_today.year + plannerYearsAhead}'), findsWidgets);
      expect(find.textContaining('${_today.year + 5}'), findsNothing);
    });

    testWidgets('the very first week cannot be swiped back past', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final selection = PlannerSelection();
      await _open(tester, _plannerApp([], selection));

      final prev = tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.chevron_left_rounded));
      expect(prev.onPressed, isNull);
    });
  });

  group('planning ahead', () {
    testWidgets('Add task on a future day opens the new task with that date', (tester) async {
      final future = _in(40);
      final selection = PlannerSelection(future);
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();

      expect(find.textContaining('NEW TASK ON $future'), findsOneWidget);
    });

    testWidgets('the empty-day button carries the date as well', (tester) async {
      final future = _in(10);
      final selection = PlannerSelection(future);
      await _open(tester, _plannerApp([], selection));

      await tester.tap(find.text('Add a Task'));
      await tester.pumpAndSettle();

      expect(find.textContaining('NEW TASK ON $future'), findsOneWidget);
    });

    testWidgets('an empty future day invites you to plan it', (tester) async {
      final selection = PlannerSelection(_in(10));
      await _open(tester, _plannerApp([], selection));

      expect(find.text('Nothing planned yet'), findsOneWidget);
      expect(find.textContaining('Plan ahead'), findsOneWidget);
    });

    testWidgets('an empty past day says it can still be logged', (tester) async {
      final selection = PlannerSelection(_in(-3));
      await _open(tester, _plannerApp([], selection));

      expect(find.text('Nothing was planned'), findsOneWidget);
    });

    testWidgets("a future day shows that day's own tasks, not today's", (tester) async {
      final future = _in(5);
      final selection = PlannerSelection(future);
      await _open(
        tester,
        _plannerApp([_task(_today, title: 'Today only'), _task(future, title: 'Next week')], selection),
      );

      expect(find.text('Next week'), findsOneWidget);
      expect(find.text('Today only'), findsNothing);
    });
  });

  group('the strip marks busy days', () {
    testWidgets("a day's task count is announced", (tester) async {
      final handle = tester.ensureSemantics();
      final day = _otherDayThisWeek;
      await _open(
        tester,
        _plannerApp([_task(day, title: 'a'), _task(day, hour: 11, title: 'b')], PlannerSelection()),
      );

      expect(find.bySemanticsLabel(RegExp('2 tasks')), findsOneWidget);
      handle.dispose();
    });

    testWidgets("the day's summary counts done tasks", (tester) async {
      await _open(
        tester,
        _plannerApp([
          _task(_today, title: 'a', done: true),
          _task(_today, hour: 11, title: 'b'),
          _task(_today, hour: 13, title: 'c'),
        ], PlannerSelection()),
      );

      expect(find.text('3 tasks · 1 done'), findsOneWidget);
    });

    testWidgets('a day with nothing says so', (tester) async {
      await _open(tester, _plannerApp([], PlannerSelection()));
      expect(find.text('No tasks'), findsOneWidget);
    });
  });

  group('the centre + button', () {
    Widget shellApp(PlannerSelection selection) {
      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                _scopes([], MainShell(child: child)),
            routes: [
              GoRoute(path: RoutePaths.home, builder: (c, s) => const SizedBox()),
              GoRoute(
                path: RoutePaths.planner,
                builder: (c, s) => PlannerPage(selection: selection),
              ),
              GoRoute(path: RoutePaths.insights, builder: (c, s) => const SizedBox()),
              GoRoute(path: RoutePaths.journal, builder: (c, s) => const SizedBox()),
            ],
          ),
          GoRoute(
            path: RoutePaths.newTask,
            builder: (context, state) => Scaffold(body: Text('NEW TASK ON ${state.extra}')),
          ),
        ],
      );
      return MaterialApp.router(theme: DzTheme.light(), routerConfig: router);
    }

    testWidgets('on the Planner it starts a task on the day being viewed', (tester) async {
      final future = _in(21);
      // The shell reads the app-wide selection, which the page also uses here.
      final selection = PlannerSelection.instance..value = future;
      await _open(tester, shellApp(selection));

      await tester.tap(find.text('Planner'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DzFab));
      await tester.pumpAndSettle();

      expect(find.textContaining('NEW TASK ON $future'), findsOneWidget);
    });

    testWidgets('elsewhere it starts a task with no date (today)', (tester) async {
      PlannerSelection.instance.value = _in(21);
      await _open(tester, shellApp(PlannerSelection.instance));

      // Still on the Home tab.
      await tester.tap(find.byType(DzFab));
      await tester.pumpAndSettle();

      expect(find.text('NEW TASK ON null'), findsOneWidget);
    });
  });

  group('PlannerSelection', () {
    test('starts on today and stores only the date', () {
      expect(PlannerSelection().value, _today);
      expect(PlannerSelection(DateTime(2026, 9, 20, 15, 30)).value, DateTime(2026, 9, 20));
    });

    test('reset goes back to today', () {
      final s = PlannerSelection(_in(30))..reset();
      expect(s.value, _today);
    });

    test('notifies listeners when it changes', () {
      var n = 0;
      PlannerSelection()
        ..addListener(() => n++)
        ..value = _in(1);
      expect(n, 1);
    });
  });
}
