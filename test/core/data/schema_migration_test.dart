import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

// Schema dumps: drift_schemas/. After changing a table, bump schemaVersion,
// then run:
//   dart run drift_dev schema dump lib/core/data/database/app_database.dart drift_schemas/
//   dart run drift_dev schema generate drift_schemas/ test/core/data/generated_migrations/
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('every schema version upgrades to the current one', () async {
    for (final from in GeneratedHelper.versions) {
      final schema = await verifier.schemaAt(from);
      final db = AppDatabase.forTesting(schema.newConnection());
      await verifier.migrateAndValidate(db, 3);
      await db.close();
    }
  });

  test('v2 -> v3 adds the weekly Rhythm history and keeps everything else',
      () async {
    final schema = await verifier.schemaAt(2);
    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);
    await db.localOnlyDao.saveRhythmWeek(RhythmProfileHistoryCompanion.insert(
      weekStart: DateTime(2027, 3, 1),
      curve: List.filled(24, '0.5').join(','),
      confidence: 3,
      savedAt: DateTime(2027, 3, 3),
    ));
    expect(await db.localOnlyDao.rhythmHistory(), hasLength(1));
    await db.close();
  });

  test('v1 -> v2 keeps tasks and backfills status and completedAt', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    // drift stores DateTime as unix seconds by default.
    final day = DateTime(2026, 11, 20).millisecondsSinceEpoch ~/ 1000;
    final edited = DateTime(2026, 11, 20, 18, 5).millisecondsSinceEpoch ~/ 1000;
    Future<void> seed(String id, bool done, {int? deletedAt}) =>
        old.customStatement(
          'INSERT INTO tasks (id, title, start_hour, start_minute, end_hour, '
          'end_minute, priority, category, is_completed, date, created_at, '
          'updated_at, dirty, deleted_at) '
          "VALUES (?, ?, 9, 30, 10, 0, 'high', 'study', ?, ?, ?, ?, 0, ?)",
          [id, 'Task $id', done ? 1 : 0, day, day, edited, deletedAt],
        );
    await seed('open', false);
    await seed('finished', true);
    await seed('deleted', true, deletedAt: edited);
    await old.close();

    final db = AppDatabase.forTesting(schema.newConnection());
    await verifier.migrateAndValidate(db, 3);

    final rows = {for (final r in await db.select(db.tasks).get()) r.id: r};
    expect(rows.keys, containsAll(['open', 'finished', 'deleted']));

    final open = TaskRepository.fromRow(rows['open']!);
    expect(open.status, TaskStatus.active);
    expect(open.completedAt, isNull);
    expect(open.rolloverCount, 0);
    expect(open.effort, isNull);
    expect(open.originalDate, isNull);
    expect(open.title, 'Task open');
    expect((open.startTime.hour, open.startTime.minute), (9, 30));
    expect(open.priority, TaskPriority.high);
    expect(open.date, DateTime(2026, 11, 20));

    final finished = TaskRepository.fromRow(rows['finished']!);
    expect(finished.status, TaskStatus.done);
    expect(finished.isCompleted, isTrue);
    expect(finished.completedAt, DateTime(2026, 11, 20, 18, 5));

    // Soft-deleted rows are migrated too (sync still needs the tombstone).
    expect(rows['deleted']!.deletedAt, isNotNull);
    expect(rows['deleted']!.status, 'done');
    // Migration doesn't queue anything for sync.
    expect(rows.values.every((r) => !r.dirty), isTrue);

    // The new local-only tables work.
    await db.localOnlyDao.increment('app_opens');
    await db.localOnlyDao.increment('app_opens', by: 2);
    expect(await db.localOnlyDao.counter('app_opens'), 3);
    await db.close();
  });
}
