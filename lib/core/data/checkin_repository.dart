import 'package:drift/drift.dart' show Value;

import '../utils/ids.dart';
import 'database/app_database.dart';
import 'database/database_provider.dart';

/// One energy check-in (local only; never synced or backed up).
class Checkin {
  const Checkin({required this.id, required this.at, required this.energy, this.mood});

  final String id;
  final DateTime at;

  /// 1 (drained) to 5 (sharp).
  final int energy;
  final String? mood;
}

/// Energy check-ins (plan M-2.5) on the `checkins` table.
class CheckinRepository {
  const CheckinRepository();

  Future<Checkin> add(int energy, {DateTime? at, String? mood}) async {
    final when = at ?? DateTime.now();
    final c = Checkin(id: newId('checkin', now: when), at: when, energy: energy, mood: mood);
    await DatabaseProvider.instance.localOnlyDao.addCheckin(CheckinsCompanion(
      id: Value(c.id),
      at: Value(c.at),
      energy: Value(c.energy),
      mood: Value(c.mood),
    ));
    return c;
  }

  Future<List<Checkin>> since(DateTime from) async {
    final rows = await DatabaseProvider.instance.localOnlyDao.checkinsSince(from);
    return rows.map(_fromRow).toList()..sort((a, b) => a.at.compareTo(b.at));
  }

  /// Local midnights of days with at least one check-in since [from].
  Future<Set<DateTime>> answeredDays(DateTime from) async => {
        for (final c in await since(from)) DateTime(c.at.year, c.at.month, c.at.day),
      };

  static Checkin _fromRow(CheckinRow r) =>
      Checkin(id: r.id, at: r.at, energy: r.energy, mood: r.mood);
}
