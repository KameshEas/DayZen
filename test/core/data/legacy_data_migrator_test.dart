import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/journal_repository.dart';
import 'package:dayzen/core/data/legacy_data_migrator.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    DatabaseProvider.instanceForTesting = db;
  });

  tearDown(() async {
    await db.close();
    DatabaseProvider.resetForTesting();
  });

  // Realistic pre-Phase-2 fixtures, built via the real model's own
  // toJson() rather than hand-typed maps — guarantees the fixture format
  // actually matches what a real pre-migration install would have written.
  DzTask fixtureTask({required String id}) => DzTask(
        id: id,
        title: 'Legacy Task $id',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 30),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        subtitle: 'Migrated from SharedPreferences',
        isCompleted: id == 'legacy-2',
        date: DateTime(2026, 1, 15),
      );

  JournalEntry fixtureEntry({required String id}) => JournalEntry(
        id: id,
        title: 'Legacy Entry $id',
        body: 'Written before the SQLite migration.',
        mood: JournalMood.peaceful,
        timestamp: DateTime(2026, 1, 10, 8, 30),
        accentColor: const Color(0xFF10B981),
      );

  group('LegacyDataMigrator', () {
    test('migrates legacy tasks and journal entries into SQLite', () async {
      final legacyTasks = [
        fixtureTask(id: 'legacy-1'),
        fixtureTask(id: 'legacy-2'),
      ];
      final legacyEntries = [fixtureEntry(id: 'legacy-entry-1')];

      SharedPreferences.setMockInitialValues({
        'dz_tasks':
            jsonEncode(legacyTasks.map((t) => t.toJson()).toList()),
        'dz_journal_entries':
            jsonEncode(legacyEntries.map((e) => e.toJson()).toList()),
      });

      await LegacyDataMigrator.migrateIfNeeded();

      final migratedTasks = await TaskRepository.loadAll();
      final migratedEntries = await JournalRepository.loadAll();

      expect(migratedTasks, hasLength(2));
      expect(migratedTasks.map((t) => t.id), containsAll(['legacy-1', 'legacy-2']));
      expect(
        migratedTasks.firstWhere((t) => t.id == 'legacy-2').isCompleted,
        isTrue,
      );

      expect(migratedEntries, hasLength(1));
      expect(migratedEntries.single.id, 'legacy-entry-1');
      expect(migratedEntries.single.body, 'Written before the SQLite migration.');
    });

    test('clears legacy keys after successful migration', () async {
      SharedPreferences.setMockInitialValues({
        'dz_tasks': jsonEncode([fixtureTask(id: 'legacy-1').toJson()]),
      });

      await LegacyDataMigrator.migrateIfNeeded();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dz_tasks'), isNull);
    });

    test('is a no-op on a fresh install with no legacy data', () async {
      SharedPreferences.setMockInitialValues({});

      await LegacyDataMigrator.migrateIfNeeded();

      expect(await TaskRepository.loadAll(), isEmpty);
      expect(await JournalRepository.loadAll(), isEmpty);
    });

    test('does not re-migrate (and does not duplicate) on a second call',
        () async {
      SharedPreferences.setMockInitialValues({
        'dz_tasks': jsonEncode([fixtureTask(id: 'legacy-1').toJson()]),
      });

      await LegacyDataMigrator.migrateIfNeeded();
      await LegacyDataMigrator.migrateIfNeeded();

      final migratedTasks = await TaskRepository.loadAll();
      expect(migratedTasks, hasLength(1));
    });

    test('re-running after the version flag is set does not resurrect '
        'a task deleted from SQLite post-migration', () async {
      SharedPreferences.setMockInitialValues({
        'dz_tasks': jsonEncode([fixtureTask(id: 'legacy-1').toJson()]),
      });

      await LegacyDataMigrator.migrateIfNeeded();
      await TaskRepository.deleteTask('legacy-1');

      // Simulate an app restart re-invoking the startup migration check.
      await LegacyDataMigrator.migrateIfNeeded();

      final tasks = await TaskRepository.loadAll();
      expect(tasks, isEmpty);
    });
  });
}
