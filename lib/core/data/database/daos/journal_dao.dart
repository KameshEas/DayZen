import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/journal_entries_table.dart';

part 'journal_dao.g.dart';

@DriftAccessor(tables: [JournalEntries])
class JournalDao extends DatabaseAccessor<AppDatabase>
    with _$JournalDaoMixin {
  JournalDao(super.db);

  /// All active (non soft-deleted) entries, unordered — callers sort as
  /// needed. Used by `JournalRepository.loadAll` to populate the in-memory
  /// cache (see docs/DEVELOPMENT_PLAN.md Phase 2.5 for the scoping
  /// rationale on why a full in-memory cache remains on top of this DB).
  Future<List<JournalEntryRow>> getAllActive() {
    return (select(journalEntries)..where((e) => e.deletedAt.isNull())).get();
  }

  /// Single-row insert. Journal entries are append-only from the UI's
  /// perspective, but insertOrReplace keeps this idempotent for the sync
  /// path (re-applying a server entry with the same id is a no-op update,
  /// not a duplicate).
  Future<void> insertEntry(JournalEntriesCompanion entry) {
    return into(journalEntries)
        .insert(entry, mode: InsertMode.insertOrReplace);
  }

  /// Single-row update, keyed by [id].
  Future<void> updateEntryRow(String id, JournalEntriesCompanion changes) {
    return (update(journalEntries)..where((e) => e.id.equals(id)))
        .write(changes);
  }

  /// Soft delete — see [Tasks.deletedAt] docs for the equivalent rationale.
  Future<void> softDeleteEntry(String id) {
    return (update(journalEntries)..where((e) => e.id.equals(id))).write(
      JournalEntriesCompanion(
        deletedAt: Value(DateTime.now()),
        dirty: const Value(true),
      ),
    );
  }

  /// Permanently removes every row. Used only by the Settings "clear all
  /// data" action.
  Future<void> hardDeleteAll() {
    return delete(journalEntries).go();
  }
}
