// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_only_dao.dart';

// ignore_for_file: type=lint
mixin _$LocalOnlyDaoMixin on DatabaseAccessor<AppDatabase> {
  $CheckinsTable get checkins => attachedDatabase.checkins;
  $DayClosesTable get dayCloses => attachedDatabase.dayCloses;
  $RhythmProfileTable get rhythmProfile => attachedDatabase.rhythmProfile;
  $CountersTable get counters => attachedDatabase.counters;
  LocalOnlyDaoManager get managers => LocalOnlyDaoManager(this);
}

class LocalOnlyDaoManager {
  final _$LocalOnlyDaoMixin _db;
  LocalOnlyDaoManager(this._db);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db.attachedDatabase, _db.checkins);
  $$DayClosesTableTableManager get dayCloses =>
      $$DayClosesTableTableManager(_db.attachedDatabase, _db.dayCloses);
  $$RhythmProfileTableTableManager get rhythmProfile =>
      $$RhythmProfileTableTableManager(_db.attachedDatabase, _db.rhythmProfile);
  $$CountersTableTableManager get counters =>
      $$CountersTableTableManager(_db.attachedDatabase, _db.counters);
}
