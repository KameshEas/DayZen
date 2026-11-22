import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/services/sync_coordinator.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/planner/widgets/day_load_pill.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final today = DateTime(2099, 5, 20);

  DzTask task(String id, DateTime day,
          {TaskStatus status = TaskStatus.active,
          int effort = 2,
          TaskPriority priority = TaskPriority.routine,
          int hour = 9}) =>
      DzTask(
        id: id,
        title: 'Task $id',
        startTime: TimeOfDay(hour: hour, minute: 0),
        endTime: TimeOfDay(hour: hour + 1, minute: 0),
        status: status,
        effort: effort,
        priority: priority,
        date: day,
      );

  late TaskController tasks;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SyncCoordinator.isSignedIn = () => false;
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
    tasks = TaskController()..setNotificationsEnabled(false);
    // History: about 4 effort points finished per day.
    for (var d = 1; d <= 5; d++) {
      final day = today.subtract(Duration(days: d));
      await tasks.addTask(task('h$d-a', day, status: TaskStatus.done));
      await tasks.addTask(task('h$d-b', day, status: TaskStatus.done));
    }
  });

  tearDown(() async {
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  testWidgets('a heavy day offers to move the lowest-priority, latest task',
      (tester) async {
    await tester.runAsync(() async {
      await tasks.addTask(task('big', today, effort: 3, priority: TaskPriority.high, hour: 9));
      await tasks.addTask(task('mid', today, effort: 3, hour: 11));
      await tasks.addTask(task('late', today, effort: 3, priority: TaskPriority.low, hour: 18));
    });
    expect(dayLoadFor(tasks.all, today).suggestMoveId, 'late');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DayLoadIndicator(tasks: tasks, day: today)),
    ));
    expect(find.text('Heavy day'), findsOneWidget);
    await tester.tap(find.text('Heavy day'));
    await tester.pumpAndSettle();
    expect(find.text('Move "Task late" to tomorrow?'), findsOneWidget);
    await tester.tap(find.text('Move it'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(tasks.taskById('late')!.date, today.add(const Duration(days: 1)));
    expect(tasks.taskById('late')!.rolloverCount, 0,
        reason: 'a chosen move is not a carry-over');
  });

  testWidgets('without enough history it says Balanced and suggests nothing',
      (tester) async {
    final fresh = TaskController()..setNotificationsEnabled(false);
    await tester.runAsync(() async {
      await tasks.clearAll();
      for (var i = 0; i < 6; i++) {
        await fresh.addTask(task('t$i', today, effort: 3));
      }
    });
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: DayLoadIndicator(tasks: fresh, day: today)),
    ));
    expect(find.text('Balanced day'), findsOneWidget);
    await tester.tap(find.text('Balanced day'));
    await tester.pumpAndSettle();
    expect(find.textContaining('to tomorrow?'), findsNothing);
    expect(find.textContaining('After a few days'), findsOneWidget);
  });
}
