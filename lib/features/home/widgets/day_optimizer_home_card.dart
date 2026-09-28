import 'package:flutter/material.dart';
import '../../../core/ai/day_optimizer.dart';
import '../../../core/design_system/design_system.dart';
import '../../task_controller.dart';
import '../day_optimizer_sheet.dart';
import 'day_optimizer_summary_card.dart';

/// Home-page preview of the offline Day Optimizer: a tap-through summary
/// card that opens the full [showDayOptimizerSheet] breakdown. Computed
/// directly from [DayOptimizer.optimise] — pure and synchronous, no
/// network, no loading state, so it always has something to show.
class DayOptimizerHomeCard extends StatelessWidget {
  const DayOptimizerHomeCard({super.key, required this.taskCtrl});

  final TaskController taskCtrl;

  @override
  Widget build(BuildContext context) {
    final result = DayOptimizer.optimise(taskCtrl.forDate(DateTime.now()));

    return InkWell(
      onTap: () => showDayOptimizerSheet(context, taskCtrl),
      borderRadius: BorderRadius.circular(DzRadius.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: DzSpacing.sm),
              Text(
                'Optimize My Day',
                style: DzTextStyles.heading3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: DzSpacing.sm),
              Text(
                'Offline',
                style: DzTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          DayOptimizerSummaryCard(result: result),
        ],
      ),
    );
  }
}
