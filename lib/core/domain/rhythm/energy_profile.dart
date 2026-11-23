/// Rhythm v1 (plan M-2.1): a 24-bin energy curve, one bin per hour.
///
/// Pure Dart: no Flutter imports, no I/O. [EnergyModel] builds profiles from
/// evidence; this file holds the curve itself and the four onboarding priors.
library;

/// The "When are you sharpest?" answer from onboarding step 2.
enum RhythmPrior { morning, midday, evening, notSure }

extension RhythmPriorX on RhythmPrior {
  String get label => switch (this) {
        RhythmPrior.morning => 'Morning',
        RhythmPrior.midday => 'Midday',
        RhythmPrior.evening => 'Evening',
        RhythmPrior.notSure => 'Not sure',
      };
}

/// A contiguous run of hours, `[startHour, endHour)`.
typedef HourWindow = ({int startHour, int endHour});

class EnergyProfile {
  EnergyProfile({
    required List<double> values,
    required List<double> evidence,
    required this.confidence,
  })  : assert(values.length == 24 && evidence.length == 24),
        values = List.unmodifiable(values),
        evidence = List.unmodifiable(evidence);

  /// Energy per hour, 0 (low) to 1 (high).
  final List<double> values;

  /// Decayed evidence weight per hour (prior excluded).
  final List<double> evidence;

  /// Effective sample count, scaled down when the curve is flat (an
  /// irregular day-to-day pattern). Below [formingBelow] the profile is
  /// "forming" and the UI says so.
  final double confidence;

  static const double formingBelow = 10;

  /// Waking hours considered for windows and contrast.
  static const int wakeStart = 6;
  static const int wakeEnd = 23;

  bool get isForming => confidence < formingBelow;

  double at(int hour) => values[hour % 24];

  /// Mean energy over `[startMinute, endMinute)` (minutes after midnight).
  double meanOver(int startMinute, int endMinute) {
    if (endMinute <= startMinute) return at(startMinute ~/ 60);
    var sum = 0.0;
    var n = 0;
    for (var m = startMinute; m < endMinute; m += 15) {
      sum += at(m ~/ 60);
      n++;
    }
    return sum / n;
  }

  /// The waking hour with the highest energy (earliest on a tie).
  int get peakHour {
    var best = wakeStart;
    for (var h = wakeStart; h < wakeEnd; h++) {
      if (values[h] > values[best] + 1e-9) best = h;
    }
    return best;
  }

  /// The best [length]-hour waking window (earliest on a tie).
  HourWindow sharpestWindow({int length = 2}) {
    var bestStart = wakeStart;
    var bestScore = double.negativeInfinity;
    for (var h = wakeStart; h + length <= wakeEnd; h++) {
      var score = 0.0;
      for (var i = 0; i < length; i++) {
        score += values[h + i];
      }
      if (score > bestScore + 1e-9) {
        bestScore = score;
        bestStart = h;
      }
    }
    return (startHour: bestStart, endHour: bestStart + length);
  }

  /// p90 − p10 of the waking bins: how pronounced the curve is (0 = flat).
  double get contrast => contrastOf(values);

  static double contrastOf(List<double> values) {
    final waking = values.sublist(wakeStart, wakeEnd).toList()..sort();
    final lo = waking[(waking.length * 0.1).floor()];
    final hi = waking[(waking.length * 0.9).floor().clamp(0, waking.length - 1)];
    return hi - lo;
  }

  /// The prior curve for an onboarding answer, with zero evidence.
  factory EnergyProfile.prior(RhythmPrior prior) => EnergyProfile(
        values: priorCurve(prior),
        evidence: List.filled(24, 0),
        confidence: 0,
      );

  /// Hand-shaped prior curves. Night hours are low for everyone; the waking
  /// shape follows the answer. "Not sure" is a gentle late-morning and
  /// mid-afternoon double hump, close to flat.
  static List<double> priorCurve(RhythmPrior prior) => List.unmodifiable(
        switch (prior) {
          RhythmPrior.morning => _morning,
          RhythmPrior.midday => _midday,
          RhythmPrior.evening => _evening,
          RhythmPrior.notSure => _notSure,
        },
      );

  //                                0     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19    20    21    22    23
  static const _morning = <double>[0.10, 0.08, 0.05, 0.05, 0.08, 0.20, 0.45, 0.70, 0.85, 0.90, 0.85, 0.75, 0.60, 0.50, 0.50, 0.55, 0.50, 0.45, 0.40, 0.35, 0.30, 0.25, 0.20, 0.15];
  static const _midday = <double>[0.10, 0.08, 0.05, 0.05, 0.05, 0.10, 0.25, 0.40, 0.55, 0.65, 0.75, 0.85, 0.90, 0.85, 0.75, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.30, 0.25, 0.15];
  static const _evening = <double>[0.30, 0.20, 0.10, 0.05, 0.05, 0.05, 0.10, 0.20, 0.30, 0.40, 0.45, 0.50, 0.50, 0.50, 0.55, 0.60, 0.65, 0.75, 0.80, 0.85, 0.90, 0.85, 0.70, 0.50];
  static const _notSure = <double>[0.10, 0.08, 0.05, 0.05, 0.05, 0.15, 0.35, 0.50, 0.58, 0.62, 0.65, 0.65, 0.58, 0.55, 0.58, 0.62, 0.62, 0.58, 0.52, 0.48, 0.42, 0.35, 0.25, 0.15];
}
