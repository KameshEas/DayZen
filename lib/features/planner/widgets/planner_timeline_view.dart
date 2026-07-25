import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart';
import '../../home/models/task_model.dart';

/// Absolutely-positioned day timeline — a Stack of hour lines + event
/// blocks inside a scroll view. Not a candidate for ListView.builder: a
/// timeline needs every item positioned by time-of-day simultaneously (see
/// docs/DEVELOPMENT_PLAN.md Phase 4.1's audit note on this exact file).
class PlannerTimelineView extends StatelessWidget {
  const PlannerTimelineView({
    super.key,
    required this.events,
    required this.currentHour,
    required this.currentMinute,
  });

  final List<PlannerEvent> events;
  final int currentHour;
  final int currentMinute;

  static double get _hourHeight => AppConfig.timelineHourHeight;
  static int get _startHour => AppConfig.timelineStartHour;
  static int get _endHour => AppConfig.timelineEndHour;
  static double get _timeColWidth => AppConfig.timelineColWidth;

  @override
  Widget build(BuildContext context) {
    final totalHours = _endHour - _startHour;
    final totalHeight = totalHours * _hourHeight;

    // Current time position
    final currentOffsetHours =
        (currentHour - _startHour) + currentMinute / 60.0;
    final currentY = currentOffsetHours * _hourHeight;
    final showCurrentTime =
        currentHour >= _startHour && currentHour < _endHour;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: SizedBox(
        height: totalHeight + DzSpacing.xl,
        child: Stack(
          children: [
            // ── Hour lines + labels ────────────────────────────
            ...List.generate(totalHours + 1, (i) {
              final hour = _startHour + i;
              final y = i * _hourHeight;
              return Positioned(
                top: y,
                left: 0,
                right: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _timeColWidth,
                      child: Text(
                        '${hour.toString().padLeft(2, '0')}:00',
                        style: DzTextStyles.small.copyWith(
                          color: DzColors.textSecondary,
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
            ...events.map((e) {
              // Clamp events that start before the visible window
              final clampedHour = e.hour.clamp(_startHour, _endHour - 1);
              final clampedMinute = e.hour < _startHour ? 0 : e.minute;
              final top =
                  (clampedHour - _startHour + clampedMinute / 60.0) * _hourHeight;
              final height =
                  (e.durationMinutes / 60.0) * _hourHeight;

              return Positioned(
                top: top,
                left: _timeColWidth,
                right: 0,
                child: _EventBlock(event: e, height: height),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$currentHour:${currentMinute.toString().padLeft(2, '0')}',
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
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({required this.event, required this.height});
  final PlannerEvent event;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.clamp(AppConfig.timelineMinEventHeight.toDouble(), AppConfig.timelineMaxEventHeight.toDouble()),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: DzColors.cardBackground,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (event.subtitle.isNotEmpty)
                  Text(
                    event.subtitle,
                    style: DzTextStyles.small.copyWith(
                      color: DzColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (event.isCompleted)
            const Padding(
              padding: EdgeInsets.only(right: DzSpacing.sm),
              child: Icon(Icons.check_circle_rounded,
                  color: DzColors.zenGreen, size: 18),
            ),
          const SizedBox(width: DzSpacing.sm),
        ],
      ),
    );
  }
}
