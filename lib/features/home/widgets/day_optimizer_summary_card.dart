import 'package:flutter/material.dart';
import '../../../core/ai/day_optimizer.dart';
import '../../../core/design_system/design_system.dart';

class DayOptimizerSummaryCard extends StatelessWidget {
  const DayOptimizerSummaryCard({super.key, required this.result});
  final DayOptimizationResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hours = result.focusTimeMinutes ~/ 60;
    final mins = result.focusTimeMinutes % 60;
    final durationText = hours > 0
        ? '$hours h${mins > 0 ? ' $mins min' : ''}'
        : '${result.focusTimeMinutes} min';

    return Container(
      padding: const EdgeInsets.all(DzSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.summary,
            style:
                DzTextStyles.body.copyWith(color: Colors.white, height: 1.5),
          ),
          if (result.focusTimeMinutes > 0) ...[
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                _Pill(
                  icon: Icons.timer_outlined,
                  label: 'Focus: $durationText',
                ),
                const SizedBox(width: DzSpacing.sm),
                _Pill(
                  icon: Icons.checklist_rounded,
                  label: '${result.suggestions.where((s) => !s.task.isCompleted).length} remaining',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style:
                  DzTextStyles.caption.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
