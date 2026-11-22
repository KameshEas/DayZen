import 'package:flutter/material.dart';
import '../../../core/ai/day_optimizer.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../models/task_model.dart';

/// A row in the "Optimize My Day" suggested schedule. Tapping toggles
/// completion in place — the tile stays visible either way (struck through
/// once done), it never disappears from the list.
class DayOptimizerSuggestionTile extends StatelessWidget {
  const DayOptimizerSuggestionTile({
    super.key,
    required this.suggestion,
    this.onCompleteChanged,
  });
  final AiSuggestion suggestion;
  final ValueChanged<bool>? onCompleteChanged;

  @override
  Widget build(BuildContext context) {
    final task = suggestion.task;

    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.sm),
      child: GestureDetector(
        onTap: () => onCompleteChanged?.call(!task.isCompleted),
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
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ),
                        if (task.isCompleted)
                          const Icon(Icons.check_circle_rounded,
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
                          .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
