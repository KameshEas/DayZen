import 'package:flutter/material.dart';

import '../../core/config/copy/close_day_copy.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import '../task_controller.dart';

/// "Let go" (plan M-1.12): every task the user chose to let go, newest day
/// first. Bring one back (it lands on today if its day has passed) or delete
/// it. Calm styling throughout; nothing here is shown as a failure.
class ReleasedTasksPage extends StatelessWidget {
  const ReleasedTasksPage({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    final ctrl = TaskScope.of(context);
    return Scaffold(
      appBar: const DzAppBar(title: CloseDayCopy.releasedTitle),
      body: ListenableBuilder(
        listenable: ctrl,
        builder: (context, _) => _body(context, ctrl),
      ),
    );
  }

  Widget _body(BuildContext context, TaskController ctrl) {
    final scheme = Theme.of(context).colorScheme;
    final released = ctrl.all.where((t) => t.status == TaskStatus.released).toList()
      ..sort((a, b) {
        final d = b.date.compareTo(a.date);
        if (d != 0) return d;
        return (a.startTime.hour * 60 + a.startTime.minute)
            .compareTo(b.startTime.hour * 60 + b.startTime.minute);
      });

    if (released.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(DzSpacing.lg),
          child: DzEmptyState(
            icon: Icons.spa_outlined,
            title: CloseDayCopy.releasedTitle,
            subtitle: CloseDayCopy.releasedEmpty,
          ),
        ),
      );
    }

    final rows = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(
            DzSpacing.md, DzSpacing.md, DzSpacing.md, DzSpacing.sm),
        child: Text(CloseDayCopy.releasedBody,
            style: DzTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
      ),
    ];
    DateTime? lastDay;
    for (final t in released) {
      if (t.date != lastDay) {
        lastDay = t.date;
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(
              DzSpacing.md, DzSpacing.md, DzSpacing.md, DzSpacing.xs),
          child: Semantics(
            header: true,
            child: Text(DateFormatter.formatDate(t.date),
                style: DzTextStyles.label.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ));
      }
      rows.add(_ReleasedRow(
        task: t,
        onBringBack: () => _bringBack(context, ctrl, t),
        onDelete: () => _delete(context, ctrl, t),
      ));
    }
    return ListView(padding: const EdgeInsets.only(bottom: DzSpacing.xl), children: rows);
  }

  Future<void> _bringBack(BuildContext context, TaskController ctrl, DzTask t) async {
    final now = (clock ?? DateTime.now)();
    final today = DateTime(now.year, now.month, now.day);
    final restored = t.date.isBefore(today)
        ? t.copyWith(status: TaskStatus.active, date: today)
        : t.copyWith(status: TaskStatus.active);
    await ctrl.updateTask(t.id, restored);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('"${t.title}" is back on your day')));
  }

  Future<void> _delete(BuildContext context, TaskController ctrl, DzTask t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('"${t.title}" will be removed for good.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(CloseDayCopy.delete)),
        ],
      ),
    );
    if (ok == true) await ctrl.deleteTask(t.id);
  }
}

class _ReleasedRow extends StatelessWidget {
  const _ReleasedRow({
    required this.task,
    required this.onBringBack,
    required this.onDelete,
  });

  final DzTask task;
  final VoidCallback onBringBack;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(task.icon ?? Icons.spa_outlined, color: scheme.onSurfaceVariant),
      title: Text(task.title),
      subtitle: Text(task.timeRange),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: '${CloseDayCopy.bringBack}: ${task.title}',
            icon: const Icon(Icons.undo_rounded),
            onPressed: onBringBack,
          ),
          IconButton(
            tooltip: '${CloseDayCopy.delete}: ${task.title}',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
