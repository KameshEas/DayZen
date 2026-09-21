import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

/// Today's completion as a ring, with the encouragement *below* it. (The
/// message used to sit inside the ring, where a whole sentence spilled over
/// the edge.)
class InsightsProductivityScoreCard extends StatelessWidget {
  const InsightsProductivityScoreCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final summary = data.todaySummary;
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.lg, vertical: DzSpacing.lg),
        child: Column(
          children: [
            const InsightsCardLabel('PRODUCTIVITY SCORE'),
            const SizedBox(height: DzSpacing.lg),
            Semantics(
              label: 'Productivity score ${data.productivityScore} out of 100',
              child: SizedBox(
                width: 168,
                height: 168,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: data.productivityScore / 100,
                    color: scheme.primary,
                    track: scheme.outline.withValues(alpha: 0.6),
                  ),
                  child: Center(
                    child: ExcludeSemantics(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${data.productivityScore}',
                            style: DzTextStyles.heading1.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: DzSpacing.xs),
                          Text(
                            'out of 100',
                            style: DzTextStyles.caption.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            Text(
              data.productivityDelta,
              textAlign: TextAlign.center,
              style: DzTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            if (summary != null) ...[
              const SizedBox(height: DzSpacing.xs),
              Text(
                summary,
                textAlign: TextAlign.center,
                style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: DzSpacing.md),
            Divider(color: scheme.outline, height: 1),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.aiQuote,
              textAlign: TextAlign.center,
              style: DzTextStyles.body.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });
  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}
