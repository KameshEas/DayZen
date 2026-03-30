import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = _buildWeek(_selectedDate);
  }

  List<DateTime> _buildWeek(DateTime anchor) {
    // Show Mon–Fri centred around today
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(5, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppData.of(context).tasks,
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // ── Date header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DzSpacing.md, DzSpacing.md, DzSpacing.md, DzSpacing.sm),
          child: Row(
            children: [
              Text(
                'Today,',
                style: DzTextStyles.heading1,
              ),
              const SizedBox(width: DzSpacing.sm),
              Text(
                '${months[_selectedDate.month - 1]} ${_selectedDate.day}',
                style: DzTextStyles.heading1.copyWith(color: DzColors.zenGreen),
              ),
            ],
          ),
        ),

        // ── Week strip ───────────────────────────────────────────
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
            itemCount: _weekDays.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: DzSpacing.sm),
            itemBuilder: (context, i) {
              final day = _weekDays[i];
              final isSelected = day.day == _selectedDate.day &&
                  day.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: AnimatedContainer(
                  duration: DzDuration.fast,
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? DzColors.primary
                        : DzColors.cardBackground,
                    borderRadius: BorderRadius.circular(DzRadius.card),
                    boxShadow: isSelected ? DzShadows.soft : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNames[day.weekday - 1],
                        style: DzTextStyles.small.copyWith(
                          color: isSelected
                              ? DzColors.white.withValues(alpha: 0.8)
                              : DzColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: DzTextStyles.heading3.copyWith(
                          color: isSelected
                              ? DzColors.white
                              : DzColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        // ── Timeline ─────────────────────────────────────────────
        Expanded(
          child: _TimelineView(
            events: AppData.of(context)
                .tasks
                .forDate(_selectedDate)
                .map(PlannerEvent.fromTask)
                .toList(),
            currentHour: DateTime.now().hour,
            currentMinute: DateTime.now().minute,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline view
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineView extends StatelessWidget {
  const _TimelineView({
    required this.events,
    required this.currentHour,
    required this.currentMinute,
  });

  final List<PlannerEvent> events;
  final int currentHour;
  final int currentMinute;

  static const double _hourHeight = 72.0;
  static const int _startHour = 7;
  static const int _endHour = 18;
  static const double _timeColWidth = 52.0;

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
              final top =
                  (e.hour - _startHour + e.minute / 60.0) * _hourHeight;
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
                        color: DzColors.primary,
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
                        color: DzColors.primary,
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
      height: height.clamp(52.0, 200.0),
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
            Padding(
              padding: const EdgeInsets.only(right: DzSpacing.sm),
              child: Icon(Icons.check_circle_rounded,
                  color: DzColors.zenGreen, size: 18),
            ),
          const SizedBox(width: DzSpacing.sm),
        ],
      ),
    );
  }
}
