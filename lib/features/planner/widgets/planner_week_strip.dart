import 'package:flutter/material.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/domain/planner_dates.dart';
import '../../../core/utils/date_formatter.dart';

/// How many tasks a day has, and how many are done. Drives the dot under a date.
typedef DaySummary = ({int total, int done});

/// One week per page, all seven days visible at once (Monday to Sunday). Swipe to
/// move a week; today is always ringed, the selected day is filled, and a dot
/// marks days that have tasks.
class PlannerWeekStrip extends StatefulWidget {
  const PlannerWeekStrip({
    super.key,
    required this.range,
    required this.selected,
    required this.today,
    required this.summaries,
    required this.onSelect,
  });

  final PlannerRange range;
  final DateTime selected;
  final DateTime today;
  final Map<DateTime, DaySummary> summaries;
  final ValueChanged<DateTime> onSelect;

  static const double height = 84;

  @override
  State<PlannerWeekStrip> createState() => _PlannerWeekStripState();
}

class _PlannerWeekStripState extends State<PlannerWeekStrip> {
  late final PageController _controller =
      PageController(initialPage: widget.range.weekIndexOf(widget.selected));

  // True while the strip moves itself (a tap on "Today", the date picker...).
  // Otherwise the pages it slides past would each look like a swipe and
  // change the selection on the way.
  bool _moving = false;

  @override
  void didUpdateWidget(PlannerWeekStrip old) {
    super.didUpdateWidget(old);
    final target = widget.range.weekIndexOf(widget.selected);
    final shown = _controller.hasClients ? (_controller.page ?? target).round() : target;
    if (target != shown) _goTo(target, shown);
  }

  Future<void> _goTo(int target, int from) async {
    _moving = true;
    try {
      if ((target - from).abs() > 1) {
        _controller.jumpToPage(target);
      } else {
        await _controller.animateToPage(
          target,
          duration: DzDuration.normal,
          curve: Curves.easeOut,
        );
      }
    } finally {
      _moving = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_moving) return;
    if (widget.range.weekIndexOf(widget.selected) == index) return;
    widget.onSelect(widget.range.sameWeekdayIn(index, widget.selected));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PlannerWeekStrip.height,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.range.weekCount,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, week) {
          final monday = widget.range.weekStart(week);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
            child: Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _buildDay(context, addDays(monday, i))),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDay(BuildContext context, DateTime day) {
    final scheme = Theme.of(context).colorScheme;
    final inRange = widget.range.contains(day);
    final isSelected = isSameDay(day, widget.selected);
    final isToday = isSameDay(day, widget.today);
    final summary = widget.summaries[day];
    final allDone = summary != null && summary.total > 0 && summary.done == summary.total;

    final Color fg = isSelected ? scheme.onPrimary : scheme.onSurface;
    final Color subFg =
        isSelected ? scheme.onPrimary.withValues(alpha: 0.8) : scheme.onSurfaceVariant;
    final Color dot = isSelected
        ? scheme.onPrimary
        : (allDone ? DzColors.zenGreen : scheme.primary);

    final label = StringBuffer(DateFormatter.formatDateFull(day));
    if (summary != null && summary.total > 0) {
      label.write(', ${summary.total} ${summary.total == 1 ? 'task' : 'tasks'}');
    }
    if (isToday) label.write(', today');

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: inRange,
      label: label.toString(),
      child: ExcludeSemantics(
        child: Opacity(
          opacity: inRange ? 1 : 0.35,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: inRange ? () => widget.onSelect(day) : null,
            child: AnimatedContainer(
              duration: DzDuration.fast,
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : scheme.surface,
                borderRadius: BorderRadius.circular(DzRadius.card),
                border: isToday && !isSelected
                    ? Border.all(color: scheme.primary, width: 1.5)
                    : null,
                boxShadow: isSelected ? DzShadows.soft : const [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormatter.weekdayAbbr(day),
                    style: DzTextStyles.small.copyWith(
                      color: subFg,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: DzTextStyles.heading3.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Reserved even when empty, so cells don't change height.
                  SizedBox(
                    height: 5,
                    child: summary != null && summary.total > 0
                        ? DecoratedBox(
                            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                            child: const SizedBox(width: 5, height: 5),
                          )
                        : null,
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
