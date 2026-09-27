import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/models/task_model.dart';

/// Flat, time-sorted list of a day's tasks — the "list" alternative to
/// [PlannerTimelineView] for reading what's due without the timeline's
/// spatial hour-grid layout. Shares the same [PlannerEvent] data and the
/// same tap-to-open / tap-to-toggle callbacks as the timeline, so switching
/// views doesn't change what tapping a task does.
class PlannerListView extends StatelessWidget {
  const PlannerListView({
    super.key,
    required this.events,
    this.onEventTap,
    this.onToggleComplete,
  });

  final List<PlannerEvent> events;
  final ValueChanged<String>? onEventTap;
  final ValueChanged<String>? onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final sorted = [...events]
      ..sort((a, b) {
        final byTime = (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
        return byTime != 0 ? byTime : a.title.compareTo(b.title);
      });

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md, vertical: DzSpacing.sm),
      itemCount: sorted.length,
      separatorBuilder: (context, i) => const SizedBox(height: DzSpacing.sm),
      itemBuilder: (context, i) {
        final event = sorted[i];
        return _ListRow(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(event.id),
          onToggleComplete: onToggleComplete == null ? null : () => onToggleComplete!(event.id),
        );
      },
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.event, this.onTap, this.onToggleComplete});

  final PlannerEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DzCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: event.accentColor,
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: event.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(event.icon, size: 16, color: event.accentColor),
                    ),
                    const SizedBox(width: DzSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            event.title,
                            style: DzTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (event.subtitle.isNotEmpty)
                            Text(
                              event.subtitle,
                              style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: DzSpacing.sm),
                    // Explicit container: independently activatable, not
                    // merged into the card's own tap target (see
                    // PlannerTimelineView's _EventBlock for the same fix).
                    Semantics(
                      container: true,
                      label: event.isCompleted ? 'Mark as not done' : 'Mark as done',
                      button: true,
                      enabled: onToggleComplete != null,
                      child: InkWell(
                        onTap: onToggleComplete,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            event.isCompleted ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: event.isCompleted ? DzColors.zenGreen : scheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
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
}
