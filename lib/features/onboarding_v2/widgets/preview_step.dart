import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/config/copy/onboarding_v2_copy.dart';
import '../../../core/design_system/design_system.dart' hide TaskPriority;
import '../../../core/domain/day_load.dart';
import '../../../core/domain/rhythm/energy_profile.dart';
import '../../home/models/task_model.dart';
import '../../planner/widgets/day_load_pill.dart';
import '../../planner/widgets/energy_tide.dart';
import '../onboarding_controller.dart';
import '../onboarding_plan.dart';
import 'draft_edit_sheet.dart';
import 'onboarding_scaffold.dart';

/// Step 3: the live timeline preview, with the energy tide behind it and a
/// Day Load pill. Blocks can be dragged to a new time.
class PreviewStep extends StatelessWidget {
  const PreviewStep({
    super.key,
    required this.controller,
    this.existingTasks = const [],
  });

  final OnboardingController controller;

  /// Tasks already on the phone (a restored account), for Day Load history.
  final List<DzTask> existingTasks;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final today = c.todayPlan;
    final tomorrow = c.tomorrowPlan;
    final prior = c.prior ?? RhythmPrior.notSure;
    final now = DateTime.now();
    final load = DayLoad.compute(today: now, tasks: [
      for (final t in existingTasks) loadTaskOf(t),
      for (final p in today)
        LoadTask(id: 'd${p.index}', date: now, status: LoadStatus.active),
    ]);

    return OnboardingStepFrame(
      stepNumber: 3,
      title: OnboardingV2Copy.previewTitle,
      body: OnboardingV2Copy.previewBody,
      onBack: c.back,
      actions: DzPrimaryButton(
        label: OnboardingV2Copy.looksGood,
        onPressed: c.continueFromPreview,
        width: double.infinity,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DayLoadPill(result: load),
          const SizedBox(height: DzSpacing.md),
          if (today.isEmpty)
            Text(OnboardingV2Copy.previewEmptyToday,
                style: DzTextStyles.body.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant))
          else
            PreviewTimeline(
              plan: today,
              profile: EnergyProfile.prior(prior),
              onMove: (index, start) =>
                  c.moveDraft(index, startMinute: start, dayOffset: 0),
            ),
          if (tomorrow.isNotEmpty) ...[
            const SizedBox(height: DzSpacing.lg),
            Semantics(
              header: true,
              child: const Text(OnboardingV2Copy.previewTomorrow,
                  style: DzTextStyles.heading3),
            ),
            const SizedBox(height: DzSpacing.sm),
            for (final p in tomorrow) _TomorrowRow(planned: p),
          ],
        ],
      ),
    );
  }
}

/// A Day Load input for an existing task.
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

