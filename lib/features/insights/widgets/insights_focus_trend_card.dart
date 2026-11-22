import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

/// Focus time per day this week (completed tasks' durations), with the week's
/// total as the headline number.
class InsightsFocusTrendCard extends StatelessWidget {
  const InsightsFocusTrendCard({super.key, required this.data});
  final InsightsData data;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const InsightsCardLabel('FOCUS TIME TREND'),
                Icon(Icons.trending_up_rounded, color: scheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.weekFocusLabel,
              style: DzTextStyles.heading1.copyWith(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            Text(
              'Total focus this week',
              style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: data.hasFocusTime ? 112 : 64,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  data.focusBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InsightsBar(
                        fraction: data.focusBars[i],
                        label: InsightsData.focusDays[i],
                        highlight: i == data.todayIndex,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!data.hasFocusTime) ...[
              const SizedBox(height: DzSpacing.md),
              Text(
                'Complete a task and its time shows up here.',
                style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
