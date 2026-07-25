import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/ai/day_optimizer.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../task_controller.dart';
import 'widgets/day_optimizer_break_card.dart';
import 'widgets/day_optimizer_summary_card.dart';
import 'widgets/day_optimizer_suggestion_tile.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Shows the Optimize My Day bottom sheet for [taskCtrl]'s today tasks.
///
/// Card widgets split into features/home/widgets/ in Phase 5.1 of
/// docs/DEVELOPMENT_PLAN.md.
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
    return Stack(
      children: [
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
        DraggableScrollableSheet(
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
                  DayOptimizerSummaryCard(result: result),
                  const SizedBox(height: DzSpacing.md),
                  if (result.suggestions.isEmpty) ...[
                    const SizedBox(height: DzSpacing.xl),
                    Center(
                      child: Column(
                        children: [
                          const Icon(Icons.sentiment_satisfied_alt_rounded,
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
                        .map((s) => DayOptimizerSuggestionTile(suggestion: s)),
                    const SizedBox(height: DzSpacing.md),
                  ],
                  // Break recommendation
                  DayOptimizerBreakCard(recommendation: result.breakRecommendation),
                  const SizedBox(height: DzSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
    ],
    );
  }
}
