import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/config/copy/close_day_copy.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../home/models/task_model.dart';

/// One open task in Close the Day. Swipe right = tomorrow, swipe left = let
/// go, tap = done. The same three choices are buttons too, and screen-reader
/// actions, so nothing depends on swiping.
class SwipeTaskCard extends StatelessWidget {
  const SwipeTaskCard({
    super.key,
    required this.task,
    required this.onDone,
    required this.onCarry,
    required this.onLetGo,
  });

  final DzTask task;
  final VoidCallback onDone;
  final VoidCallback onCarry;
  final VoidCallback onLetGo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '${task.title}, ${task.timeRange}'
          '${task.rolloverCount > 0 ? ', carried ${task.rolloverCount} times' : ''}',
      customSemanticsActions: {
        const CustomSemanticsAction(label: CloseDayCopy.done): onDone,
        const CustomSemanticsAction(label: CloseDayCopy.carry): onCarry,
        const CustomSemanticsAction(label: CloseDayCopy.letGo): onLetGo,
      },
      child: Dismissible(
        key: ValueKey('close-${task.id}'),
        background: _SwipeBackground(
          alignment: Alignment.centerLeft,
          color: scheme.primary.withValues(alpha: 0.14),
          fg: scheme.primary,
          icon: Icons.east_rounded,
          label: CloseDayCopy.carry,
        ),
        secondaryBackground: _SwipeBackground(
          alignment: Alignment.centerRight,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.12),
          fg: scheme.onSurfaceVariant,
          icon: Icons.spa_outlined,
          label: CloseDayCopy.letGo,
        ),
        onDismissed: (dir) =>
            dir == DismissDirection.startToEnd ? onCarry() : onLetGo(),
        child: Material(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(DzRadius.card),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(DzRadius.card),
            onTap: onDone,
            child: Container(
              padding: const EdgeInsets.all(DzSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DzRadius.card),
                border: Border(left: BorderSide(color: task.priority.color, width: 4)),
                boxShadow: DzShadows.soft,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.title,
                            style: DzTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            )),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: DzSpacing.sm,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(task.timeRange,
                                style: DzTextStyles.caption
                                    .copyWith(color: scheme.onSurfaceVariant)),
                            if (task.rolloverCount > 0)
                              CarriedChip(count: task.rolloverCount),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: CloseDayCopy.done,
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        color: DzColors.zenGreen),
                    onPressed: onDone,
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

/// "Carried 2×": a quiet hint, never a warning colour (M-1.12).
class CarriedChip extends StatelessWidget {
  const CarriedChip({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        CloseDayCopy.carriedHint.replaceAll('{n}', '$count'),
        style: DzTextStyles.small.copyWith(
          color: scheme.onSurfaceVariant,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.fg,
    required this.icon,
    required this.label,
  });

  final Alignment alignment;
  final Color color;
  final Color fg;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final leading = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading) Icon(icon, color: fg),
          if (leading) const SizedBox(width: DzSpacing.sm),
          Text(label, style: DzTextStyles.body.copyWith(color: fg, fontWeight: FontWeight.w600)),
          if (!leading) const SizedBox(width: DzSpacing.sm),
          if (!leading) Icon(icon, color: fg),
        ],
      ),
    );
  }
}
