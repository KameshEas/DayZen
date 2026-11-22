import 'dart:async';
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/journal_repository.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/core/services/journal_service.dart';
import 'package:dayzen/core/services/journal_sync_manager.dart';
import 'package:dayzen/core/services/sync_coordinator.dart';
import 'package:dayzen/core/services/sync_manager.dart';
import 'package:dayzen/core/services/task_service.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/task_controller.dart';

/// Regression tests for docs/MOBILE_PROJECT_PLAN.md P0-1 (controller <-> sync
/// recursion) and P0-5 (sync protocol: deltas, tombstones, times, cursor).
///
/// Before the fix, `TaskController.addTask` never returned: each add queued
/// a sync whose "local write" was `addTask` again.

DzTask _task(String id, {String title = 'Task', int startHour = 9}) => DzTask(
      id: id,
      title: title,
      startTime: TimeOfDay(hour: startHour, minute: 15),
      endTime: TimeOfDay(hour: startHour + 1, minute: 45),
      priority: TaskPriority.routine,
      category: TaskCategory.work,
      date: DateTime(2026, 11, 20),
    );

JournalEntry _entry(String id) => JournalEntry(
      id: id,
      title: 'Entry',
      body: 'Body',
      mood: JournalMood.peaceful,
      timestamp: DateTime(2026, 11, 20, 8),
    );

/// Records every request; answers with [respond].
class _Server {
  _Server(this.respond);
  final Future<http.Response> Function(http.Request) respond;
  final requests = <http.Request>[];

  ApiClient client() => ApiClient(
        client: MockClient((r) {
          requests.add(r);
          return respond(r);
        }),
      );

  Map<String, dynamic> body(int i) =>
      jsonDecode(requests[i].body) as Map<String, dynamic>;
}

http.Response _json(Map<String, dynamic> body) =>
    http.Response(jsonEncode(body), 200);

