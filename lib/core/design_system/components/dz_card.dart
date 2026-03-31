import 'package:flutter/material.dart';
import '../tokens/dz_colors.dart';
import '../tokens/dz_dimensions.dart';
import '../tokens/dz_shadows.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DzCard
// ─────────────────────────────────────────────────────────────────────────────

/// A standard DayZen card with soft shadow and 16px radius.
///
/// ```dart
/// DzCard(child: Text('Hello'))
/// ```
class DzCard extends StatelessWidget {
  const DzCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevated = false,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;

  /// Use [elevated] for modals / bottom sheets with stronger shadow.
  final bool elevated;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).colorScheme.surface;
    final radius = borderRadius ?? BorderRadius.circular(DzRadius.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: radius,
        boxShadow: elevated ? DzShadows.elevated : DzShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(DzSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzSectionCard
// ─────────────────────────────────────────────────────────────────────────────

/// A card with an optional header title and subtitle.
class DzSectionCard extends StatelessWidget {
  const DzSectionCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DzCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DzSpacing.md,
                DzSpacing.md,
                DzSpacing.md,
                DzSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title!, style: theme.textTheme.titleMedium),
                        if (subtitle case final s?) ...[
                          const SizedBox(height: 2),
                          Text(s, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          Padding(
            padding: padding ?? const EdgeInsets.all(DzSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DzTaskBlock
// ─────────────────────────────────────────────────────────────────────────────

/// A color-coded task block for the Planner page.
class DzTaskBlock extends StatelessWidget {
  const DzTaskBlock({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.onTap,
    this.onCompleteToggle,
  });

  final String title;
  final String? subtitle;
  final String? time;
  final TaskPriority priority;
  final bool isCompleted;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(priority);

    return DzCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Priority indicator bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DzRadius.card),
                  bottomLeft: Radius.circular(DzRadius.card),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DzSpacing.md,
                  vertical: DzSpacing.sm + DzSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (time != null)
                            Text(
                              time!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: priorityColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                          if (subtitle != null)
                            Text(subtitle!, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: onCompleteToggle != null
                          ? (v) => onCompleteToggle!(v ?? false)
                          : null,
                      activeColor: DzColors.zenGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return DzColors.error;
      case TaskPriority.medium:
        return DzColors.warning;
      case TaskPriority.low:
        return DzColors.zenGreen;
    }
  }
}

enum TaskPriority { high, medium, low }
