import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/models/task_model.dart';
import '../timeline_layout.dart';

/// Absolutely-positioned day timeline — a Stack of hour lines + event
/// blocks inside a scroll view. Not a candidate for ListView.builder: a
/// timeline needs every item positioned by time-of-day simultaneously (see
/// docs/DEVELOPMENT_PLAN.md Phase 4.1's audit note on this exact file).
///
/// Events that overlap sit side by side, and identical events show as one card
/// with a count (see [layoutTimeline]).
class PlannerTimelineView extends StatefulWidget {
  const PlannerTimelineView({
    super.key,
    required this.events,
    required this.currentHour,
    required this.currentMinute,
    this.showNow = true,
  });

  final List<PlannerEvent> events;
  final int currentHour;
  final int currentMinute;

  /// False for any day but today: there is no "now" on another date.
  final bool showNow;

  @override
  State<PlannerTimelineView> createState() => _PlannerTimelineViewState();
}

class _PlannerTimelineViewState extends State<PlannerTimelineView> {
  static double get _hourHeight => AppConfig.timelineHourHeight;
  static int get _startHour => AppConfig.timelineStartHour;
  static int get _endHour => AppConfig.timelineEndHour;
  static double get _timeColWidth => AppConfig.timelineColWidth;

  /// Gap between cards that sit side by side.
  static const double _columnGap = 6;

  /// The shortest a card is drawn, in minutes (its minimum height / the hour height).
  static int get _minEventMinutes =>
      (AppConfig.timelineMinEventHeight / _hourHeight * 60).ceil();

  List<PlannerEvent> get events => widget.events;
  int get currentHour => widget.currentHour;
  int get currentMinute => widget.currentMinute;
  bool get showNow => widget.showNow;

  // Opens half an hour above the first task, so a day that starts at 6 PM
  // doesn't begin with screens of empty rows and make you scroll to find it.
  // (Give the view a new key to re-apply this when the day changes.)
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: _initialOffset(),
  );

  double _initialOffset() {
    if (events.isEmpty) return 0;
    final first = events
        .map((e) => e.hour + e.minute / 60.0)
        .reduce((a, b) => a < b ? a : b);
    return ((first - _startHour - 0.5) * _hourHeight).clamp(0.0, double.infinity);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalHours = _endHour - _startHour;
    final totalHeight = totalHours * _hourHeight;
    final slots = layoutTimeline(events, minEventMinutes: _minEventMinutes);

    // Current time position
    final currentOffsetHours =
        (currentHour - _startHour) + currentMinute / 60.0;
    final currentY = currentOffsetHours * _hourHeight;
    final showCurrentTime =
        showNow && currentHour >= _startHour && currentHour < _endHour;

    return SingleChildScrollView(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: LayoutBuilder(
        builder: (context, box) {
          final eventsWidth = box.maxWidth - _timeColWidth;
          return SizedBox(
            height: totalHeight + DzSpacing.xl,
            child: Stack(
              children: [
                // ── Hour lines + labels ────────────────────────────
                ...List.generate(totalHours + 1, (i) {
                  final hour = _startHour + i;
                  final y = i * _hourHeight;
                  // The "now" pill sits on the label of the hour it is nearest, so
                  // that label steps aside instead of being printed underneath it.
                  final underNowPill = showCurrentTime && (currentY - y).abs() < 14;
                  return Positioned(
                    top: y,
                    left: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: _timeColWidth,
                          child: underNowPill
                              ? null
                              : Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: DzTextStyles.small.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            margin: const EdgeInsets.only(top: 6),
                            color: DzColors.borderLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // ── Events ────────────────────────────────────────
                ...slots.map((slot) {
                  final e = slot.event;
                  // Clamp events that start before the visible window
                  final clampedHour = e.hour.clamp(_startHour, _endHour - 1);
                  final clampedMinute = e.hour < _startHour ? 0 : e.minute;
                  final top =
                      (clampedHour - _startHour + clampedMinute / 60.0) * _hourHeight;
                  final height = (e.durationMinutes / 60.0) * _hourHeight;

                  final columnWidth = eventsWidth / slot.columns;
                  final width = slot.columns == 1 ? columnWidth : columnWidth - _columnGap;
                  return Positioned(
                    top: top,
                    left: _timeColWidth + slot.column * columnWidth,
                    width: width,
                    child: _EventBlock(
                      event: e,
                      height: height,
                      width: width,
                      count: slot.count,
                    ),
                  );
                }),

                // ── Current time indicator ─────────────────────────
                if (showCurrentTime)
                  Positioned(
                    top: currentY - 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: [
                        Container(
                          width: _timeColWidth - 4,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${currentHour.toString().padLeft(2, '0')}:'
                            '${currentMinute.toString().padLeft(2, '0')}',
                            style: DzTextStyles.small.copyWith(
                              color: DzColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.event,
    required this.height,
    required this.width,
    required this.count,
  });

  final PlannerEvent event;
  final double height;
  final double width;

  /// More than one when identical events were merged into this card.
  final int count;

  // Below these widths (cards sharing the row) the card sheds detail so the
  // title always stays readable.
  static const double _hideIconBelow = 210;
  static const double _hideSubtitleBelow = 130;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showIcon = width >= _hideIconBelow;
    final showSubtitle = event.subtitle.isNotEmpty && width >= _hideSubtitleBelow;

    return Container(
      height: height.clamp(AppConfig.timelineMinEventHeight.toDouble(), AppConfig.timelineMaxEventHeight.toDouble()),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(DzRadius.card),
        boxShadow: DzShadows.soft,
      ),
      child: Row(
        children: [
          // Accent bar
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
          const SizedBox(width: DzSpacing.sm),
          // Icon
          if (showIcon) ...[
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
          ],
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: DzTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: showSubtitle ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showSubtitle)
                  Text(
                    event.subtitle,
                    style: DzTextStyles.small.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (count > 1)
            Padding(
              padding: const EdgeInsets.only(left: DzSpacing.xs),
              child: _CountBadge(count: count),
            ),
          if (event.isCompleted)
            const Padding(
              padding: EdgeInsets.only(left: DzSpacing.xs),
              child: Icon(Icons.check_circle_rounded,
                  color: DzColors.zenGreen, size: 18),
            ),
          const SizedBox(width: DzSpacing.sm),
        ],
      ),
    );
  }
}

/// "×3" on a card standing for three identical events.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: '$count identical tasks',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '×$count',
            style: DzTextStyles.small.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
