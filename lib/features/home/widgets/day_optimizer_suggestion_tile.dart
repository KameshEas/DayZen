import 'package:flutter/material.dart';
import '../../../core/ai/day_optimizer.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../models/task_model.dart';

class DayOptimizerSuggestionTile extends StatefulWidget {
  const DayOptimizerSuggestionTile({
    super.key,
    required this.suggestion,
    this.onCompleteChanged,
  });
  final AiSuggestion suggestion;
  final ValueChanged<bool>? onCompleteChanged;

  @override
  State<DayOptimizerSuggestionTile> createState() =>
      _DayOptimizerSuggestionTileState();
}

class _DayOptimizerSuggestionTileState extends State<DayOptimizerSuggestionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeInQuad),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  void _onTap() {
    final newCompleted = !widget.suggestion.task.isCompleted;
    if (newCompleted) {
      _popController.forward();
    }
    widget.onCompleteChanged?.call(newCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.suggestion.task;

    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.sm),
      child: FadeTransition(
        opacity: _opacity,
        child: ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTap: _onTap,
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
                              const Icon(Icons.check_circle_rounded,
                                  size: 16, color: DzColors.zenGreen),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.suggestion.suggestedSlot,
                          style: DzTextStyles.caption.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.suggestion.reason,
                          style: DzTextStyles.caption
                              .copyWith(color: DzColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
