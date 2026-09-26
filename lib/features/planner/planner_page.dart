import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/domain/planner_dates.dart';
import '../../core/routing/route_paths.dart';
import '../../core/utils/date_formatter.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import 'planner_selection.dart';
import 'schedule_suggestions_widget.dart';
import 'widgets/planner_date_header.dart';
import 'widgets/planner_timeline_view.dart';
import 'widgets/planner_week_strip.dart';

/// PlannerPage — composes PlannerTimelineView under features/planner/widgets/.
/// Split from a single 344-line file in Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
///
/// Browse any week from when you started using the app to two years ahead, and
/// plan tasks on any of those days. The day being viewed lives in
/// [PlannerSelection] so it survives tab switches and the centre "+" can use it.
class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key, this.selection});

  /// Only for tests; the app always uses [PlannerSelection.instance].
  final PlannerSelection? selection;

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  bool _showAiSuggestions = false;

  /// The day the app was first opened (null until read), the far end of the
  /// calendar you can browse back to.
  DateTime? _firstUse;

  PlannerSelection get _selection => widget.selection ?? PlannerSelection.instance;

  // Drives the timeline's "now" indicator line. The page otherwise only
  // rebuilds when TaskController notifies (task added/edited/completed), so
  // without this the current-time line stayed frozen at whatever time the
  // page happened to last rebuild at, instead of tracking real time.
  Timer? _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    AppPrefs.firstUseDate().then((d) {
      if (mounted && d != null) setState(() => _firstUse = d);
    });
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  /// The earliest day worth showing: the older of the first-use day and the
  /// oldest task, so nothing you have ever planned falls outside the calendar.
  DateTime? _earliest(List<DzTask> tasks) {
    DateTime? oldest = _firstUse;
    for (final t in tasks) {
      if (oldest == null || t.date.isBefore(oldest)) oldest = t.date;
    }
    return oldest;
  }

  Map<DateTime, DaySummary> _summaries(List<DzTask> tasks) {
    final out = <DateTime, DaySummary>{};
    for (final t in tasks) {
      final prev = out[t.date] ?? (total: 0, done: 0);
      out[t.date] = (total: prev.total + 1, done: prev.done + (t.isCompleted ? 1 : 0));
    }
    return out;
  }

  Future<void> _pickDate(PlannerRange range, DateTime selected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: range.firstDay,
      lastDate: range.lastDay,
      helpText: 'Jump to a date',
    );
    if (picked != null) _selection.value = dayOnly(picked);
  }

  void _addTask(DateTime day) => context.push(RoutePaths.newTask, extra: day);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([TaskScope.of(context), _selection]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final taskCtrl = TaskScope.of(context);
    final all = taskCtrl.all;
    final today = dayOnly(DateTime.now());
    final range = PlannerRange.from(today: today, earliest: _earliest(all));
    final selected = range.clamp(_selection.value);
    final dayTasks = taskCtrl.forDate(selected);

    return Column(
      children: [
        // ── Title + month controls ───────────────────────────────
        PlannerDateHeader(
          selected: selected,
          today: today,
          range: range,
          onPickDate: () => _pickDate(range, selected),
          onToday: () => _selection.reset(),
          onShiftWeek: (dir) =>
              _selection.value = range.clamp(addDays(selected, dir * 7)),
        ),

        // ── Week strip ───────────────────────────────────────────
        PlannerWeekStrip(
          // A new first week (older tasks appeared) renumbers the pages: start afresh.
          key: ValueKey(range.weekStart(0)),
          range: range,
          selected: selected,
          today: today,
          summaries: _summaries(all),
          onSelect: (d) => _selection.value = dayOnly(d),
        ),
        const SizedBox(height: DzSpacing.sm),

        // ── This day: how it stands, and add to it ────────────────
        _DaySummaryRow(
          tasks: dayTasks,
          day: selected,
          onAdd: () => _addTask(selected),
        ),

        // ── AI schedule suggestions (opt-in) ────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: DzGhostButton(
              label: _showAiSuggestions
                  ? AppConfig.plannerHideAiSuggestions
                  : AppConfig.plannerShowAiSuggestions,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18),
              onPressed: () => setState(() => _showAiSuggestions = !_showAiSuggestions),
            ),
          ),
        ),
        if (_showAiSuggestions) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
            child: ScheduleSuggestionsWidget(tasks: dayTasks),
          ),
          const SizedBox(height: DzSpacing.md),
        ],

        // ── Timeline ─────────────────────────────────────────────
        Expanded(
          child: _buildTimeline(context, selected, today, dayTasks),
        ),
      ],
    );
  }

  Widget _buildTimeline(
    BuildContext context,
    DateTime selected,
    DateTime today,
    List<DzTask> tasks,
  ) {
    final events = tasks.map(PlannerEvent.fromTask).toList();

    if (events.isEmpty) {
      final copy = _emptyCopy(selected, today);
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xl),
          child: DzEmptyState(
            icon: Icons.schedule_outlined,
            illustration: copy.illustration,
            title: copy.title,
            subtitle: copy.body,
            actionLabel: AppConfig.plannerEmptyAction,
            onAction: () => _addTask(selected),
          ),
        ),
      );
    }

    return PlannerTimelineView(
      key: ValueKey(selected),
      events: events,
      currentHour: _now.hour,
      currentMinute: _now.minute,
      showNow: isSameDay(selected, today),
    );
  }

  /// What an empty day says, depending on whether it is today, ahead, or behind.
  static ({String title, String body, DzIllustration illustration}) _emptyCopy(
    DateTime selected,
    DateTime today,
  ) {
    if (isSameDay(selected, today)) {
      return (
        title: AppConfig.plannerEmptyTitle,
        body: AppConfig.plannerEmptyBody,
        illustration: DzIllustration.emptyDayToday,
      );
    }
    final label = DateFormatter.formatDate(selected);
    return selected.isAfter(today)
        ? (
            title: 'Nothing planned yet',
            body: 'Plan ahead: add a task for $label.',
            illustration: DzIllustration.emptyDayFuture,
          )
        : (
            title: 'Nothing was planned',
            body: 'You can still add a task to log $label.',
            illustration: DzIllustration.emptyDayPast,
          );
  }
}

/// "3 tasks · 1 done" for the selected day, with an add button. Shows the day it
/// adds to, so it is clear a future date is being planned.
class _DaySummaryRow extends StatelessWidget {
  const _DaySummaryRow({required this.tasks, required this.day, required this.onAdd});
  final List<DzTask> tasks;
  final DateTime day;
  final VoidCallback onAdd;

  String get _summary {
    if (tasks.isEmpty) return 'No tasks';
    final done = tasks.where((t) => t.isCompleted).length;
    final noun = tasks.length == 1 ? 'task' : 'tasks';
    return '${tasks.length} $noun · $done done';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _summary,
              style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text('Add task', style: DzTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, DzSizing.minTouchTarget),
              foregroundColor: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
