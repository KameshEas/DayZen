import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../logging/app_logger.dart';
import '../../security/secure_storage.dart';

/// Whole-database encryption (plan M-2.7) with SQLite3MultipleCiphers
/// (enabled in `pubspec.yaml` under `hooks: user_defines`).
///
/// - The key is 32 random bytes, hex-encoded, kept in secure storage
///   (Android Keystore-backed) and never synced or backed up.
/// - An existing plaintext database is encrypted in place once, with
///   `PRAGMA hexrekey`, on a background isolate.
/// - If the file can't be read with the key (secure storage was wiped, or a
///   backup was restored onto a new phone without the key), the file is set
///   aside, a fresh encrypted database is started, and [takeRecoveryNotice]
///   reports it once so the app can tell the user that signing in restores
///   synced tasks and journal entries.
class DbEncryption {
  DbEncryption._();

  static const _keyName = 'db_key_v1';
  static const _recoveredKey = 'db_recovered_at';
  static const _openSamplesKey = 'counter_db_open_ms';

  /// The database key, created on first use.
  static Future<String> loadOrCreateKey({FlutterSecureStorage? storage}) async {
    final s = storage ?? appSecureStorage;
    final existing = await s.read(key: _keyName);
    if (existing != null && RegExp(r'^[0-9a-f]{64}$').hasMatch(existing)) {
      return existing;
    }
    final rng = Random.secure();
    final key = List.generate(32, (_) => rng.nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    await s.write(key: _keyName, value: key);
    return key;
  }

  /// `PRAGMA hexkey` statement for [key], for drift's `setup` callback.
  static String keyPragma(String key) => "PRAGMA hexkey = '$key';";

  /// Makes [path] an encrypted database readable with [key], before drift
  /// opens it. Returns how it went. Runs the SQLite work off the UI thread.
  static Future<DbPrepareResult> prepare(String path, String key) async {
    final sw = Stopwatch()..start();
    final result = await Isolate.run(() => prepareSync(path, key));
    sw.stop();
    if (result == DbPrepareResult.recovered) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recoveredKey, DateTime.now().toIso8601String());
    }
    await _recordOpenSample(sw.elapsedMilliseconds);
    AppLogger.debug('Database prepare: $result in ${sw.elapsedMilliseconds} ms');
    return result;
  }

  /// The synchronous core of [prepare] (public for tests).
  static DbPrepareResult prepareSync(String path, String key) {
    final file = File(path);
    if (!file.existsSync()) return DbPrepareResult.fresh;

    // Already encrypted with this key?
    if (_readable(path, key: key)) return DbPrepareResult.alreadyEncrypted;

    // Plaintext from before encryption: encrypt it in place, once.
    if (_readable(path)) {
      final db = sqlite3.open(path);
      try {
        db.execute("PRAGMA hexrekey = '$key';");
      } finally {
        db.close();
      }
      if (_readable(path, key: key)) return DbPrepareResult.migrated;
      throw StateError('Database encryption did not take effect');
    }

    // Neither: encrypted with a key we no longer have. Keep the file (it
    // can't be read, but it isn't ours to delete) and start fresh.
    final aside = '$path.unreadable-${DateTime.now().millisecondsSinceEpoch}';
    file.renameSync(aside);
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final f = File('$path$suffix');
      if (f.existsSync()) f.deleteSync();
    }
    return DbPrepareResult.recovered;
  }

  static bool _readable(String path, {String? key}) {
    Database? db;
    try {
      db = sqlite3.open(path);
      if (key != null) db.execute("PRAGMA hexkey = '$key';");
      db.select('SELECT count(*) FROM sqlite_master');
      return true;
    } on SqliteException {
      return false;
    } finally {
      db?.close();
    }
  }

  /// True once, after a fresh start caused by an unreadable database.
  static Future<bool> takeRecoveryNotice() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_recoveredKey)) return false;
    await prefs.remove(_recoveredKey);
    return true;
  }

  /// Database prepare times (ms), newest last, for the benchmark gate: the
  /// tester counters screen shows them, so a before/after cold-start
  /// comparison can be made on a device.
  static Future<List<int>> openSamples() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_openSamplesKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toList();
  }

  static Future<void> _recordOpenSample(int ms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = [...(prefs.getStringList(_openSamplesKey) ?? const <String>[]), '$ms'];
      await prefs.setStringList(
          _openSamplesKey, list.length > 20 ? list.sublist(list.length - 20) : list);
    } catch (_) {}
  }
}

enum DbPrepareResult {
  /// No database yet; it will be created encrypted.
  fresh,

  /// Already encrypted with the stored key.
  alreadyEncrypted,

  /// A plaintext database was encrypted in place just now.
  migrated,

  /// The file couldn't be read with the key and was set aside.
  recovered,
}
