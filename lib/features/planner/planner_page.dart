import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = _buildWeek(_selectedDate);
  }

  List<DateTime> _buildWeek(DateTime anchor) {
    // Show Mon–Sun (full week) so weekend tasks are also visible
    final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

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
              const Text(
                'Today,',
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
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
            itemCount: _weekDays.length,
            separatorBuilder: (context, i) =>
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
            title: 'No tasks scheduled',
            subtitle: 'Your day is clear. Create a task to get started.',
            actionLabel: 'Add a task',
            onAction: () => context.push(RoutePaths.newTask),
          ),
        ),
      );
    }

    return PlannerTimelineView(
      events: events,
      currentHour: DateTime.now().hour,
      currentMinute: DateTime.now().minute,
    );
  }
}
