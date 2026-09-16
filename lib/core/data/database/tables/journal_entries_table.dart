import 'package:drift/drift.dart';

/// Persisted journal entry rows. Mirrors [JournalEntry]
/// (lib/features/journal/models/journal_entry.dart) plus sync/soft-delete
/// bookkeeping columns not present on the domain model.
@TableIndex(name: 'idx_journal_timestamp', columns: {#timestamp})
@TableIndex(name: 'idx_journal_deleted_at', columns: {#deletedAt})
@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// [JournalMood] enum name (e.g. "happy", "peaceful").
  TextColumn get mood => text()();

  /// Entry timestamp — this is "entry_timestamp" in docs/DEVELOPMENT_PLAN.md's
  /// original schema note. Indexed — entries are always queried newest-first.
  DateTimeColumn get timestamp => dateTime()();

  /// ARGB int from [Color.toARGB32], nullable — [JournalEntry.accentColor]
  /// is optional.
  IntColumn get accentColorValue => integer().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// See [Tasks.dirty] — same sync-pending semantics.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  /// See [Tasks.deletedAt] — same soft-delete semantics.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
