import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import 'schedule_suggestions_widget.dart';
import 'widgets/planner_timeline_view.dart';

/// PlannerPage — composes PlannerTimelineView under features/planner/widgets/.
/// Split from a single 344-line file in Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  bool _showAiSuggestions = false;

  // Drives the timeline's "now" indicator line. The page otherwise only
  // rebuilds when TaskController notifies (task added/edited/completed), so
  // without this the current-time line stayed frozen at whatever time the
  // page happened to last rebuild at, instead of tracking real time.
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = _buildWeek(_selectedDate);
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  List<DateTime> _buildWeek(DateTime anchor) {
    // Show Mon–Sun (full week) so weekend tasks are also visible
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _shiftWeek(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _weekDays = _buildWeek(_selectedDate);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TaskScope.of(context),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {

    return Column(
      children: [
        // ── Date header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              DzSpacing.md, DzSpacing.md, DzSpacing.md, DzSpacing.sm),
          child: Row(
            children: [
              Text(
                _isSameDay(_selectedDate, _now)
                    ? 'Today,'
                    : '${DateFormatter.weekdayFull(_selectedDate)},',
                style: DzTextStyles.heading1,
              ),
              const SizedBox(width: DzSpacing.sm),
              Text(
                '${DateFormatter.monthAbbr(_selectedDate.month)} ${_selectedDate.day}',
                style: DzTextStyles.heading1.copyWith(color: DzColors.zenGreen),
              ),
            ],
          ),
        ),

        // ── Week strip ───────────────────────────────────────────
        SizedBox(
          height: 80,
          child: Row(
            children: [
              IconButton(
                onPressed: () => _shiftWeek(-7),
                icon: const Icon(Icons.chevron_left_rounded),
                color: DzColors.textSecondary,
                tooltip: 'Previous week',
              ),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _weekDays.length,
                  separatorBuilder: (context, i) =>
                      const SizedBox(width: DzSpacing.sm),
                  itemBuilder: (context, i) {
                    final day = _weekDays[i];
                    final isSelected = _isSameDay(day, _selectedDate);
                    final hasTasks =
                        TaskScope.of(context).forDate(day).isNotEmpty;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDate = day),
                      child: AnimatedContainer(
                        duration: DzDuration.fast,
                        width: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : DzColors.cardBackground,
                          borderRadius: BorderRadius.circular(DzRadius.card),
                          boxShadow: isSelected ? DzShadows.soft : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormatter.weekdayAbbr(day),
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
                            const SizedBox(height: 4),
                            // Filled dot = has tasks; hollow ring = no tasks
                            // for this day, so an empty day is visible right
                            // in the date strip rather than only after
                            // navigating to it.
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasTasks
                                    ? (isSelected
                                        ? DzColors.white
                                        : Theme.of(context).colorScheme.primary)
                                    : Colors.transparent,
                                border: hasTasks
                                    ? null
                                    : Border.all(
                                        color: isSelected
                                            ? DzColors.white.withValues(alpha: 0.5)
                                            : DzColors.textSecondary.withValues(alpha: 0.35),
                                        width: 1,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () => _shiftWeek(7),
                icon: const Icon(Icons.chevron_right_rounded),
                color: DzColors.textSecondary,
                tooltip: 'Next week',
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        // ── AI schedule suggestions (opt-in) ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DzGhostButton(
              label: _showAiSuggestions ? AppConfig.plannerHideAiSuggestions : AppConfig.plannerShowAiSuggestions,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              onPressed: () => setState(() => _showAiSuggestions = !_showAiSuggestions),
            ),
          ),
        ),
        if (_showAiSuggestions) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
            child: ScheduleSuggestionsWidget(
              tasks: TaskScope.of(context).forDate(_selectedDate),
            ),
          ),
          const SizedBox(height: DzSpacing.md),
        ],

        // ── Timeline ─────────────────────────────────────────────
        Expanded(
          child: _buildTimeline(context),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context) {
    final tasks = TaskScope.of(context).forDate(_selectedDate);
    final events = tasks.map(PlannerEvent.fromTask).toList();

    if (events.isEmpty) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xl),
          child: DzEmptyState(
            icon: Icons.schedule_outlined,
            title: AppConfig.plannerEmptyTitle,
            subtitle: AppConfig.plannerEmptyBody,
            actionLabel: AppConfig.plannerEmptyAction,
            onAction: () => context.push(RoutePaths.newTask),
          ),
        ),
      );
    }

    return PlannerTimelineView(
      events: events,
      currentHour: _now.hour,
      currentMinute: _now.minute,
      isToday: _isSameDay(_selectedDate, _now),
    );
  }
}
