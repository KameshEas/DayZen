import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_shared_widgets.dart';

class InsightsMindfulnessCard extends StatelessWidget {
  const InsightsMindfulnessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MINDFULNESS',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                        'Zen Sessions',
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Daily mindfulness practice',
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            const InsightsProgressBar(value: 0.55, color: DzColors.zenGreen),
          ],
        ),
      ),
    );
  }
}



