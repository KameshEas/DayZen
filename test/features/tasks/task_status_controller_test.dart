import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/core/domain/task_analytics.dart';
import 'package:dayzen/core/services/sync_coordinator.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/planner/timeline_layout.dart';
import 'package:dayzen/features/task_controller.dart';

/// Task actions at the controller level (real SQLite, signed out so sync is a
/// no-op), plus the counting rules for let-go tasks.

final _day = DateTime(2099, 3, 4); // in the future: load()'s rollover leaves it

DzTask _task(String id, {TaskStatus status = TaskStatus.active, String title = 'T'}) =>
    DzTask(
      id: id,
      title: title,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      endTime: const TimeOfDay(hour: 10, minute: 0),
      status: status,
      date: _day,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskController.setStatus', () {
    late TaskController c;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      SyncCoordinator.isSignedIn = () => false;
      DatabaseProvider.instanceForTesting =
          AppDatabase.forTesting(NativeDatabase.memory());
      c = TaskController()..setNotificationsEnabled(false);
      await c.addTask(_task('1'));
    });

    tearDown(() async {
      await DatabaseProvider.instance.close();
      DatabaseProvider.resetForTesting();
    });

    Future<DzTask> stored() async =>
        (await TaskRepository.loadAll()).singleWhere((t) => t.id == '1');

    test('done stamps completedAt and is stored dirty for sync', () async {
      await c.setStatus('1', TaskStatus.done);
      final t = await stored();
      expect(t.status, TaskStatus.done);
      expect(t.isCompleted, isTrue);
      expect(t.completedAt, isNotNull);
      expect(await TaskRepository.hasPendingChanges('1'), isTrue);
    });

    test('let go clears completedAt; bring back makes it active', () async {
      await c.setStatus('1', TaskStatus.done);
      await c.setStatus('1', TaskStatus.released);
      var t = await stored();
      expect((t.status, t.completedAt), (TaskStatus.released, null));

      await c.setStatus('1', TaskStatus.active);
      t = await stored();
      expect(t.status, TaskStatus.active);
      expect(c.taskById('1')!.status, TaskStatus.active);
    });

    test('toggleTask: released becomes done, done becomes active', () async {
      await c.setStatus('1', TaskStatus.released);
      await c.toggleTask('1');
      expect(c.taskById('1')!.status, TaskStatus.done);
      await c.toggleTask('1');
      expect(c.taskById('1')!.status, TaskStatus.active);
    });

    test('setting the same status again changes nothing', () async {
      await c.setStatus('1', TaskStatus.done);
      final first = c.taskById('1')!.completedAt;
      var notified = 0;
      c.addListener(() => notified++);
      await c.setStatus('1', TaskStatus.done);
      expect(c.taskById('1')!.completedAt, first);
      expect(notified, 0);
    });

    test('an unknown id is ignored', () async {
      await c.setStatus('nope', TaskStatus.done);
      expect(c.all.single.status, TaskStatus.active);
    });

    test('an edit keeps status and v2 fields', () async {
      await c.setStatus('1', TaskStatus.done);
      final done = c.taskById('1')!;
      await c.updateTask('1', done.copyWith(title: 'Renamed'));
      final t = await stored();
      expect(t.title, 'Renamed');
      expect(t.status, TaskStatus.done);
      // SQLite keeps whole seconds.
      expect(t.completedAt!.millisecondsSinceEpoch ~/ 1000,
          done.completedAt!.millisecondsSinceEpoch ~/ 1000);
    });
  });

  group('let-go tasks never count against a day', () {
    test('score and completion ignore them', () {
      final tasks = [
        _task('a', status: TaskStatus.done),
        _task('b', status: TaskStatus.released),
        _task('c', status: TaskStatus.released),
      ];
      expect(TaskAnalytics.completionFraction(tasks, _day), 1.0);
      expect(TaskAnalytics.score(tasks, _day), 100);
    });

    test('a day of only let-go tasks scores 0, not NaN', () {
      final tasks = [_task('a', status: TaskStatus.released)];
      expect(TaskAnalytics.completionFraction(tasks, _day), 0);
    });

    test('weekly counts skip them', () {
      final tasks = [
        _task('a', status: TaskStatus.released),
        _task('b'),
      ];
      expect(TaskAnalytics.topCategory(tasks, _day)!.planned, 1);
    });
  });

  group('timeline cards', () {
    test('a merged card knows every task behind it', () {
      final slots = layoutTimeline([
        PlannerEvent.fromTask(_task('a')),
        PlannerEvent.fromTask(_task('b')),
      ]);
      expect(slots.single.count, 2);
      expect(slots.single.event.taskIds, ['a', 'b']);
    });

    test('a merged card is let go only when all of its tasks are', () {
      PlannerEvent e(String id, TaskStatus s) =>
          PlannerEvent.fromTask(_task(id, status: s));
      expect(
        layoutTimeline([e('a', TaskStatus.released), e('b', TaskStatus.active)])
            .single.event.isReleased,
        isFalse,
      );
      expect(
        layoutTimeline([e('a', TaskStatus.released), e('b', TaskStatus.released)])
            .single.event.isReleased,
        isTrue,
      );
    });
  });
}
