import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

/// Tasks completed this week, and the share of each day's tasks that got done.
class InsightsWeeklyCompletionCard extends StatelessWidget {
  const InsightsWeeklyCompletionCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = data.weeklyTasksDone;
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const InsightsCardLabel('WEEKLY COMPLETION'),
                      const SizedBox(height: DzSpacing.xs),
                      Text(
                        '$done ${done == 1 ? 'task' : 'tasks'} done',
                        style: DzTextStyles.heading3
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DzSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: insightsNeutralTint(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'This week',
                    style: DzTextStyles.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: done > 0 ? 92 : 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  data.completionBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InsightsBar(
                        fraction: data.completionBars[i],
                        label: InsightsData.completionDays[i],
                        highlight: i == data.todayIndex,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              'Each bar is the share of that day\'s tasks you finished.',
              style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
