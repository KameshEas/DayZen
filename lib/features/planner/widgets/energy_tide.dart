import 'package:flutter/material.dart';

import '../../../core/domain/rhythm/energy_profile.dart';

/// The Rhythm "tide" (plan M-2.4): a soft gradient behind a timeline, deeper
/// where energy is higher. Purely decorative: screen readers get the
/// sharpest-window sentence instead, so this is excluded from semantics.
///
/// Static (no animation), so it needs no reduced-motion variant.
class EnergyTide extends StatelessWidget {
  const EnergyTide({
    super.key,
    required this.profile,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    this.topOffset = 0,
    this.color,
  });

  final EnergyProfile profile;

  /// First and last hour the timeline shows, `[startHour, endHour)`.
  final int startHour;
  final int endHour;
  final double hourHeight;

  /// Space above [startHour]'s line (e.g. a header inside the same stack).
  final double topOffset;

  /// Defaults to the theme's primary colour.
  final Color? color;

  /// Strongest and weakest tint, as alpha.
  static const double maxAlpha = 0.20;
  static const double minAlpha = 0.0;

  @override
  Widget build(BuildContext context) {
    final base = color ?? Theme.of(context).colorScheme.primary;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size(double.infinity, topOffset + (endHour - startHour) * hourHeight),
        painter: _TidePainter(
          profile: profile,
          startHour: startHour,
          endHour: endHour,
          hourHeight: hourHeight,
          topOffset: topOffset,
          color: base,
        ),
      ),
    );
  }
}

class _TidePainter extends CustomPainter {
  _TidePainter({
    required this.profile,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.topOffset,
    required this.color,
  });

  final EnergyProfile profile;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final double topOffset;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final hours = endHour - startHour;
    if (hours <= 0) return;
    final height = hours * hourHeight;
    // One stop per hour, at the hour's middle, so neighbouring hours blend.
    final colors = <Color>[];
    final stops = <double>[];
    for (var i = 0; i < hours; i++) {
      final e = profile.at(startHour + i);
      final alpha = EnergyTide.minAlpha + (EnergyTide.maxAlpha - EnergyTide.minAlpha) * e;
      colors.add(color.withValues(alpha: alpha));
      stops.add((i + 0.5) / hours);
    }
    if (colors.length == 1) {
      colors.add(colors.first);
      stops
        ..clear()
        ..addAll([0, 1]);
    }
    final rect = Rect.fromLTWH(0, topOffset, size.width, height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      paint,
    );
  }

  @override
  bool shouldRepaint(_TidePainter old) =>
      old.profile != profile ||
      old.startHour != startHour ||
      old.endHour != endHour ||
      old.hourHeight != hourHeight ||
      old.topOffset != topOffset ||
      old.color != color;
}