Future<void> _idle(SyncCoordinator<dynamic> m) async {
  for (var i = 0; i < 200 && m.isSyncing; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  // Let any follow-up sync start and finish.
  await Future<void>.delayed(const Duration(milliseconds: 20));
  for (var i = 0; i < 200 && m.isSyncing; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SyncCoordinator.isSignedIn = () => true;
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
    SyncManager.instance.clearSyncState();
    JournalSyncManager.instance.clearSyncState();
  });

  tearDown(() async {
    await _idle(SyncManager.instance);
    await _idle(JournalSyncManager.instance);
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  group('P0-1: local writes terminate (offline)', () {
    late _Server server;
    setUp(() {
      server = _Server((_) async => http.Response('down', 503));
      TaskService.apiClientForTesting = server.client();
      JournalService.apiClientForTesting = server.client();
    });

    test('addTask returns and stores the task exactly once', () async {
      final c = TaskController();
      await c.addTask(_task('a'));
      await _idle(SyncManager.instance);

      expect(c.all.map((t) => t.id), ['a']);
      expect(await TaskRepository.loadAll(), hasLength(1));
      expect(server.requests, hasLength(1), reason: 'one push attempt, no loop');
      expect((await TaskRepository.dirtyRows()).single.id, 'a',
          reason: 'failed push leaves the change queued');
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('deleteTask returns and leaves one dirty tombstone', () async {
      final c = TaskController();
      await c.addTask(_task('a'));
      await _idle(SyncManager.instance);
      await c.deleteTask('a');
      await _idle(SyncManager.instance);

      expect(c.all, isEmpty);
      final dirty = await TaskRepository.dirtyRows();
      expect(dirty.single.deletedAt, isNotNull);
      expect(server.requests, hasLength(2));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('toggleTask returns without duplicating the task', () async {
      final c = TaskController();
      await c.addTask(_task('a'));
      await c.toggleTask('a');
      await _idle(SyncManager.instance);

      expect(c.all.single.isCompleted, isTrue);
      expect(await TaskRepository.loadAll(), hasLength(1));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('journal addEntry/deleteEntry return', () async {
      final c = JournalController();
      await c.addEntry(_entry('j'));
      await _idle(JournalSyncManager.instance);
      expect(c.all, hasLength(1));
      await c.deleteEntry('j');
      await _idle(JournalSyncManager.instance);
      expect(c.all, isEmpty);
      expect((await JournalRepository.dirtyRows()).single.deletedAt, isNotNull);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });

  group('P0-5: task sync protocol', () {
    test('pushes times and tombstones, then applies server changes clean',
        () async {
      // Local state: 'a' edited (dirty), 'b' deleted (dirty tombstone),
      // 'c' clean copy of a server task.
      await TaskRepository.insertTask(_task('a', startHour: 14));
      await TaskRepository.insertTask(_task('b'));
      await TaskRepository.deleteTask('b');
      await TaskRepository.upsertFromServer(_task('c'));

      final server = _Server((_) async => _json({
            'server_tasks': [
              {
                'id': 's1',
                'title': 'From server',
                'scheduled_date': '2026-11-21',
                'start_hour': 7,
                'start_minute': 30,
                'end_hour': 8,
                'end_minute': 0,
                'priority': 'high',
                'category': 'study',
                'is_completed': false,
              },
            ],
            'deleted_ids': ['c'],
            'conflicts': [],
            'synced_at': '2026-11-20T10:00:00Z',
          }));
      TaskService.apiClientForTesting = server.client();

      final c = TaskController();
      await c.load(); // load starts the sync
      await _idle(SyncManager.instance);

      expect(server.requests, hasLength(1),
          reason: 'applying server changes must not trigger another push');
      final pushed = <String, dynamic>{
        for (final t in server.body(0)['tasks'] as List)
          (t as Map)['id'] as String: t,
      };
      expect(pushed.keys.toSet(), {'a', 'b'}, reason: 'only dirty rows');
      expect(pushed['a']['start_hour'], 14);
      expect(pushed['a']['start_minute'], 15);
      expect(pushed['a']['end_hour'], 15);
      expect(pushed['a']['deleted_at'], isNull);
      expect(pushed['b']['deleted_at'], isNotNull);
      expect(server.body(0)['last_sync_at'], isNull, reason: 'first sync');

      expect(await TaskRepository.dirtyRows(), isEmpty);
      expect(c.all.map((t) => t.id).toSet(), {'a', 's1'});
      final s1 = c.all.firstWhere((t) => t.id == 's1');
      expect(s1.startTime, const TimeOfDay(hour: 7, minute: 30));
      expect(await SyncCursor.load(SyncManager.cursorKey),
          DateTime.utc(2026, 11, 20, 10));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('next sync sends the saved cursor and nothing when nothing changed',
        () async {
      await SyncCursor.save(SyncManager.cursorKey, DateTime.utc(2026, 1, 2));
      final server = _Server((_) async =>
          _json({'server_tasks': [], 'deleted_ids': [], 'conflicts': []}));
      TaskService.apiClientForTesting = server.client();

      final c = TaskController();
      await c.load();
      await _idle(SyncManager.instance);

      expect(server.body(0)['last_sync_at'], '2026-01-02T00:00:00.000Z');
      expect(server.body(0)['tasks'], isEmpty);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('a failed sync does not apply cached data over local state',
        () async {
      final server = _Server((_) async => http.Response('boom', 500));
      TaskService.apiClientForTesting = server.client();

      final c = TaskController();
      await c.addTask(_task('a', title: 'local title'));
      await _idle(SyncManager.instance);

      expect(c.all.single.title, 'local title');
      expect(await TaskRepository.dirtyRows(), hasLength(1));
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('an edit made while a sync is in flight is pushed by a follow-up',
        () async {
      final gate = Completer<void>();
      final server = _Server((r) async {
        await gate.future;
        return _json({'server_tasks': [], 'deleted_ids': [], 'conflicts': []});
      });
      TaskService.apiClientForTesting = server.client();

      final c = TaskController();
      await c.addTask(_task('a', title: 'v1'));
      // First push is now in flight and blocked on the gate.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await c.updateTask('a', _task('a', title: 'v2'));
      gate.complete();
      await _idle(SyncManager.instance);

      expect(server.requests, hasLength(2));
      final second = (server.body(1)['tasks'] as List).single as Map;
      expect(second['title'], 'v2');
      expect(await TaskRepository.dirtyRows(), isEmpty);
    }, timeout: const Timeout(Duration(seconds: 10)));

    test('a server change does not overwrite an unpushed local edit',
        () async {
      final c = TaskController();
      await TaskRepository.insertTask(_task('a', title: 'local edit'));
      await c.applyServerChanges(
        upserts: [_task('a', title: 'server copy')],
        deletedIds: const [],
      );
      expect((await TaskRepository.loadAll()).single.title, 'local edit');
    });
  });
}
