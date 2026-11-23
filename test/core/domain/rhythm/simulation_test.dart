import 'dart:math' as math;

import 'package:dayzen/core/domain/rhythm/energy_model.dart';
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plan M-2.2: synthetic users with noise. Every user starts from the
/// "Not sure" prior, so the model has to find the peak from evidence alone.
void main() {
  final start = DateTime(2027, 1, 4); // a Monday

  /// A true energy curve peaking at [peak] (0..1), wrapping round midnight.
  double truth(int hour, int peak) {
    final d = math.min((hour - peak).abs(), 24 - (hour - peak).abs());
    return math.max(0.05, 1 - d / 7);
  }

  /// [days] of evidence: two check-ins a day at varied waking hours, plus a
  /// heavy task finished near the peak every other day.
  List<EnergyEvidence> simulate({
    required int days,
    required int seed,
    int? peak,
  }) {
    final rng = math.Random(seed);
    final out = <EnergyEvidence>[];
    for (var d = 0; d < days; d++) {
      final day = start.add(Duration(days: d));
      for (var i = 0; i < 2; i++) {
        final hour = 7 + rng.nextInt(16); // 07:00–22:59
        final at = day.add(Duration(hours: hour, minutes: rng.nextInt(60)));
        final int energy;
        if (peak == null) {
          energy = 1 + rng.nextInt(5); // irregular: no pattern at all
        } else {
          final noisy = truth(hour, peak) * 4 + 1 + (rng.nextDouble() - 0.5) * 1.6;
          energy = noisy.round().clamp(1, 5);
        }
        out.add(CheckinEvidence(at, energy));
      }
      if (peak != null && d.isOdd) {
        final hour = (peak + rng.nextInt(3) - 1) % 24;
        out.add(HeavyTaskDoneEvidence(day.add(Duration(hours: hour))));
      }
    }
    return out;
  }

  EnergyProfile run({required int days, required int seed, int? peak}) =>
      EnergyModel.compute(
        prior: RhythmPrior.notSure,
        evidence: simulate(days: days, seed: seed, peak: peak),
        now: start.add(Duration(days: days)),
      );

  int circularDistance(int a, int b) =>
      math.min((a - b).abs(), 24 - (a - b).abs());

  group('morning person (true peak 09:00)', () {
    test('peak within ±1 h of the truth by day 14, across seeds', () {
      for (var seed = 1; seed <= 10; seed++) {
        final p = run(days: 14, seed: seed, peak: 9);
        expect(circularDistance(p.peakHour, 9), lessThanOrEqualTo(1),
            reason: 'seed $seed: peak ${p.peakHour}');
      }
    });

    test('is no longer "forming" by day 14', () {
      final p = run(days: 14, seed: 3, peak: 9);
      expect(p.isForming, isFalse, reason: 'confidence ${p.confidence}');
    });
  });

  group('night owl (true peak 21:00)', () {
    test('peak within ±1 h of the truth by day 14, across seeds', () {
      for (var seed = 1; seed <= 10; seed++) {
        final p = run(days: 14, seed: seed, peak: 21);
        expect(circularDistance(p.peakHour, 21), lessThanOrEqualTo(1),
            reason: 'seed $seed: peak ${p.peakHour}');
      }
    });
  });

  group('irregular user', () {
    test('stays flat-ish and low-confidence after 14 days, across seeds', () {
      for (var seed = 1; seed <= 10; seed++) {
        final p = run(days: 14, seed: seed);
        expect(p.isForming, isTrue,
            reason: 'seed $seed: confidence ${p.confidence}');
      }
    });

    test('is clearly less confident than a patterned user', () {
      final irregular = run(days: 14, seed: 5);
      final morning = run(days: 14, seed: 5, peak: 9);
      expect(irregular.confidence, lessThan(morning.confidence / 2));
    });
  });

  group('model properties', () {
    test('no evidence returns the prior exactly, with zero confidence', () {
      final p = EnergyModel.compute(
        prior: RhythmPrior.evening,
        evidence: const [],
        now: start,
      );
      expect(p.values, EnergyProfile.priorCurve(RhythmPrior.evening));
      expect(p.confidence, 0);
      expect(p.isForming, isTrue);
    });

    test('is deterministic', () {
      final a = run(days: 30, seed: 7, peak: 10);
      final b = run(days: 30, seed: 7, peak: 10);
      expect(a.values, b.values);
      expect(a.confidence, b.confidence);
    });

    test('old evidence counts less than fresh evidence (21-day half-life)', () {
      final at = DateTime(2027, 1, 1, 10);
      EnergyProfile after(int days) => EnergyModel.compute(
            prior: RhythmPrior.notSure,
            evidence: [CheckinEvidence(at, 1)],
            now: at.add(Duration(days: days)),
          );
      expect(after(21).evidence[10], closeTo(after(0).evidence[10] / 2, 1e-9));
      expect(after(42).values[10], greaterThan(after(0).values[10]),
          reason: 'a decayed low check-in pulls the bin down less');
    });

    test('"Not me" drops older evidence for that hour back to the prior', () {
      final at = DateTime(2027, 1, 1, 14);
      final evidence = [for (var i = 0; i < 10; i++) CheckinEvidence(at, 5)];
      final now = at.add(const Duration(days: 1));
      final before = EnergyModel.compute(
          prior: RhythmPrior.morning, evidence: evidence, now: now);
      final after = EnergyModel.compute(
        prior: RhythmPrior.morning,
        evidence: evidence,
        now: now,
        resets: {14: at.add(const Duration(minutes: 1))},
      );
      expect(before.values[14], greaterThan(0.8));
      expect(after.values[14],
          closeTo(EnergyProfile.priorCurve(RhythmPrior.morning)[14], 1e-9));
    });

    test('recomputes 90 days of dense evidence well under 50 ms', () {
      final evidence = simulate(days: 90, seed: 1, peak: 9);
      // Warm up once, then time.
      EnergyModel.compute(
          prior: RhythmPrior.morning, evidence: evidence, now: DateTime.now());
      final sw = Stopwatch()..start();
      for (var i = 0; i < 10; i++) {
        EnergyModel.compute(
            prior: RhythmPrior.morning, evidence: evidence, now: DateTime.now());
      }
      sw.stop();
      expect(sw.elapsedMilliseconds / 10, lessThan(50));
    });
  });
}
