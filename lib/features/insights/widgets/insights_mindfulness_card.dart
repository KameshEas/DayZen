import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

/// Mindful sessions (zen-priority or mindful-category tasks) done out of
/// planned this week.
class InsightsMindfulnessCard extends StatelessWidget {
  const InsightsMindfulnessCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final planned = data.mindfulPlanned;
    final subtitle = planned == 0
        ? 'None planned this week'
        : '${data.mindfulDone} of $planned '
            '${planned == 1 ? 'session' : 'sessions'} done this week';
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InsightsCardLabel('MINDFULNESS'),
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: DzColors.successTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      color: DzColors.zenGreen, size: 22),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zen sessions',
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        subtitle,
                        style: DzTextStyles.caption
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            InsightsProgressBar(
              value: planned == 0 ? 0 : data.mindfulDone / planned,
              color: DzColors.zenGreen,
            ),
          ],
        ),
      ),
    );
  }
}
