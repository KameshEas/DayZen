import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final taskCtrl = TaskScope.of(context);
    final tasks = taskCtrl.all;
    final task = tasks.isEmpty ? null : tasks.cast<dynamic>().fold(
      null,
      (prev, t) => (t.id as String) == taskId ? t : prev,
    );

    return DzAuthScaffold(
      appBar: DzAppBar(
        title: 'Task Details',
      ),
      body: task == null
          ? DzEmptyState(
              icon: Icons.task_alt_outlined,
              title: AppConfig.taskNotFound,
              subtitle: 'Task no longer exists.',
              actionLabel: 'Back',
              onAction: () => Navigator.of(context).pop(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(DzSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title as String,
                      style: DzTextStyles.heading2,
                    ),
                    SizedBox(height: DzSpacing.md),

                    // Priority badge
                    DzCard(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DzSpacing.md,
                          vertical: DzSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flag_outlined,
                              size: 16,
                            ),
                            SizedBox(width: DzSpacing.sm),
                            Text(
                              (task.priority as dynamic).label as String,
                              style: DzTextStyles.label,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: DzSpacing.md),

                    // Details in a card
                    DzCard(
                      child: Padding(
                        padding: const EdgeInsets.all(DzSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(
                              label: 'Category',
                              value: (task.category as dynamic).label as String,
                            ),
                            Divider(height: DzSpacing.md),
                            _DetailRow(
                              label: 'Date',
                              value: task.date.toString(),
                            ),
                            Divider(height: DzSpacing.md),
                            _DetailRow(
                              label: 'Start Time',
                              value: task.startTime.toString(),
                            ),
                            Divider(height: DzSpacing.md),
                            _DetailRow(
                              label: 'Duration',
                              value: '${task.estimatedDurationMinutes} minutes',
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: DzSpacing.md),

                    // Completion status
                    DzCard(
                      child: CheckboxListTile(
                        title: const Text('Mark as Completed'),
                        value: task.isCompleted as bool,
                        onChanged: null,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DzTextStyles.caption),
        Text(value, style: DzTextStyles.body),
      ],
    );
  }
}
