import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

class InsightsWeeklyCompletionCard extends StatelessWidget {
  const InsightsWeeklyCompletionCard({super.key, required this.data});
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
                Flexible(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY COMPLETION',
                      style: DzTextStyles.caption.copyWith(
                        color: DzColors.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.weeklyTasksDone} Tasks Done',
                      style: DzTextStyles.heading3
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DzColors.neutralTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last 7 Days',
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  data.completionBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InsightsBar(
                        fraction: data.completionBars[i],
                        label: InsightsData.completionDays[i],
                        highlight: i == DateTime.now().weekday - 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



