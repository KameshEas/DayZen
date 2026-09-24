import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/planner_dates.dart';
import '../../../core/utils/date_formatter.dart';

/// The Planner's title ("Tomorrow, SEP 21") and, beneath it, the month with the
/// controls for moving around: open the calendar, jump back to today, step a week.
class PlannerDateHeader extends StatelessWidget {
  const PlannerDateHeader({
    super.key,
    required this.selected,
    required this.today,
    required this.range,
    required this.onPickDate,
    required this.onToday,
    required this.onShiftWeek,
  });

  final DateTime selected;
  final DateTime today;
  final PlannerRange range;
  final VoidCallback onPickDate;
  final VoidCallback onToday;

  /// -1 for the previous week, +1 for the next.
  final ValueChanged<int> onShiftWeek;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = isSameDay(selected, today);
    final week = range.weekIndexOf(selected);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DzSpacing.md,
        DzSpacing.md,
        DzSpacing.md,
        DzSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ─────────────────────────────────────────────
          Text.rich(
            TextSpan(
              text: '${DateFormatter.relativeDayLabel(selected, today)}, ',
              style: DzTextStyles.heading1,
              children: [
                TextSpan(
                  text:
                      '${DateFormatter.monthAbbr(selected.month)} ${selected.day}',
                  style: DzTextStyles.heading1.copyWith(
                    color: DzColors.zenGreen,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: DzSpacing.xs),

          // ── Month + navigation ────────────────────────────────
          LayoutBuilder(
            builder: (context, box) {
              // Below this the month is abbreviated and "Today" shows as an icon,
              // so the month label is never squeezed into "Septem...".
              final compact = box.maxWidth < 360;
              final month = compact
                  ? DateFormatter.monthAbbr(selected.month).substring(0, 1) +
                        DateFormatter.monthAbbr(
                          selected.month,
                        ).substring(1).toLowerCase()
                  : DateFormatter.monthFull(selected.month);
              return Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label:
                            'Open calendar, ${DateFormatter.monthFull(selected.month)} ${selected.year}',
                        child: ExcludeSemantics(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(DzRadius.small),
                            onTap: onPickDate,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DzSpacing.xs,
                                vertical: DzSpacing.sm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '$month ${selected.year}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: DzTextStyles.body.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.expand_more_rounded,
                                    size: 20,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isToday) _TodayChip(onTap: onToday, compact: compact),
                  IconButton(
                    tooltip: 'Previous week',
                    onPressed: week > 0 ? () => onShiftWeek(-1) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  IconButton(
                    tooltip: 'Next week',
                    onPressed: week < range.weekCount - 1
                        ? () => onShiftWeek(1)
                        : null,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.onTap, required this.compact});
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: DzSpacing.xs),
      child: Semantics(
        button: true,
        label: 'Jump to today',
        child: ExcludeSemantics(
          child: Material(
            color: scheme.primaryContainer,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.today_rounded,
                      size: 16,
                      color: scheme.onPrimaryContainer,
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 6),
                      Text(
                        'Today',
                        style: DzTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
