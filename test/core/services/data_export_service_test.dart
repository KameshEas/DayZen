import 'dart:convert';

import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/data/checkin_repository.dart';
import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/day_close_repository.dart';
import 'package:dayzen/core/data/journal_repository.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/core/services/data_export_service.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApi extends ApiClient {
  final calls = <String>[];

  @override
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? headers}) async {
    calls.add(endpoint);
    return {
      'format': 'dayzen-export/1',
      'profile': {'id': 'u1', 'email': 'a@b.c'},
      'tasks': [],
      'journal': [],
    };
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
    await TaskRepository.insertTask(DzTask(
      id: 'task-1',
      title: 'Write report',
      startTime: const TimeOfDay(hour: 9, minute: 30),
      endTime: const TimeOfDay(hour: 10, minute: 30),
      status: TaskStatus.done,
      completedAt: DateTime(2027, 5, 1, 10, 31),
      date: DateTime(2027, 5, 1),
    ));
    await JournalRepository.insertEntry(JournalEntry(
      id: 'j-1',
      title: 'Evening reflection',
      body: 'Good focus after lunch',
      mood: JournalMood.peaceful,
      timestamp: DateTime(2027, 5, 1, 21),
    ));
    await const CheckinRepository().add(4, at: DateTime(2027, 5, 1, 15));
    await const DayCloseRepository().save(DayCloseRecord(
      date: DateTime(2027, 5, 1),
      closedAt: DateTime(2027, 5, 1, 21),
      done: 1,
      carried: 0,
      released: 0,
      journalEntryId: 'j-1',
    ));
  });

  tearDown(() async {
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  test('signed out: this phone\'s data in the server export shape', () async {
    final api = _FakeApi();
    final data = await DataExportService(api: api).build(signedIn: false);
    expect(api.calls, isEmpty, reason: 'no network when signed out');
    expect(data['format'], DataExportService.format);
    expect(data['source'], 'device');
    final task = (data['tasks'] as List).single as Map;
    expect(task['id'], 'task-1');
    expect(task['scheduled_date'], '2027-05-01');
    expect(task['status'], 'done');
    expect(task['start_hour'], 9);
    expect(task['deleted'], false);
    final entry = (data['journal'] as List).single as Map;
    expect(entry['body'], 'Good focus after lunch');
    expect(entry['mood'], 'peaceful');
    // Round-trips through JSON (no DateTime objects left in the map).
    expect(() => jsonEncode(data), returnsNormally);
  });

  test('signed in: the server export plus this phone\'s local-only data', () async {
    final api = _FakeApi();
    final data = await DataExportService(api: api).build(signedIn: true);
    expect(api.calls, ['/users/me/export']);
    expect((data['profile'] as Map)['id'], 'u1');
    final local = data['local_only'] as Map;
    expect((local['checkins'] as List).single, containsPair('energy', 4));
    expect((local['day_closes'] as List).single,
        allOf(containsPair('date', '2027-05-01'), containsPair('journal_entry_id', 'j-1')));
  });

  test('local-only data is in the signed-out export too', () async {
    final data = await DataExportService(api: _FakeApi()).build(signedIn: false);
    expect((data['local_only'] as Map)['checkins'], hasLength(1));
  });
}
