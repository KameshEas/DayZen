import 'package:dayzen/core/design_system/design_system.dart' hide TaskPriority;
import 'package:dayzen/core/domain/planner_dates.dart';
import 'package:dayzen/core/routing/route_paths.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/planner/planner_page.dart';
import 'package:dayzen/features/planner/planner_selection.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:dayzen/features/tasks/new_task_page.dart';
import 'package:dayzen/features/tasks/widgets/new_task_form_fields.dart';
import 'package:dayzen/features/tasks/widgets/task_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps tasks in memory and records what the UI asked for, so these tests
/// cover the screens without SQLite, sync or the notification plugin.
class _Tasks extends TaskController {
  _Tasks(List<DzTask> tasks) : _tasks = [...tasks];
  final List<DzTask> _tasks;
  final calls = <String>[];

  @override
  List<DzTask> get all => List.unmodifiable(_tasks);

  @override
  List<DzTask> forDate(DateTime date) =>
      _tasks.where((t) => t.isSameDay(dayOnly(date))).toList();

  @override
  DzTask? taskById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> setStatus(String id, TaskStatus status) async {
    calls.add('status $id ${status.name}');
    final i = _tasks.indexWhere((t) => t.id == id);
    _tasks[i] = _tasks[i].copyWith(status: status);
    notifyListeners();
  }

  @override
  Future<void> updateTask(String id, DzTask updatedTask) async {
    calls.add('update $id');
    final i = _tasks.indexWhere((t) => t.id == id);
    _tasks[i] = updatedTask;
    notifyListeners();
  }

  @override
  Future<void> deleteTask(String id) async {
    calls.add('delete $id');
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

final _today = dayOnly(DateTime.now());

DzTask _task(String id,
        {String title = 'Write report',
        TaskStatus status = TaskStatus.active,
        int rollover = 0,
        TaskPriority priority = TaskPriority.routine,
        TaskCategory category = TaskCategory.work}) =>
    DzTask(
      id: id,
      title: title,
      startTime: const TimeOfDay(hour: 10, minute: 0),
      endTime: const TimeOfDay(hour: 11, minute: 30),
      status: status,
      rolloverCount: rollover,
      priority: priority,
      category: category,
      icon: Icons.work_outline_rounded,
      date: _today,
    );

/// The Planner (on today) inside a router whose "new task" route is the real
/// page, so Edit can be followed end to end.
Widget _app(_Tasks tasks) {
  Widget scoped(Widget child) => AppScopes(
        tasks: tasks,
        journal: JournalController(),
        settings: SettingsController(),
        notifications: NotificationController(),
        child: child,
      );
  final router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (_, _) =>
          scoped(Scaffold(body: PlannerPage(selection: PlannerSelection()))),
    ),
    GoRoute(
      path: RoutePaths.newTask,
      builder: (_, state) => scoped(NewTaskPage(task: state.extra as DzTask?)),
    ),
  ]);
  return MaterialApp.router(theme: DzTheme.light(), routerConfig: router);
}

Future<void> _open(WidgetTester tester, _Tasks tasks, {bool wide = false}) async {
  // The edit form needs the wide surface the New Task tests use: the test
  // font draws every letter as a full-width square.
  tester.view.physicalSize = wide ? const Size(3000, 3600) : const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(tasks));
  await tester.pumpAndSettle();
}

