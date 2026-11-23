import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/daos/local_only_dao.dart';
import '../data/database/database_provider.dart';
import '../logging/app_logger.dart';

/// Local usage counters (plan M-1.11). Nothing here ever leaves the phone:
/// testers read the numbers from the debug screen and copy them into their
/// feedback form by hand.
///
/// Every method swallows its own errors. A counter failing to save must never
/// break the feature that bumped it.
class CountersService {
  CountersService._();

  static final CountersService instance = CountersService._();

  // ── Counter keys ──────────────────────────────────────────────────────
  static const onboardingStarted = 'onboarding_started';
  static const onboardingCompleted = 'onboarding_completed';
  static const daysClosed = 'days_closed';
  static const closePrompts = 'close_prompts';
  static const checkinPrompts = 'checkin_prompts';
  static const checkinAnswers = 'checkin_answers';
  static const notMeTaps = 'not_me_taps';

  /// Every counter the debug screen lists, in display order.
  static const all = [
    onboardingStarted,
    onboardingCompleted,
    daysClosed,
    closePrompts,
    checkinPrompts,
    checkinAnswers,
    notMeTaps,
  ];

  /// Time-to-first-plan samples (ms). Stored as a list, not a counter: the
  /// KPI is a median.
  static const _ttfpKey = 'counter_ttfp_ms';

  /// Most samples kept. Old ones are dropped first.
  static const maxTtfpSamples = 50;

  LocalOnlyDao get _dao => DatabaseProvider.instance.localOnlyDao;

  Future<void> increment(String key, {int by = 1}) async {
    try {
      await _dao.increment(key, by: by);
    } catch (e) {
      AppLogger.warning('Counter $key not saved: $e');
    }
  }

  Future<int> value(String key) async {
    try {
      return await _dao.counter(key);
    } catch (_) {
      return 0;
    }
  }

  /// All counters, in [all] order.
  Future<Map<String, int>> snapshot() async => {
        for (final key in all) key: await value(key),
      };

  Future<void> addTtfpSample(Duration elapsed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final samples = [
        ...(prefs.getStringList(_ttfpKey) ?? const <String>[]),
        '${elapsed.inMilliseconds}',
      ];
      final kept = samples.length > maxTtfpSamples
          ? samples.sublist(samples.length - maxTtfpSamples)
          : samples;
      await prefs.setStringList(_ttfpKey, kept);
    } catch (e) {
      AppLogger.warning('TTFP sample not saved: $e');
    }
  }

  Future<List<int>> ttfpSamples() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_ttfpKey) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toList();
  }

  /// Median of [samples], or null when there are none.
  static int? median(List<int> samples) {
    if (samples.isEmpty) return null;
    final sorted = [...samples]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }

  /// The tester feedback export: plain JSON with counts only, no content.
  Future<String> exportJson() async {
    final ttfp = await ttfpSamples();
    return const JsonEncoder.withIndent('  ').convert({
      'counters': await snapshot(),
      'ttfp_ms': {'samples': ttfp, 'median': median(ttfp)},
      'exported_at': DateTime.now().toIso8601String(),
    });
  }

  /// Wipes counters too (Settings "clear all data" / account deletion).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ttfpKey);
  }
}
