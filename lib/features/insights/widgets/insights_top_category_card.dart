import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_shared_widgets.dart';

class InsightsTopCategoryCard extends StatelessWidget {
  const InsightsTopCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOP CATEGORY',
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
                    color: DzColors.neutralTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center_rounded,
                      color: DzColors.textSecondary, size: 22),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health & Wellness',
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Top focus area this week',
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            InsightsProgressBar(value: 0.72, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}