Future<void> _tapCard(WidgetTester tester, String title) async {
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _pick(WidgetTester tester, TaskAction a) async {
  await tester.tap(find.byKey(Key('task-action-${a.name}')));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('actions offered depend on the status', () {
    Future<Set<TaskAction>> offered(WidgetTester tester, DzTask t) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: TaskActionsSheet(task: t)),
      ));
      return {
        for (final a in TaskAction.values)
          if (find.byKey(Key('task-action-${a.name}')).evaluate().isNotEmpty) a,
      };
    }

    testWidgets('a to-do can be done or let go', (tester) async {
      expect(await offered(tester, _task('1')), {
        TaskAction.done, TaskAction.letGo, TaskAction.edit, TaskAction.delete,
      });
    });

    testWidgets('a done task can be un-done', (tester) async {
      expect(await offered(tester, _task('1', status: TaskStatus.done)), {
        TaskAction.notDone, TaskAction.edit, TaskAction.delete,
      });
    });

    testWidgets('a let-go task can be brought back', (tester) async {
      expect(await offered(tester, _task('1', status: TaskStatus.released)), {
        TaskAction.bringBack, TaskAction.edit, TaskAction.delete,
      });
    });

    testWidgets('a carried task says how many times', (tester) async {
      await offered(tester, _task('1', rollover: 2));
      expect(find.text('Carried 2×'), findsOneWidget);
    });
  });

  group('from the planner', () {
    testWidgets('tap a card, mark it done, then undo', (tester) async {
      final tasks = _Tasks([_task('1')]);
      await _open(tester, tasks);

      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.done);
      expect(tasks.taskById('1')!.status, TaskStatus.done);
      expect(find.text('1 task · 1 done'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(tasks.taskById('1')!.status, TaskStatus.active);
      expect(tasks.calls, ['status 1 done', 'status 1 active']);
    });

    testWidgets('let go: stays on the day, faded, and is not counted',
        (tester) async {
      final tasks = _Tasks([_task('1'), _task('2', title: 'Gym')]);
      await _open(tester, tasks);

      await _tapCard(tester, 'Gym');
      await _pick(tester, TaskAction.letGo);

      expect(tasks.taskById('2')!.status, TaskStatus.released);
      expect(find.text('Gym'), findsOneWidget);
      expect(find.text('1 task · 0 done · 1 let go'), findsOneWidget);
      final fade = tester.widget<Opacity>(
          find.ancestor(of: find.text('Gym'), matching: find.byType(Opacity)).first);
      expect(fade.opacity, lessThan(1));

      // Let the other one go too: nothing planned is left to count.
      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.letGo);
      expect(find.text('2 let go'), findsOneWidget);

      // And it can be brought back from the same card.
      await _tapCard(tester, 'Gym');
      await _pick(tester, TaskAction.bringBack);
      expect(tasks.taskById('2')!.status, TaskStatus.active);
    });

    testWidgets('delete asks first; cancel keeps the task', (tester) async {
      final tasks = _Tasks([_task('1')]);
      await _open(tester, tasks);

      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.delete);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(tasks.calls, isEmpty);

      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.delete);
      await tester.tap(find.byKey(const Key('confirm-delete-task')));
      await tester.pumpAndSettle();
      expect(tasks.calls, ['delete 1']);
      expect(find.text('Write report'), findsNothing);
    });

    testWidgets('a card for identical tasks asks which one', (tester) async {
      final tasks = _Tasks([_task('a'), _task('b')]);
      await _open(tester, tasks);

      await _tapCard(tester, 'Write report');
      expect(find.text('2 identical tasks'), findsOneWidget);
      await tester.tap(find.text('Write report (2)'));
      await tester.pumpAndSettle();
      await _pick(tester, TaskAction.done);
      expect(tasks.calls, ['status b done']);
    });

    testWidgets('edit opens the form filled in and saves the changes',
        (tester) async {
      final tasks = _Tasks([
        _task('1', rollover: 2, priority: TaskPriority.zen),
      ]);
      await _open(tester, tasks, wide: true);

      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.edit);

      expect(find.text('Edit Task'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Write the report');
      await tester.tap(find.text('Study'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      final t = tasks.taskById('1')!;
      expect(tasks.calls, ['update 1']);
      expect(t.title, 'Write the report');
      expect(t.category, TaskCategory.study);
      expect(t.icon, Icons.menu_book_rounded);
      // Untouched fields survive the edit.
      expect(t.priority, TaskPriority.zen, reason: 'zen has no level of its own');
      expect(t.rolloverCount, 2);
      expect(t.startTime, const TimeOfDay(hour: 10, minute: 0));
      expect(t.endTime, const TimeOfDay(hour: 11, minute: 30));
      expect(find.text('Write the report'), findsOneWidget, reason: 'back on the planner');
    });

    testWidgets('changing the priority in edit is saved', (tester) async {
      final tasks = _Tasks([_task('1', priority: TaskPriority.zen)]);
      await _open(tester, tasks, wide: true);
      await _tapCard(tester, 'Write report');
      await _pick(tester, TaskAction.edit);

      final segment = find.byType(PrioritySegment);
      await tester.tap(find.descendant(of: segment, matching: find.text('High')));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(tasks.taskById('1')!.priority, TaskPriority.high);
    });
  });
}
