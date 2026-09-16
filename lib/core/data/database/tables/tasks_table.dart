import 'package:drift/drift.dart';

/// Persisted task rows. Mirrors [DzTask] (lib/features/home/models/task_model.dart)
/// plus sync/soft-delete bookkeeping columns not present on the domain model.
///
/// `startTime`/`endTime` are stored as separate hour/minute int columns
/// rather than a single packed value, matching how [DzTask] already exposes
/// them as two `TimeOfDay` fields — avoids a lossy round-trip conversion.
@TableIndex(name: 'idx_tasks_date', columns: {#date})
@TableIndex(name: 'idx_tasks_deleted_at', columns: {#deletedAt})
@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  IntColumn get startHour => integer()();
  IntColumn get startMinute => integer()();
  IntColumn get endHour => integer()();
  IntColumn get endMinute => integer()();

  /// [TaskPriority] enum name (e.g. "high", "zen").
  TextColumn get priority => text()();

  /// [TaskCategory] enum name (e.g. "work", "study").
  TextColumn get category => text()();

  /// [IconData.codePoint], nullable — [DzTask.icon] is optional.
  IntColumn get iconCodePoint => integer().nullable()();
  TextColumn get subtitle => text().nullable()();
  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  /// Normalised to midnight, matching [DzTask.date]. Indexed — this is the
  /// column `forDate`/`forWeek` filter on.
  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// True when this row has local changes not yet confirmed synced to the
  /// server. Written by the repository on every local mutation; cleared by
  /// the sync layer once the server acknowledges the change.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  /// Soft-delete timestamp. Null = active. Rows are never hard-deleted
  /// except by [TaskDao.hardDeleteAll] (used for the Settings "clear all
  /// data" action), so sync can still see what was removed locally.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
