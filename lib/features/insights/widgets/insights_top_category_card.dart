import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/models/task_model.dart';
import 'insights_data.dart';
import 'insights_shared_widgets.dart';

/// The category the user spent the week on: most tasks completed, or, before
/// anything is done, most planned. Hidden when the week has no tasks.
class InsightsTopCategoryCard extends StatelessWidget {
  const InsightsTopCategoryCard({super.key, required this.data});
  final InsightsData data;

  static IconData iconFor(TaskCategory c) => switch (c) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.mindful => Icons.self_improvement_rounded,
        TaskCategory.study => Icons.menu_book_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final stat = data.topCategory;
    if (stat == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InsightsCardLabel('TOP CATEGORY'),
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: insightsNeutralTint(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconFor(stat.category),
                      color: scheme.onSurfaceVariant, size: 22),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.category.label,
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${stat.completed} of ${stat.planned} '
                        '${stat.planned == 1 ? 'task' : 'tasks'} done this week',
                        style: DzTextStyles.caption
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            InsightsProgressBar(value: stat.fraction, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
