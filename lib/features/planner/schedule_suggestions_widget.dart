import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/ai_service.dart';
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
  late Future<ScheduleSuggestions> _suggestionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    if (widget.tasks.isEmpty) return;

    // Convert tasks to API format
    final taskData = widget.tasks
        .map((t) {
              final duration = t.endTime.hour * 60 + t.endTime.minute - (t.startTime.hour * 60 + t.startTime.minute);
              return {
                'id': t.id,
                'title': t.title,
                'priority': t.priority.label.toLowerCase(),
                'estimated_duration_minutes': duration.abs(),
                'category': t.category.label.toLowerCase(),
              };
            })
        .toList();

    // For now, use default availability (8 AM to 11 PM with peak hours 8-11 AM)
    _suggestionsFuture = _getSuggestions(taskData);
  }

  Future<ScheduleSuggestions> _getSuggestions(List<Map<String, dynamic>> taskData) async {
    // This would be called from AIOptimizationController in a real app
    // For now, returning a placeholder
    throw UnimplementedError('Connect to AIOptimizationController');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 48,
                color: DzColors.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(height: DzSpacing.md),
              const Text('No tasks scheduled'),
              const SizedBox(height: DzSpacing.sm),
              const Text(
                'Add tasks to get schedule suggestions',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<ScheduleSuggestions>(
      future: _suggestionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(DzSpacing.lg),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: DzSpacing.md),
                  const Text('Generating optimal schedule...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(DzSpacing.md),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  const Text('Could not generate schedule'),
                  const SizedBox(height: DzSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _loadSuggestions()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final suggestions = snapshot.data;
        if (suggestions == null) {
          return const SizedBox.shrink();
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI-optimized for ${suggestions.totalFocusMinutes} min focus',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => setState(() => _loadSuggestions()),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Generate new schedule',
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
      },
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
                color: Colors.grey.withValues(alpha: 0.3),
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
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(DzSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${task.suggestedStartTime} - ${task.suggestedEndTime}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Chip(
                        label: Text(
                          '${(task.confidence * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: DzColors.primary.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  Text(
                    task.taskId,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.reason,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: DzSpacing.md),

        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DzSpacing.md),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.orange),
                const SizedBox(width: DzSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${breakRec.startTime} - ${breakRec.type}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${breakRec.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
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
