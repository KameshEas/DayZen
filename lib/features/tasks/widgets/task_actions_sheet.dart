import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/date_formatter.dart';
import '../../app_data.dart';
import '../../home/models/task_model.dart';

/// What the user picked in the task actions sheet.
enum TaskAction { done, notDone, letGo, bringBack, edit, delete }

/// Opens the actions for the task(s) behind a timeline card: mark done, let go,
/// bring back, edit, delete. A card standing for several identical tasks first
/// asks which one.
Future<void> showTaskActions(BuildContext context, List<String> taskIds) async {
  final ctrl = TaskScope.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.maybeOf(context);

  final tasks = [
    for (final id in taskIds) ?ctrl.taskById(id),
  ];
  if (tasks.isEmpty) return;

  final task = tasks.length == 1 ? tasks.first : await _pickOne(context, tasks);
  if (task == null || !context.mounted) return;

  final action = await showModalBottomSheet<TaskAction>(
    context: context,
    // Above the tab shell, so the bottom bar and + button don't cover it.
    useRootNavigator: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DzRadius.modal)),
    ),
    builder: (_) => TaskActionsSheet(task: task),
  );
  if (action == null || !context.mounted) return;

  Future<void> changeStatus(TaskStatus to, String message) async {
    final before = task.status;
    await ctrl.setStatus(task.id, to);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ctrl.setStatus(task.id, before),
        ),
      ));
  }

  switch (action) {
    case TaskAction.done:
      await changeStatus(TaskStatus.done, 'Marked done');
    case TaskAction.notDone:
      await changeStatus(TaskStatus.active, 'Marked not done');
    case TaskAction.letGo:
      await changeStatus(TaskStatus.released, "Let go. It won't roll over.");
    case TaskAction.bringBack:
      await changeStatus(TaskStatus.active, 'Back on your day');
    case TaskAction.edit:
      // A leftover "Marked done" would otherwise sit on top of the form.
      messenger.hideCurrentSnackBar();
      await router?.push(RoutePaths.newTask, extra: task);
    case TaskAction.delete:
      final sure = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete this task?'),
          content: Text('"${task.title}" will be removed from your day.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('confirm-delete-task'),
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (sure != true) return;
      await ctrl.deleteTask(task.id);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Task deleted')));
  }
}

/// For a card that stands for several identical tasks: which one?
Future<DzTask?> _pickOne(BuildContext context, List<DzTask> tasks) {
  return showModalBottomSheet<DzTask>(
    context: context,
    // Above the tab shell, so the bottom bar and + button don't cover it.
    useRootNavigator: true,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.sm),
            child: Text('${tasks.length} identical tasks',
                style: DzTextStyles.heading3),
          ),
          for (final (i, t) in tasks.indexed)
            ListTile(
              title: Text('${t.title} (${i + 1})'),
              subtitle: Text(_statusLabel(t)),
              onTap: () => Navigator.of(ctx).pop(t),
            ),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    ),
  );
}

String _statusLabel(DzTask t) => switch (t.status) {
      TaskStatus.done => 'Done',
      TaskStatus.released => 'Let go',
      TaskStatus.active =>
        t.rolloverCount > 0 ? 'Carried ${t.rolloverCount}×' : 'To do',
    };

/// The sheet body: what the task is, then the actions that fit its status.
/// Pops with the chosen [TaskAction].
class TaskActionsSheet extends StatelessWidget {
  const TaskActionsSheet({super.key, required this.task});

  final DzTask task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    void pick(TaskAction a) => Navigator.of(context).pop(a);

    Widget tile(TaskAction a, IconData icon, String label,
            {String? hint, Color? color}) =>
        ListTile(
          key: Key('task-action-${a.name}'),
          leading: Icon(icon, color: color ?? scheme.onSurfaceVariant),
          title: Text(label, style: TextStyle(color: color)),
          subtitle: hint == null ? null : Text(hint),
          onTap: () => pick(a),
        );

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: DzTextStyles.heading3),
                const SizedBox(height: DzSpacing.xs),
                Text(
                  '${DateFormatter.formatDate(task.date)} · ${task.timeRange}',
                  style: DzTextStyles.caption
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
                if (task.status != TaskStatus.active ||
                    task.rolloverCount > 0) ...[
                  const SizedBox(height: DzSpacing.sm),
                  _StatusChip(label: _statusLabel(task)),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ...switch (task.status) {
            TaskStatus.active => [
                tile(TaskAction.done, Icons.check_circle_outline_rounded,
                    'Mark done', color: DzColors.zenGreen),
                tile(TaskAction.letGo, Icons.air_rounded, 'Let it go',
                    hint: "Not today. It won't roll over."),
              ],
            TaskStatus.done => [
                tile(TaskAction.notDone, Icons.radio_button_unchecked_rounded,
                    'Mark not done'),
              ],
            TaskStatus.released => [
                tile(TaskAction.bringBack, Icons.undo_rounded, 'Bring it back',
                    hint: 'Make it a to-do again'),
              ],
          },
          tile(TaskAction.edit, Icons.edit_outlined, 'Edit'),
          tile(TaskAction.delete, Icons.delete_outline_rounded, 'Delete',
              color: scheme.error),
          const SizedBox(height: DzSpacing.sm),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: DzTextStyles.small.copyWith(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
