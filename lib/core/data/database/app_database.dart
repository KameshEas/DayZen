import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/journal_dao.dart';
import 'daos/task_dao.dart';
import 'tables/journal_entries_table.dart';
import 'tables/tasks_table.dart';

part 'app_database.g.dart';

/// App-wide SQLite database (via drift), replacing the previous
/// SharedPreferences JSON-blob storage for tasks and journal entries.
///
/// SQLite binaries are provisioned automatically by `package:sqlite3`'s
/// native-assets hook (see sqlite3's doc/hook.md) — no separate
/// `sqlite3_flutter_libs`-style plugin dependency is needed as of
/// `package:sqlite3` v3+.
@DriftDatabase(tables: [Tasks, JournalEntries], daos: [TaskDao, JournalDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test-only constructor: inject an in-memory or otherwise pre-configured
  /// executor (e.g. `NativeDatabase.memory()`) instead of the real on-disk
  /// file.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  // Lazy: the native database file isn't actually opened until the first
  // query runs, and that happens in a background isolate so it never blocks
  // app startup.
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'dayzen.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
