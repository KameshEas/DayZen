import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';

class InsightsProductivityScoreCard extends StatelessWidget {
  const InsightsProductivityScoreCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.lg, vertical: DzSpacing.lg),
        child: Column(
          children: [
            Text(
              'PRODUCTIVITY SCORE',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: data.productivityScore / 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.productivityScore}',
                        style: DzTextStyles.heading1.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        data.productivityDelta,
                        style: DzTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.aiQuote,
              textAlign: TextAlign.center,
              style: DzTextStyles.body.copyWith(
                color: DzColors.textSecondary,
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
  const _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = DzColors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}



