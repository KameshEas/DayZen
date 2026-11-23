import 'dart:math' as math;

import 'energy_profile.dart';

/// One observation about the user's energy at a moment in time.
///
/// Weights follow the plan (M-2.1): a check-in counts fully, finishing a
/// heavy task is half a vote for "high energy then", and a task planned for
/// an hour that got carried over or skipped is a small vote for "low then".
sealed class EnergyEvidence {
  const EnergyEvidence(this.at);

  final DateTime at;

  /// 0 (low) to 1 (high).
  double get value;

  /// Base weight before time decay.
  double get weight;
}

/// A 1-to-5 energy check-in.
class CheckinEvidence extends EnergyEvidence {
  const CheckinEvidence(super.at, this.energy)
      : assert(energy >= 1 && energy <= 5);

  final int energy;

  @override
  double get value => (energy - 1) / 4;

  @override
  double get weight => 1.0;
}

/// An effort-3 (heavy) task completed in the hour of [at].
class HeavyTaskDoneEvidence extends EnergyEvidence {
  const HeavyTaskDoneEvidence(super.at);

  @override
  double get value => 1.0;

  @override
  double get weight => 0.5;
}

/// A task planned for the hour of [at] that was rolled over or skipped.
class TaskSlippedEvidence extends EnergyEvidence {
  const TaskSlippedEvidence(super.at);

  @override
  double get value => 0.0;

  @override
  double get weight => 0.3;
}

/// Builds an [EnergyProfile] from a prior and evidence.
///
/// Deterministic and pure: same inputs, same profile. Each bin is a weighted
/// mean of the prior (a fixed pseudo-weight) and the decayed evidence. A
/// piece of evidence also leaks into the neighbouring hours (half weight one
/// hour away, a quarter two hours away), so a few check-ins shape a smooth
/// curve instead of isolated spikes.
class EnergyModel {
  EnergyModel._();

  /// Evidence loses half its weight every 21 days.
  static const halfLifeDays = 21.0;

  /// How strongly the prior holds a bin before evidence arrives.
  static const priorWeight = 2.0;

  /// Kernel for spreading evidence to neighbouring hours (offset 0, ±1, ±2).
  static const _kernel = [1.0, 0.5, 0.25];

  /// Total weight one piece of evidence spreads over its five bins.
  static const _kernelMass = 1.0 + 2 * 0.5 + 2 * 0.25;

  /// Reliability (see [compute]) below which the evidence is treated as
  /// noise, and the span over which confidence then ramps up to full.
  static const _reliabilityFloor = 0.3;
  static const _reliabilityRamp = 0.3;

  /// [resets] maps an hour to the moment the user tapped "Not me" on it:
  /// evidence for that hour from before the reset is ignored, and the hour
  /// falls back to the prior until new evidence arrives.
  static EnergyProfile compute({
    required RhythmPrior prior,
    required Iterable<EnergyEvidence> evidence,
    required DateTime now,
    Map<int, DateTime> resets = const {},
  }) {
    final priorValues = EnergyProfile.priorCurve(prior);
    final sumWV = List<double>.filled(24, 0);
    final sumWV2 = List<double>.filled(24, 0);
    final sumW = List<double>.filled(24, 0);

    for (final e in evidence) {
      final ageDays = now.difference(e.at).inMinutes / (60 * 24);
      if (ageDays < 0) continue; // from the future: clock skew, ignore
      final decay = math.pow(0.5, ageDays / halfLifeDays).toDouble();
      final w = e.weight * decay;
      final hour = e.at.hour;
      for (var off = -2; off <= 2; off++) {
        final bin = (hour + off) % 24;
        final reset = resets[bin];
        if (reset != null && !e.at.isAfter(reset)) continue;
        final kw = w * _kernel[off.abs()];
        sumWV[bin] += kw * e.value;
        sumWV2[bin] += kw * e.value * e.value;
        sumW[bin] += kw;
      }
    }

    final values = List<double>.generate(24, (h) {
      final num = priorValues[h] * priorWeight + sumWV[h];
      final den = priorWeight + sumW[h];
      return (num / den).clamp(0.0, 1.0);
    });

    // Effective sample count counts each piece of evidence once (the kernel
    // centre), not once per neighbouring bin it leaked into.
    final nEff = sumW.fold<double>(0, (a, b) => a + b) / _kernelMass;
    final r = reliability(sumW: sumW, sumWV: sumWV, sumWV2: sumWV2);
    final factor =
        ((r - _reliabilityFloor) / _reliabilityRamp).clamp(0.0, 1.0);

    return EnergyProfile(
      values: values,
      evidence: sumW,
      confidence: nEff * factor,
    );
  }

  /// How much of the evidence's spread is a real hour-to-hour pattern rather
  /// than noise: between-hour variance / (between + within-hour variance).
  /// Near 0 when energy is random whatever the hour (an irregular user),
  /// near 1 when each hour reports consistently and the hours differ.
  static double reliability({
    required List<double> sumW,
    required List<double> sumWV,
    required List<double> sumWV2,
  }) {
    final total = sumW.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return 0;
    var grand = 0.0;
    for (var h = 0; h < 24; h++) {
      grand += sumWV[h];
    }
    grand /= total;
    var within = 0.0;
    var between = 0.0;
    for (var h = 0; h < 24; h++) {
      if (sumW[h] <= 0) continue;
      final mean = sumWV[h] / sumW[h];
      within += sumWV2[h] - sumW[h] * mean * mean;
      between += sumW[h] * (mean - grand) * (mean - grand);
    }
    within /= total;
    between /= total;
    final spread = within + between;
    return spread <= 1e-12 ? 0 : between / spread;
  }
}
