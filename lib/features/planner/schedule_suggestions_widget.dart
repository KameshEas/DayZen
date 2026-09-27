import 'package:flutter/material.dart';
import '../../core/ai/day_optimizer.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import '../home/widgets/day_optimizer_break_card.dart';
import '../home/widgets/day_optimizer_suggestion_tile.dart';

/// Offline, on-device schedule suggestions for [tasks] — computed directly
/// from [DayOptimizer.optimise], so unlike the old remote-backed version
/// there's no loading/error state to show: it always has an answer.
class ScheduleSuggestionsWidget extends StatelessWidget {
  final List<DzTask> tasks;

  const ScheduleSuggestionsWidget({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return DzCard(
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: DzColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: DzSpacing.md),
            const Text('No tasks scheduled', style: DzTextStyles.body),
            const SizedBox(height: DzSpacing.sm),
            const Text(
              'Add tasks to get schedule suggestions',
              style: DzTextStyles.small,
            ),
          ],
        ),
      );
    }

    final result = DayOptimizer.optimise(tasks);
    final taskCtrl = TaskScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Schedule',
                      style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Offline — optimized for ${result.focusTimeMinutes} min focus',
                      style: DzTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Column(
            children: [
              ...result.suggestions.map((s) => DayOptimizerSuggestionTile(
                    suggestion: s,
                    onCompleteChanged: (_) => taskCtrl.toggleTask(s.task.id),
                  )),
              const SizedBox(height: DzSpacing.xs),
              DayOptimizerBreakCard(recommendation: result.breakRecommendation),
            ],
          ),
        ),
      ],
    );
  }
}
