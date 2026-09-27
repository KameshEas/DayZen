import 'package:flutter/material.dart';
import '../../../core/app_prefs.dart';
import '../../../core/config/app_config.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../task_controller.dart';
import '../models/task_model.dart';

/// Shows a "did you get to these?" dialog once per app session for tasks
/// whose scheduled time has already passed but are still marked incomplete.
/// A no-op if there's nothing to ask about. Each task is only ever asked
/// about once (tracked in [AppPrefs]), regardless of how it's answered.
Future<void> maybeShowOverdueTasksPopup(
  BuildContext context,
  TaskController taskCtrl,
) async {
  final now = DateTime.now();
  final prompted = await AppPrefs.promptedOverdueTaskIds();

  final overdue = taskCtrl.all.where((t) {
    if (t.isCompleted || prompted.contains(t.id)) return false;
    final endDateTime = DateTime(
      t.date.year,
      t.date.month,
      t.date.day,
      t.endTime.hour,
      t.endTime.minute,
    );
    return endDateTime.isBefore(now);
  }).toList();

  if (overdue.isEmpty || !context.mounted) return;

  // Marked up front so dismissing the dialog without tapping anything still
  // doesn't cause a repeat nag on the next app open.
  for (final task in overdue) {
    await AppPrefs.markOverdueTaskPrompted(task.id);
  }

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => _OverdueTasksDialog(tasks: overdue, taskCtrl: taskCtrl),
  );
}

class _OverdueTasksDialog extends StatefulWidget {
  const _OverdueTasksDialog({required this.tasks, required this.taskCtrl});
  final List<DzTask> tasks;
  final TaskController taskCtrl;

  @override
  State<_OverdueTasksDialog> createState() => _OverdueTasksDialogState();
}

class _OverdueTasksDialogState extends State<_OverdueTasksDialog> {
  late final List<DzTask> _remaining = List.of(widget.tasks);

  void _resolve(DzTask task, {required bool done}) {
    if (done) widget.taskCtrl.toggleTask(task.id);
    setState(() => _remaining.removeWhere((t) => t.id == task.id));
    if (_remaining.isEmpty) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        // Bounded and scrollable: a handful of overdue tasks otherwise
        // grows this dialog taller than the screen (no scroll = overflow).
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConfig.overdueTaskPopupTitle,
                style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: DzSpacing.md),
              ..._remaining.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: DzSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(
                        task.timeRange,
                        style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: DzSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: DzSecondaryButton(
                              label: AppConfig.overdueTaskPopupSkipLabel,
                              onPressed: () => _resolve(task, done: false),
                            ),
                          ),
                          const SizedBox(width: DzSpacing.sm),
                          Expanded(
                            child: DzPrimaryButton(
                              label: AppConfig.overdueTaskPopupDoneLabel,
                              onPressed: () => _resolve(task, done: true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
