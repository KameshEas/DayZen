import 'app_database.dart';

/// Process-wide [AppDatabase] singleton. Repositories go through this
/// instead of each opening their own connection to the same SQLite file.
class DatabaseProvider {
  DatabaseProvider._();

  static AppDatabase? _instance;

  static AppDatabase get instance => _instance ??= AppDatabase();

  /// Test-only: inject a caller-provided database (e.g. one backed by
  /// `NativeDatabase.memory()`) in place of the real on-disk singleton.
  static set instanceForTesting(AppDatabase db) => _instance = db;

  /// Test-only: clear the singleton so the next [instance] access opens a
  /// fresh (real) database. Call in `tearDown` after using
  /// [instanceForTesting].
  static void resetForTesting() => _instance = null;
}
