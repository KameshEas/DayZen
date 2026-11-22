import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart' show ValueNotifier;

import 'database/app_database.dart';
import 'database/database_provider.dart';

/// One closed day (local only; never synced or backed up).
class DayCloseRecord {
  const DayCloseRecord({
    required this.date,
    required this.closedAt,
    required this.done,
    required this.carried,
    required this.released,
    this.journalEntryId,
  });

  /// Local midnight of the closed day.
  final DateTime date;
  final DateTime closedAt;
  final int done;
  final int carried;
  final int released;
  final String? journalEntryId;
}

/// Where Close the Day reads and writes its records. An interface so tests
/// can use an in-memory fake.
abstract class DayCloseStore {
  Future<DayCloseRecord?> forDay(DateTime midnight);
  Future<void> save(DayCloseRecord record);

  /// Closed days between [from] and [to] inclusive (midnights).
  Future<List<DayCloseRecord>> between(DateTime from, DateTime to);
}

/// Drift-backed store on the `day_closes` table.
class DayCloseRepository implements DayCloseStore {
  const DayCloseRepository();

  /// Bumped after every save, so screens showing a day's close (the Home
  /// card) refresh even when they were rebuilt while Close the Day was open.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  static DateTime midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Future<DayCloseRecord?> forDay(DateTime day) async {
    final row = await DatabaseProvider.instance.localOnlyDao
        .dayCloseFor(midnight(day));
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<void> save(DayCloseRecord r) async {
    await DatabaseProvider.instance.localOnlyDao.saveDayClose(DayClosesCompanion(
      date: Value(midnight(r.date)),
      closedAt: Value(r.closedAt),
      done: Value(r.done),
      carried: Value(r.carried),
      released: Value(r.released),
      journalEntryId: Value(r.journalEntryId),
    ));
    changes.value++;
  }

  @override
  Future<List<DayCloseRecord>> between(DateTime from, DateTime to) async {
    final rows = await DatabaseProvider.instance.localOnlyDao
        .dayClosesBetween(midnight(from), midnight(to));
    return rows.map(_fromRow).toList();
  }

  static DayCloseRecord _fromRow(DayCloseRow row) => DayCloseRecord(
        date: row.date,
        closedAt: row.closedAt,
        done: row.done,
        carried: row.carried,
        released: row.released,
        journalEntryId: row.journalEntryId,
      );
}