class _TomorrowRow extends StatelessWidget {
  const _TomorrowRow({required this.planned});
  final PlannedDraft planned;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: DzSpacing.xs),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Text(formatMinuteOfDay(planned.startMinute),
                style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(planned.draft.title,
                style: DzTextStyles.body, overflow: TextOverflow.ellipsis),
          ),
          if (planned.movedToTomorrow)
            Text(OnboardingV2Copy.previewMovedNote,
                style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Today's planned drafts on an hour grid. A long-press-free vertical drag
/// moves a block in 15-minute steps; the move is committed on release.
class PreviewTimeline extends StatefulWidget {
  const PreviewTimeline({
    super.key,
    required this.plan,
    required this.profile,
    required this.onMove,
  });

  final List<PlannedDraft> plan;
  final EnergyProfile profile;

  /// (draft index, new start minute).
  final void Function(int index, int startMinute) onMove;

  static const double hourHeight = 64;
  static const double timeColumn = 56;

  @override
  State<PreviewTimeline> createState() => _PreviewTimelineState();
}

class _PreviewTimelineState extends State<PreviewTimeline> {
  int? _dragging;
  double _dragDy = 0;

  ({int start, int end}) get _hours {
    final first = widget.plan.map((p) => p.startMinute).reduce(math.min);
    final last = widget.plan.map((p) => p.endMinute).reduce(math.max);
    final start = math.max(0, first ~/ 60 - 1);
    final end = math.min(24, (last + 59) ~/ 60 + 1);
    return (start: start, end: math.max(end, start + 3));
  }

  int _snap(double minutes) => (minutes / 15).round() * 15;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hours = _hours;
    const h = PreviewTimeline.hourHeight;
    final height = (hours.end - hours.start) * h;

    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, constraints) {
        final blockWidth = constraints.maxWidth - PreviewTimeline.timeColumn;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: PreviewTimeline.timeColumn,
              right: 0,
              top: 0,
              child: EnergyTide(
                profile: widget.profile,
                startHour: hours.start,
                endHour: hours.end,
                hourHeight: h,
              ),
            ),
            for (var hr = hours.start; hr < hours.end; hr++)
              Positioned(
                top: (hr - hours.start) * h,
                left: 0,
                right: 0,
                child: ExcludeSemantics(
                  child: Row(
                    children: [
                      SizedBox(
                        width: PreviewTimeline.timeColumn,
                        child: Text(
                          formatMinuteOfDay(hr * 60).replaceAll(':00', ''),
                          style: DzTextStyles.small
                              .copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          height: 1,
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            for (final p in widget.plan)
              _block(context, p, hours.start, blockWidth, hours.end),
          ],
        );
      }),
    );
  }

  Widget _block(BuildContext context, PlannedDraft p, int startHour,
      double width, int endHour) {
    const h = PreviewTimeline.hourHeight;
    final dragging = _dragging == p.index;
    final baseTop = (p.startMinute - startHour * 60) / 60 * h;
    final maxTop = (endHour - startHour) * h - p.draft.durationMinutes / 60 * h;
    final double top = dragging
        ? (baseTop + _dragDy).clamp(0.0, math.max(0.0, maxTop)).toDouble()
        : baseTop;
    final previewStart = dragging
        ? startHour * 60 + _snap(top / h * 60)
        : p.startMinute;
    final blockHeight =
        math.max(p.draft.durationMinutes / 60 * h - 2, 30.0).toDouble();
    final color = OnboardingPlan.taskPriority(p.draft.category).color;
    final scheme = Theme.of(context).colorScheme;

    void commit(int minute) =>
        widget.onMove(p.index, minute.clamp(0, 24 * 60 - p.draft.durationMinutes));

    return Positioned(
      key: ValueKey('preview-block-${p.index}'),
      top: top,
      left: PreviewTimeline.timeColumn + 4,
      width: width - 8,
      height: blockHeight,
      child: Semantics(
        label: '${p.draft.title}, ${formatMinuteOfDay(previewStart)}, '
            '${formatDuration(p.draft.durationMinutes)}',
        hint: 'Drag up or down to move',
        customSemanticsActions: {
          const CustomSemanticsAction(label: 'Move 15 minutes earlier'): () =>
              commit(p.startMinute - 15),
          const CustomSemanticsAction(label: 'Move 15 minutes later'): () =>
              commit(p.startMinute + 15),
        },
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) => setState(() {
            _dragging = p.index;
            _dragDy = 0;
          }),
          onVerticalDragUpdate: (d) => setState(() => _dragDy += d.delta.dy),
          onVerticalDragEnd: (_) {
            final minute = previewStart;
            setState(() {
              _dragging = null;
              _dragDy = 0;
            });
            commit(minute);
          },
          onVerticalDragCancel: () => setState(() {
            _dragging = null;
            _dragDy = 0;
          }),
          child: AnimatedContainer(
            duration: dragging ? Duration.zero : DzDuration.fast,
            padding: const EdgeInsets.symmetric(horizontal: DzSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(DzRadius.small),
              border: Border(left: BorderSide(color: color, width: 4)),
              boxShadow: dragging ? DzShadows.elevated : DzShadows.soft,
            ),
            child: Row(
              children: [
                Icon(OnboardingPlan.categoryIcon(p.draft.category),
                    size: 16, color: color),
                const SizedBox(width: DzSpacing.sm),
                Expanded(
                  child: Text(
                    p.draft.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formatMinuteOfDay(previewStart),
                  style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(width: 4),
                Icon(Icons.drag_indicator_rounded,
                    size: 16, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
