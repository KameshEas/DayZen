import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../../core/domain/day_load.dart';
import '../../home/models/task_model.dart';
import '../../task_controller.dart';

/// A Day Load input for a task.
LoadTask loadTaskOf(DzTask t) => LoadTask(
      id: t.id,
      date: t.date,
      status: switch (t.status) {
        TaskStatus.active => LoadStatus.active,
        TaskStatus.done => LoadStatus.done,
        TaskStatus.released => LoadStatus.released,
      },
      effort: t.effort,
      priorityRank: switch (t.priority) {
        TaskPriority.high => 4,
        TaskPriority.zen => 3,
        TaskPriority.routine => 2,
        TaskPriority.low => 1,
      },
      startMinute: t.startTime.hour * 60 + t.startTime.minute,
    );

/// Day Load for [day] from every task (history included).
DayLoadResult dayLoadFor(List<DzTask> tasks, DateTime day) =>
    DayLoad.compute(today: day, tasks: tasks.map(loadTaskOf));

/// The pill for [day] (Home: today; planner: the day being viewed). When the
/// day is Heavy, tapping it offers to move the suggested task to the next
/// day; otherwise it explains what the level means.
class DayLoadIndicator extends StatelessWidget {
  const DayLoadIndicator({super.key, required this.tasks, required this.day});

  final TaskController tasks;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final result = dayLoadFor(tasks.all, day);
    return Align(
      alignment: Alignment.centerLeft,
      child: DayLoadPill(
        result: result,
        onTap: () => _explain(context, result),
      ),
    );
  }

  Future<void> _explain(BuildContext context, DayLoadResult r) async {
    final suggest = r.suggestMoveId == null ? null : tasks.taskById(r.suggestMoveId!);
    final move = await showModalBottomSheet<bool>(
      useRootNavigator: true, // above the tab bar, not inside the shell
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${r.level.label} day', style: DzTextStyles.heading3),
              const SizedBox(height: DzSpacing.sm),
              Text(_explanation(r), style: DzTextStyles.body),
              if (suggest != null) ...[
                const SizedBox(height: DzSpacing.lg),
                Text('Move "${suggest.title}" to tomorrow?',
                    style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: DzSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: DzSecondaryButton(
                        label: 'Keep it',
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: DzSpacing.sm),
                    Expanded(
                      child: DzPrimaryButton(
                        label: 'Move it',
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (move == true && suggest != null) {
      await tasks.updateTask(
        suggest.id,
        suggest.copyWith(date: suggest.date.add(const Duration(days: 1))),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${suggest.title}" moved to tomorrow')),
        );
      }
    }
  }

  static String _explanation(DayLoadResult r) {
    if (!r.hasHistory) {
      return 'DayZen compares each day with what you usually finish. After a few '
          'days of use it can tell you when a day looks light or heavy.';
    }
    return switch (r.level) {
      DayLoadLevel.light => 'Less planned than you usually get done. Room to breathe.',
      DayLoadLevel.balanced => 'About what you usually get done.',
      DayLoadLevel.heavy => 'More planned than you usually get done. '
          'Moving one thing can make it feel lighter.',
    };
  }
}

/// "Balanced day" pill (plan M-2.6). Calm colours only: Heavy is amber, never
/// red, because a full day is information, not a failure.
class DayLoadPill extends StatelessWidget {
  const DayLoadPill({super.key, required this.result, this.onTap});

  final DayLoadResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg, IconData icon) = switch (result.level) {
      DayLoadLevel.light => (
          DzColors.zenGreen.withValues(alpha: 0.14),
          scheme.brightness == Brightness.dark ? DzColors.brightGreen : DzColors.forestGreen,
          Icons.spa_outlined,
        ),
      DayLoadLevel.balanced => (
          scheme.primary.withValues(alpha: 0.10),
          scheme.primary,
          Icons.balance_rounded,
        ),
      DayLoadLevel.heavy => (
          DzColors.warning.withValues(alpha: 0.18),
          scheme.brightness == Brightness.dark ? DzColors.warning : const Color(0xFF8A5A0B),
          Icons.layers_outlined,
        ),
    };
    final label = '${result.level.label} day';
    return Semantics(
      label: result.hasHistory
          ? '$label: about ${(result.load / result.baseline! * 100).round()} percent of a usual day'
          : label,
      button: onTap != null,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      style: DzTextStyles.caption.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
