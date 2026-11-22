import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_prefs.dart';
import '../../core/data/checkin_repository.dart';
import '../../core/data/database/app_database.dart';
import '../../core/data/database/database_provider.dart';
import '../../core/domain/rhythm/energy_model.dart';
import '../../core/domain/rhythm/energy_profile.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/counters_service.dart';
import '../home/models/task_model.dart';

/// Owns the user's Rhythm (plan M-2.1/M-2.4): the onboarding prior, the
/// evidence (check-ins, heavy tasks done, tasks that slipped), "Not me"
/// resets, and the computed [EnergyProfile]. All local; nothing syncs.
class RhythmController extends ChangeNotifier {
  RhythmController({
    CheckinRepository? checkins,
    DateTime Function()? clock,
    bool persist = true,
  })  : _checkins = checkins ?? const CheckinRepository(),
        _clock = clock ?? DateTime.now,
        _persist = persist;

  final CheckinRepository _checkins;
  final DateTime Function() _clock;
  final bool _persist;

  static const _resetsKey = 'rhythm_resets';

  /// How far back evidence is read. Older evidence has decayed to almost
  /// nothing (21-day half-life).
  static const lookback = Duration(days: 90);

  RhythmPrior _prior = RhythmPrior.notSure;
  RhythmPrior get prior => _prior;

  EnergyProfile _profile = EnergyProfile.prior(RhythmPrior.notSure);
  EnergyProfile get profile => _profile;

  Map<int, DateTime> _resets = {};
  List<EnergyEvidence> _evidence = const [];

  /// Loads the prior, resets and check-ins, then computes the profile from
  /// them plus [tasks]. Never throws: on failure the prior curve stands.
  Future<void> load(List<DzTask> tasks) async {
    try {
      final name = await AppPrefs.rhythmPriorName();
      _prior = RhythmPrior.values.asNameMap()[name] ?? RhythmPrior.notSure;
      _resets = await _loadResets();
      final since = _clock().subtract(lookback);
      final checkins = await _checkins.since(since);
      _evidence = [
        for (final c in checkins) CheckinEvidence(c.at, c.energy),
        ...evidenceFromTasks(tasks, since: since),
      ];
    } catch (e) {
      AppLogger.warning('Rhythm evidence unavailable: $e');
    }
    _recompute();
  }

  /// Re-reads task evidence after tasks changed (cheap: no I/O for tasks).
  void updateTasks(List<DzTask> tasks) {
    final since = _clock().subtract(lookback);
    _evidence = [
      ..._evidence.whereType<CheckinEvidence>(),
      ...evidenceFromTasks(tasks, since: since),
    ];
    _recompute();
  }

  /// A new check-in, added without reloading.
  void addCheckin(DateTime at, int energy) {
    _evidence = [..._evidence, CheckinEvidence(at, energy)];
    _recompute();
  }

  /// "Not me" on [hour]: older evidence for that hour stops counting and the
  /// hour falls back to the prior until new evidence arrives (M-2.4).
  Future<void> notMe(int hour) async {
    _resets = {..._resets, hour % 24: _clock()};
    _recompute();
    await CountersService.instance.increment(CountersService.notMeTaps);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetsKey, jsonEncode({
      for (final e in _resets.entries) '${e.key}': e.value.toIso8601String(),
    }));
  }

  /// "Not me" on a whole window, e.g. the sharpest window shown on Home.
  Future<void> notMeWindow(HourWindow w) async {
    for (var h = w.startHour; h < w.endHour; h++) {
      await notMe(h);
    }
  }

  void _recompute() {
    _profile = EnergyModel.compute(
      prior: _prior,
      evidence: _evidence,
      now: _clock(),
      resets: _resets,
    );
    notifyListeners();
    if (_persist) unawaited(_saveProfile());
  }

  Future<Map<int, DateTime>> _loadResets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_resetsKey);
    if (raw == null) return {};
    final map = (jsonDecode(raw) as Map).cast<String, String>();
    return {
      for (final e in map.entries)
        if (int.tryParse(e.key) != null && DateTime.tryParse(e.value) != null)
          int.parse(e.key): DateTime.parse(e.value),
    };
  }

  /// Keeps the latest curve in `rhythm_profile` (read by the home-screen
  /// widget and the weekly history snapshot).
  Future<void> _saveProfile() async {
    try {
      final dao = DatabaseProvider.instance.localOnlyDao;
      final now = _clock();
      for (var h = 0; h < 24; h++) {
        await dao.saveRhythmBin(RhythmProfileCompanion(
          bin: Value(h),
          value: Value(_profile.values[h]),
          weight: Value(_profile.evidence[h]),
          updatedAt: Value(now),
        ));
      }
    } catch (e) {
      AppLogger.warning('Rhythm profile not saved: $e');
    }
  }

  /// Task evidence: a heavy (effort 3) task done counts for the hour it was
  /// finished; a task that was carried over or let go counts against the
  /// hour it was first planned for.
  static List<EnergyEvidence> evidenceFromTasks(
    List<DzTask> tasks, {
    required DateTime since,
  }) {
    final out = <EnergyEvidence>[];
    for (final t in tasks) {
      if (t.status == TaskStatus.done && (t.effort ?? 0) >= 3) {
        final at = t.completedAt;
        if (at != null && at.isAfter(since)) out.add(HeavyTaskDoneEvidence(at));
      }
      final slipped = t.status == TaskStatus.released || t.rolloverCount > 0;
      if (slipped) {
        final day = t.originalDate ?? t.date;
        final at = DateTime(day.year, day.month, day.day, t.startTime.hour,
            t.startTime.minute);
        if (at.isAfter(since)) out.add(TaskSlippedEvidence(at));
      }
    }
    return out;
  }

  /// "Your sharpest window: ~9–11 am · forming".
  static String windowSentence(EnergyProfile p) {
    final w = p.sharpestWindow();
    final label = '${hourLabel(w.startHour)}–${hourLabel(w.endHour)}';
    return p.isForming
        ? 'Your sharpest window: ~$label · forming'
        : 'Your sharpest window: ~$label';
  }

  static String hourLabel(int hour) {
    final h = hour % 24;
    final suffix = h < 12 ? 'am' : 'pm';
    final display = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$display $suffix';
  }
}
