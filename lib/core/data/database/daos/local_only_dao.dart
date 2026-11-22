import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/local_only_tables.dart';

part 'local_only_dao.g.dart';

/// Check-ins, day closes, the Rhythm profile and counters. All local only.
/// Later phases (Close the Day, Rhythm) add their own queries here.
@DriftAccessor(tables: [Checkins, DayCloses, RhythmProfile, Counters])
class LocalOnlyDao extends DatabaseAccessor<AppDatabase>
    with _$LocalOnlyDaoMixin {
  LocalOnlyDao(super.db);

  Future<void> addCheckin(CheckinsCompanion row) =>
      into(checkins).insert(row, mode: InsertMode.insertOrReplace);

  Future<List<CheckinRow>> checkinsSince(DateTime since) =>
      (select(checkins)..where((c) => c.at.isBiggerOrEqualValue(since))).get();

  Future<void> saveDayClose(DayClosesCompanion row) =>
      into(dayCloses).insert(row, mode: InsertMode.insertOrReplace);

  Future<DayCloseRow?> dayCloseFor(DateTime midnight) =>
      (select(dayCloses)..where((d) => d.date.equals(midnight)))
          .getSingleOrNull();

  Future<List<RhythmBinRow>> rhythmBins() => select(rhythmProfile).get();

  Future<void> saveRhythmBin(RhythmProfileCompanion row) =>
      into(rhythmProfile).insert(row, mode: InsertMode.insertOrReplace);

  /// Adds [by] to counter [key], creating it at 0 first if needed.
  Future<void> increment(String key, {int by = 1}) => transaction(() async {
        final current = await counter(key);
        await into(counters).insert(
          CountersCompanion.insert(
            key: key,
            value: Value(current + by),
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace,
        );
      });

  Future<int> counter(String key) async =>
      (await (select(counters)..where((c) => c.key.equals(key)))
              .getSingleOrNull())
          ?.value ??
      0;

  Future<void> clearAll() => transaction(() async {
        await delete(checkins).go();
        await delete(dayCloses).go();
        await delete(rhythmProfile).go();
        await delete(counters).go();
      });
}
