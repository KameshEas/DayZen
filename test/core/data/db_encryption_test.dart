import 'dart:convert';
import 'dart:io';

import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/db_encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Plan M-2.7: encryption at rest with SQLite3MultipleCiphers, including the
/// migration of an existing plaintext database and the lost-key recovery.
void main() {
  late Directory dir;
  late String path;
  const key = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
  const otherKey = 'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';

  setUp(() {
    dir = Directory.systemTemp.createTempSync('dz_enc_');
    path = '${dir.path}${Platform.pathSeparator}dayzen.sqlite';
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  void plaintextDb() {
    sqlite3.open(path)
      ..execute('CREATE TABLE notes(body TEXT)')
      ..execute("INSERT INTO notes VALUES ('secret journal line')")
      ..close();
  }

  List<String> read({String? withKey}) {
    final db = sqlite3.open(path);
    try {
      if (withKey != null) db.execute(DbEncryption.keyPragma(withKey));
      return [for (final r in db.select('SELECT body FROM notes')) r['body'] as String];
    } finally {
      db.close();
    }
  }

  bool fileLooksPlain() {
    final head = File(path).readAsBytesSync().take(16).toList();
    return ascii.decode(head, allowInvalid: true).startsWith('SQLite format 3');
  }

  test('the bundled SQLite is the encryption-capable build', () {
    final db = sqlite3.openInMemory();
    try {
      final v = db.select('SELECT sqlite3mc_version() AS v').single['v'];
      expect(v, isA<String>());
    } finally {
      db.close();
    }
  });

  test('no file yet → fresh', () {
    expect(DbEncryption.prepareSync(path, key), DbPrepareResult.fresh);
  });

  test('a plaintext database is encrypted in place, data intact', () {
    plaintextDb();
    expect(fileLooksPlain(), isTrue);

    expect(DbEncryption.prepareSync(path, key), DbPrepareResult.migrated);

    expect(fileLooksPlain(), isFalse, reason: 'header is now ciphertext');
    expect(File(path).readAsStringSync(encoding: latin1),
        isNot(contains('secret journal line')));
    expect(read(withKey: key), ['secret journal line']);
    expect(() => read(), throwsA(isA<SqliteException>()),
        reason: 'unreadable without the key');
  });

  test('the second start finds it already encrypted', () {
    plaintextDb();
    DbEncryption.prepareSync(path, key);
    expect(DbEncryption.prepareSync(path, key), DbPrepareResult.alreadyEncrypted);
    expect(read(withKey: key), ['secret journal line']);
  });

  test('a lost key sets the file aside and starts fresh', () {
    plaintextDb();
    DbEncryption.prepareSync(path, otherKey);

    expect(DbEncryption.prepareSync(path, key), DbPrepareResult.recovered);
    expect(File(path).existsSync(), isFalse);
    final aside = dir.listSync().whereType<File>()
        .where((f) => f.path.contains('.unreadable-'));
    expect(aside, hasLength(1), reason: 'kept, not deleted');
  });

  test('drift opens and writes an encrypted database with the key pragma', () async {
    final db = AppDatabase.forTesting(NativeDatabase(
      File(path),
      setup: (raw) => raw.execute(DbEncryption.keyPragma(key)),
    ));
    await db.customStatement('CREATE TABLE IF NOT EXISTS probe(x TEXT)');
    await db.customStatement("INSERT INTO probe VALUES ('hello')");
    await db.close();
    expect(fileLooksPlain(), isFalse);
    expect(DbEncryption.prepareSync(path, key), DbPrepareResult.alreadyEncrypted);
  });
}
