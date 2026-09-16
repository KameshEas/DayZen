import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../features/journal/models/journal_entry.dart';
import 'database/app_database.dart';
import 'database/daos/journal_dao.dart';
import 'database/database_provider.dart';

/// Journal entry persistence, backed by SQLite (via drift) — see
/// docs/DATABASE_SCHEMA.md. Single-row operations; no more
/// `save(List<JournalEntry>)` full-list rewrite (see
/// docs/BASELINE_METRICS.md for why that pattern was the Phase 2 target).
class JournalRepository {
  static JournalDao get _dao => DatabaseProvider.instance.journalDao;

  /// All active (non soft-deleted) entries.
  static Future<List<JournalEntry>> loadAll() async {
    final rows = await _dao.getAllActive();
    return rows.map(_fromRow).toList();
  }

  static Future<void> insertEntry(JournalEntry entry) {
    return _dao.insertEntry(_toCompanion(entry));
  }

  /// Full-row update, keyed by [JournalEntry.id]. Not currently called by
  /// `JournalController` (entries are treated as append-only from the UI),
  /// but available — matches `TaskRepository.updateTask`'s shape and gives
  /// the sync layer a real update path instead of delete+re-insert.
  static Future<void> updateEntry(JournalEntry entry) {
    return _dao.updateEntryRow(entry.id, _toCompanion(entry));
  }

  /// Soft delete — see [JournalDao.softDeleteEntry].
  static Future<void> deleteEntry(String id) {
    return _dao.softDeleteEntry(id);
  }

  /// Hard delete every row. Used only by the Settings "clear all data"
  /// action, via `JournalController.clearAll()`.
  static Future<void> clearAll() {
    return _dao.hardDeleteAll();
  }

  static JournalEntry _fromRow(JournalEntryRow row) => JournalEntry(
        id: row.id,
        title: row.title,
        body: row.body,
        mood: JournalMood.values.byName(row.mood),
        timestamp: row.timestamp,
        accentColor: row.accentColorValue != null
            ? Color(row.accentColorValue!)
            : null,
      );

  static JournalEntriesCompanion _toCompanion(JournalEntry entry) =>
      JournalEntriesCompanion(
        id: Value(entry.id),
        title: Value(entry.title),
        body: Value(entry.body),
        mood: Value(entry.mood.name),
        timestamp: Value(entry.timestamp),
        accentColorValue: Value(entry.accentColor?.toARGB32()),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      );
}
