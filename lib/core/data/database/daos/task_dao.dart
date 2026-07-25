import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  /// All active (non soft-deleted) tasks, unordered — callers sort/filter
  /// as needed. Used by `TaskRepository.loadAll` to populate the in-memory
  /// cache; see docs/DEVELOPMENT_PLAN.md Phase 2.5 for why a full in-memory
  /// cache is still maintained on top of this DB-backed source of truth.
  Future<List<TaskRow>> getAllActive() {
    return (select(tasks)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Single-row insert. Replaces the old "rewrite entire list to
  /// SharedPreferences" pattern — this is the actual fix for
  /// docs/BASELINE_METRICS.md's headline scalability finding.
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
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(DateTime.now()),
        dirty: const Value(true),
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
  /// loaded cache for now (see docs/DEVELOPMENT_PLAN.md for the scoping
  /// rationale). Available for Phase 4 to adopt via StreamBuilder.
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
