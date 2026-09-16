import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/ai_service.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';

/// Widget displaying AI schedule suggestions for tasks with breaks.
class ScheduleSuggestionsWidget extends StatefulWidget {
  final List<DzTask> tasks;
  final VoidCallback? onRefresh;

  const ScheduleSuggestionsWidget({
    super.key,
    required this.tasks,
    this.onRefresh,
  });

  @override
  State<ScheduleSuggestionsWidget> createState() => _ScheduleSuggestionsWidgetState();
}

class _ScheduleSuggestionsWidgetState extends State<ScheduleSuggestionsWidget> {
  bool _loading = false;
  bool _errored = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSuggestions());
  }

  Future<void> _loadSuggestions() async {
    if (!mounted || widget.tasks.isEmpty) return;

    final taskData = widget.tasks.map((t) {
      final duration = t.endTime.hour * 60 +
          t.endTime.minute -
          (t.startTime.hour * 60 + t.startTime.minute);
      return {
        'id': t.id,
        'title': t.title,
        'priority': t.priority.label.toLowerCase(),
        'estimated_duration_minutes': duration.abs(),
        'category': t.category.label.toLowerCase(),
      };
    }).toList();

    setState(() {
      _loading = true;
      _errored = false;
    });

    final controller = AIOptimizationScope.of(context);
    await controller.getScheduleSuggestions(
      tasks: taskData,
      startHour: AppConfig.timelineStartHour,
      endHour: AppConfig.timelineEndHour,
      peakHours: const [8, 9, 10],
    );

    if (!mounted) return;
    setState(() {
      _loading = false;
      _errored = controller.scheduleSuggestions == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return DzCard(
        child: Column(
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 48,
              color: DzColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: DzSpacing.md),
            const Text('No tasks scheduled', style: DzTextStyles.body),
            const SizedBox(height: DzSpacing.sm),
            const Text(
              'Add tasks to get schedule suggestions',
              style: DzTextStyles.small,
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return const DzCard(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: DzSpacing.md),
            Text('Generating optimal schedule...', style: DzTextStyles.body),
          ],
        ),
      );
    }

    final suggestions = AIOptimizationScope.of(context).scheduleSuggestions;

    if (_errored || suggestions == null) {
      return DzCard(
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: DzColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: DzSpacing.sm),
            const Text('Could not generate schedule', style: DzTextStyles.body),
            const SizedBox(height: DzSpacing.md),
            DzSecondaryButton(
              label: 'Retry',
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: _loadSuggestions,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suggested Schedule',
                    style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-optimized for ${suggestions.totalFocusMinutes} min focus',
                    style: DzTextStyles.caption,
                  ),
                ],
              ),
              DzIconButton(
                onPressed: _loadSuggestions,
                tooltip: 'Generate new schedule',
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: DzSpacing.md),

        // Timeline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: _buildTimeline(context, suggestions),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, ScheduleSuggestions suggestions) {
    // Combine scheduled tasks and breaks, then sort by time
    final allItems = <({String type, dynamic data})>[
      ...suggestions.scheduledTasks.map((t) => (type: 'task', data: t)),
      ...suggestions.recommendedBreaks.map((b) => (type: 'break', data: b)),
    ];

    // Sort by start time (simplified - assumes HH:MM format)
    allItems.sort((a, b) {
      final timeA = a.type == 'task' ? (a.data as ScheduledTask).suggestedStartTime : (a.data as BreakRecommendation).startTime;
      final timeB = b.type == 'task' ? (b.data as ScheduledTask).suggestedStartTime : (b.data as BreakRecommendation).startTime;
      return timeA.compareTo(timeB);
    });

    return Column(
      children: List.generate(allItems.length, (index) {
        final item = allItems[index];
        final isLast = index == allItems.length - 1;

        return Column(
          children: [
            if (item.type == 'task')
              _buildTaskTimelineItem(context, item.data as ScheduledTask)
            else
              _buildBreakTimelineItem(context, item.data as BreakRecommendation),
            if (!isLast)
              Container(
                margin: const EdgeInsets.symmetric(vertical: DzSpacing.sm),
                width: 2,
                height: 20,
                color: DzColors.mutedBorder.withValues(alpha: 0.3),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTaskTimelineItem(BuildContext context, ScheduledTask task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: DzColors.primary,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: DzSpacing.md),

        // Content
        Expanded(
          child: DzCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${task.suggestedStartTime} - ${task.suggestedEndTime}',
                      style: DzTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: DzColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DzRadius.small),
                      ),
                      child: Text(
                        '${(task.confidence * 100).toStringAsFixed(0)}%',
                        style: DzTextStyles.small.copyWith(color: DzColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DzSpacing.sm),
                Text(
                  task.taskId,
                  style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  task.reason,
                  style: DzTextStyles.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakTimelineItem(BuildContext context, BreakRecommendation breakRec) {
    final icon = switch (breakRec.type) {
      'stretch' => Icons.self_improvement_rounded,
      'walk' => Icons.directions_walk_rounded,
      'meditate' => Icons.spa_rounded,
      _ => Icons.coffee_rounded,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Break dot
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: DzColors.warning,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        const SizedBox(width: DzSpacing.md),

        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DzSpacing.md),
            decoration: BoxDecoration(
              color: DzColors.warningTint.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(DzRadius.small),
              border: Border.all(color: DzColors.warning.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: DzColors.warning),
                const SizedBox(width: DzSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${breakRec.startTime} - ${breakRec.type}',
                        style: DzTextStyles.small.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${breakRec.durationMinutes} min',
                        style: DzTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
