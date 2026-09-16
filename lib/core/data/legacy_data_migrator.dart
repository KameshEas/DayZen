import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/models/task_model.dart';
import '../../features/journal/models/journal_entry.dart';
import 'journal_repository.dart';
import 'task_repository.dart';
import '../logging/app_logger.dart';

/// One-time migration from the pre-Phase-2 SharedPreferences JSON-blob
/// storage (see docs/BASELINE_METRICS.md) into the SQLite-backed
/// [TaskRepository]/[JournalRepository] (see docs/DATABASE_SCHEMA.md).
///
/// Call [migrateIfNeeded] once during app startup, **before** the first
/// `TaskController.load()` / `JournalController.load()` â€” otherwise a
/// user upgrading from a pre-Phase-2 install would see an empty task list
/// on first launch while their real data sits un-migrated in the old keys.
///
/// Safe to call on every startup: guarded by a migration-version flag, and
/// idempotent even if a previous attempt partially failed (task/entry
/// inserts use `INSERT OR REPLACE`, so re-running with the same source
/// data never creates duplicates). The legacy keys and the version flag
/// are only cleared/set once the *entire* migration succeeds â€” a failure
/// partway through leaves the legacy data in place for a retry on the next
/// launch, and never crashes startup.
class LegacyDataMigrator {
  LegacyDataMigrator._();

  static const _migrationVersionKey = 'dz_legacy_migration_version';
  static const _currentVersion = 1;

  static const _legacyTasksKey = 'dz_tasks';
  static const _legacyJournalKey = 'dz_journal_entries';

  static Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migratedVersion = prefs.getInt(_migrationVersionKey) ?? 0;
    if (migratedVersion >= _currentVersion) return;

    try {
      await _migrateTasks(prefs);
      await _migrateJournalEntries(prefs);
      await prefs.setInt(_migrationVersionKey, _currentVersion);
    } catch (e) {
      AppLogger.debug('Legacy data migration failed, will retry next launch: $e');
      // Deliberately don't set the version flag or clear legacy keys â€”
      // next launch retries from scratch. Never rethrow: a migration
      // failure must not block app startup.
    }
  }

  static Future<void> _migrateTasks(SharedPreferences prefs) async {
    final raw = prefs.getString(_legacyTasksKey);
    if (raw == null) return;

    final list = jsonDecode(raw) as List<dynamic>;
    final tasks = list
        .map((e) => DzTask.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final task in tasks) {
      await TaskRepository.insertTask(task);
    }

    await prefs.remove(_legacyTasksKey);
  }

  static Future<void> _migrateJournalEntries(SharedPreferences prefs) async {
    final raw = prefs.getString(_legacyJournalKey);
    if (raw == null) return;

    final list = jsonDecode(raw) as List<dynamic>;
    final entries = list
        .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final entry in entries) {
      await JournalRepository.insertEntry(entry);
    }

    await prefs.remove(_legacyJournalKey);
  }
}


