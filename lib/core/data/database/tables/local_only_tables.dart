import 'package:drift/drift.dart';

// Schema v2 tables that never leave the phone: they are not synced and are
// excluded from Android Auto Backup.

/// Energy check-ins (1 to 5), optionally with a mood label.
@DataClassName('CheckinRow')
class Checkins extends Table {
  TextColumn get id => text()();
  DateTimeColumn get at => dateTime()();
  // drift's CHECK syntax refers to the column itself; not a recursion.
  // ignore: recursive_getters
  IntColumn get energy =>
      integer().check(energy.isBetweenValues(1, 5))();
  TextColumn get mood => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One row per closed day, keyed by local midnight.
@DataClassName('DayCloseRow')
class DayCloses extends Table {
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get closedAt => dateTime()();
  IntColumn get done => integer()();
  IntColumn get carried => integer()();
  IntColumn get released => integer()();
  TextColumn get journalEntryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {date};
}

/// Learned energy curve: one row per hour of the day (0 to 23).
@DataClassName('RhythmBinRow')
class RhythmProfile extends Table {
  // ignore: recursive_getters
  IntColumn get bin => integer().check(bin.isBetweenValues(0, 23))();
  RealColumn get value => real()();
  RealColumn get weight => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {bin};
}

/// Local usage counters (no upload).
@DataClassName('CounterRow')
class Counters extends Table {
  TextColumn get key => text()();
  IntColumn get value => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

/// One Rhythm curve per week (schema v3, plan M-4.2), keyed by the week's
/// Monday at local midnight. Local only, like the profile itself.
@DataClassName('RhythmHistoryRow')
class RhythmProfileHistory extends Table {
  DateTimeColumn get weekStart => dateTime()();

  /// 24 comma-separated values, 0..1, one per hour.
  TextColumn get curve => text()();
  RealColumn get confidence => real()();
  DateTimeColumn get savedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {weekStart};
}
