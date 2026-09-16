import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

class InsightsFocusTrendCard extends StatelessWidget {
  const InsightsFocusTrendCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FOCUS TIME TREND',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.trending_up_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  data.focusBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: InsightsBar(
                        fraction: data.focusBars[i],
                        label: InsightsData.focusDays[i],
                        highlight: i == DateTime.now().weekday - 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.totalFocusLabel,
              style: DzTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Total focus this week',
              style: DzTextStyles.caption
                  .copyWith(color: DzColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
