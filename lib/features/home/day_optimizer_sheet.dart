import 'package:flutter/material.dart';
import '../../core/ai/day_optimizer.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../home/models/task_model.dart';
import '../task_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the Optimize My Day bottom sheet for [taskCtrl]'s today tasks.
void showDayOptimizerSheet(BuildContext context, TaskController taskCtrl) {
  final tasks = taskCtrl.forDate(DateTime.now());
  final result = DayOptimizer.optimise(tasks);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OptimizerSheet(result: result),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _OptimizerSheet extends StatelessWidget {
  const _OptimizerSheet({required this.result});
  final DayOptimizationResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(DzRadius.card),
          ),
        ),
        child: Column(
          children: [
            // ── Handle ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DzSpacing.sm),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DzColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // ── Header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, DzSpacing.sm, DzSpacing.lg, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: DzSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Optimize My Day',
                            style: DzTextStyles.heading3
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text(
                          'Offline AI — on-device only',
                          style: DzTextStyles.caption
                              .copyWith(color: DzColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            // ── Content ───────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.symmetric(
                    horizontal: DzSpacing.lg, vertical: 0),
                children: [
                  // Summary card
                  _SummaryCard(result: result),
                  const SizedBox(height: DzSpacing.md),
                  if (result.suggestions.isEmpty) ...[
                    const SizedBox(height: DzSpacing.xl),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.sentiment_satisfied_alt_rounded,
                              size: 64, color: DzColors.zenGreen),
                          const SizedBox(height: DzSpacing.md),
                          Text(
                            'No tasks to optimize today!',
                            style: DzTextStyles.heading3.copyWith(
                                color: DzColors.zenGreen,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: DzSpacing.sm),
                          Text(
                            'Add a new task to see AI suggestions.',
                            style: DzTextStyles.body.copyWith(
                                color: DzColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: DzSpacing.xl),
                  ]
                  else ...[
                    Text('Suggested Schedule',
                        style: DzTextStyles.heading3
                            .copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: DzSpacing.sm),
                    ...result.suggestions
                        .map((s) => _SuggestionTile(suggestion: s)),
                    const SizedBox(height: DzSpacing.md),
                  ],
                  // Break recommendation
                  _BreakCard(recommendation: result.breakRecommendation),
                  const SizedBox(height: DzSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});
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

// ─────────────────────────────────────────────────────────────────────────────
// Suggestion tile
// ─────────────────────────────────────────────────────────────────────────────

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion});
  final AiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final task = suggestion.task;
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.sm),
      child: DzCard(
        padding: const EdgeInsets.all(DzSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority dot
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: task.priority.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: DzSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: DzTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? DzColors.textSecondary
                                : null,
                          ),
                        ),
                      ),
                      if (task.isCompleted)
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: DzColors.zenGreen),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.suggestedSlot,
                    style: DzTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.reason,
                    style: DzTextStyles.caption
                        .copyWith(color: DzColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Break recommendation card
// ─────────────────────────────────────────────────────────────────────────────

class _BreakCard extends StatelessWidget {
  const _BreakCard({required this.recommendation});
  final String recommendation;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      padding: const EdgeInsets.all(DzSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DzColors.zenGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.self_improvement_rounded,
                color: DzColors.zenGreen, size: 20),
          ),
          const SizedBox(width: DzSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Break Strategy',
                    style: DzTextStyles.label
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(recommendation,
                    style: DzTextStyles.body
                        .copyWith(color: DzColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
