import 'package:flutter/material.dart';

import '../../core/domain/brain_dump_parser.dart';
import '../../core/domain/rhythm/energy_profile.dart';
import '../../core/domain/rhythm/rhythm_scheduler.dart';
import '../../core/utils/ids.dart';
import '../home/models/task_model.dart';

/// A draft with the slot it will be saved in.
class PlannedDraft {
  const PlannedDraft({
    required this.index,
    required this.draft,
    required this.dayOffset,
    required this.startMinute,
    required this.movedToTomorrow,
  });

  /// Position in [OnboardingPlan.build]'s input, so edits map back.
  final int index;
  final TaskDraft draft;

  /// 0 = today, 1 = tomorrow.
  final int dayOffset;
  final int startMinute;

  /// No room left today, so it went to tomorrow.
  final bool movedToTomorrow;

  int get endMinute => startMinute + draft.durationMinutes;
}

/// Places onboarding drafts on today's (and tomorrow's) timeline with
/// [RhythmScheduler], using the prior from step 2.
///
/// - A draft with a time keeps it (fixed).
/// - Others go where the prior says: work and study into the energy peak,
///   mindful tasks in a good-energy stretch, personal errands in the troughs.
/// - Today nothing is placed before [now]; what doesn't fit moves to tomorrow.
class OnboardingPlan {
  OnboardingPlan._();

  static const dayStartMinute = 7 * 60;
  static const dayEndMinute = 22 * 60;

  static List<PlannedDraft> build({
    required List<TaskDraft> drafts,
    required RhythmPrior prior,
    required DateTime now,
  }) {
    final profile = EnergyProfile.prior(prior);
    final out = <PlannedDraft>[];
    final overflow = <int>[];

    for (final offset in const [0, 1]) {
      final indices = <int>[
        for (var i = 0; i < drafts.length; i++)
          if (drafts[i].dayOffset == offset) i,
        if (offset == 1) ...overflow,
      ];
      if (indices.isEmpty) continue;
      final result = RhythmScheduler.schedule(
        items: [
          for (final i in indices)
            ScheduleItem(
              id: '$i',
              durationMinutes: drafts[i].durationMinutes,
              priority: _slotPriority(drafts[i].category),
              fixedStartMinute: drafts[i].startMinute,
            ),
        ],
        profile: profile,
        dayStartMinute: dayStartMinute,
        dayEndMinute: dayEndMinute,
        notBeforeMinute: offset == 0 ? now.hour * 60 + now.minute : null,
      );
      for (final p in result.placed) {
        final i = int.parse(p.id);
        out.add(PlannedDraft(
          index: i,
          draft: drafts[i],
          dayOffset: offset,
          startMinute: p.startMinute,
          movedToTomorrow: offset == 1 && drafts[i].dayOffset == 0,
        ));
      }
      if (offset == 0) {
        overflow.addAll(result.unplaceable.map(int.parse));
      } else {
        // Still no room tomorrow: put it at the end of tomorrow's day
        // rather than lose it. The user can drag it in the preview.
        for (final id in result.unplaceable) {
          final i = int.parse(id);
          out.add(PlannedDraft(
            index: i,
            draft: drafts[i],
            dayOffset: 1,
            startMinute: dayEndMinute,
            movedToTomorrow: drafts[i].dayOffset == 0,
          ));
        }
      }
    }

    out.sort((a, b) {
      final d = a.dayOffset.compareTo(b.dayOffset);
      return d != 0 ? d : a.startMinute.compareTo(b.startMinute);
    });
    return out;
  }

  static SlotPriority _slotPriority(TaskCategory c) => switch (c) {
        TaskCategory.work || TaskCategory.study => SlotPriority.high,
        TaskCategory.mindful => SlotPriority.zen,
        TaskCategory.personal => SlotPriority.routine,
      };

  /// The saved task's priority: mindful drafts are Zen, everything else
  /// Routine (the user can raise it later; onboarding never asks).
  static TaskPriority taskPriority(TaskCategory c) =>
      c == TaskCategory.mindful ? TaskPriority.zen : TaskPriority.routine;

  static IconData categoryIcon(TaskCategory c) => switch (c) {
        TaskCategory.work => Icons.work_outline_rounded,
        TaskCategory.personal => Icons.person_outline_rounded,
        TaskCategory.mindful => Icons.self_improvement_rounded,
        TaskCategory.study => Icons.menu_book_rounded,
      };

  /// Real tasks for a plan, each with a globally unique id (see [newId]).
  static List<DzTask> toTasks(
    List<PlannedDraft> plan, {
    required DateTime now,
  }) {
    final today = DateTime(now.year, now.month, now.day);
    return [
      for (final p in plan)
        DzTask(
          id: newId('task', now: now),
          title: p.draft.title,
          startTime: _time(p.startMinute),
          endTime: _time(p.endMinute),
          priority: taskPriority(p.draft.category),
          category: p.draft.category,
          icon: categoryIcon(p.draft.category),
          date: today.add(Duration(days: p.dayOffset)),
        ),
    ];
  }

  static TimeOfDay _time(int minute) {
    final m = minute.clamp(0, 23 * 60 + 59);
    return TimeOfDay(hour: m ~/ 60, minute: m % 60);
  }
}
