import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// All active (non soft-deleted) tasks, unordered — callers sort/filter
  /// as needed. Used by `TaskRepository.loadAll` to populate the in-memory
  /// cache, kept on top of this DB-backed source of truth so the UI can read
  /// synchronously.
  Future<List<TaskRow>> getAllActive() {
    return (select(tasks)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Single-row insert. Replaces the old "rewrite entire list to
  /// SharedPreferences" pattern, which rewrote every task on each change
  /// and slowed down as the list grew.
  Future<void> insertTask(TasksCompanion task) {
    return into(tasks).insert(task, mode: InsertMode.insertOrReplace);
  }

  /// Single-row update, keyed by [id]. Only the fields present on [changes]
  /// (i.e. not `Value.absent()`) are written.
  Future<void> updateTaskRow(String id, TasksCompanion changes) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(changes);
  }

  /// Soft delete — sets `deletedAt`, does not remove the row. Sync still
  /// needs to see what was deleted locally; see [hardDeleteAll] for the
  /// destructive "clear all data" path.
  Future<void> softDeleteTask(String id) {
    final now = DateTime.now();
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  // ── Sync bookkeeping ────────────────────────────────────────────────

  /// Every row with local changes the server hasn't acknowledged yet,
  /// including soft-deleted rows (tombstones), so deletes reach the server.
  Future<List<TaskRow>> getDirty() {
    return (select(tasks)..where((t) => t.dirty.equals(true))).get();
  }

  Future<TaskRow?> getById(String id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Clears `dirty` on each of [sent] whose row is still exactly what was
  /// sent. A row edited while the request was in flight stays dirty and goes
  /// out with the next sync.
  Future<void> markSynced(List<TaskRow> sent) {
    return transaction(() async {
      for (final row in sent) {
        final current = await getById(row.id);
        if (current == row) {
          await (update(tasks)..where((t) => t.id.equals(row.id)))
              .write(const TasksCompanion(dirty: Value(false)));
        }
      }
    });
  }

  /// Writes a row that came from the server. Stored clean (not dirty), so
  /// applying server state never queues another push.
  Future<void> upsertFromServer(TasksCompanion row) {
    return into(tasks).insert(
      row.copyWith(dirty: const Value(false)),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// Applies a server-side delete: soft delete, stored clean.
  Future<void> deleteFromServer(String id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(DateTime.now()),
        dirty: const Value(false),
      ),
    );
  }

  /// Permanently removes every row. Used only by the Settings "clear all
  /// data" action — everyday deletes go through [softDeleteTask].
  Future<void> hardDeleteAll() {
    return delete(tasks).go();
  }

  /// Indexed query on the `date` column (see `idx_tasks_date` on [Tasks]).
  /// Not yet wired into the UI — Phase 2.5 deliberately kept
  /// `TaskController.forDate` doing in-memory filtering over the already-
  /// loaded cache for now. Available to adopt via StreamBuilder later.
  Stream<List<TaskRow>> watchForDate(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    return (select(tasks)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .watch();
  }

  /// Indexed range query for the 7-day window starting at [weekStart].
  Stream<List<TaskRow>> watchForWeek(DateTime weekStart) {
    final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final end = start.add(const Duration(days: 7));
    return (select(tasks)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .watch();
  }
}
