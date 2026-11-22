import 'package:dayzen/core/domain/brain_dump_parser.dart';
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/onboarding_v2/onboarding_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final morningAt7 = DateTime(2027, 1, 12, 7, 0);

  test('a draft with a time keeps it', () {
    final plan = OnboardingPlan.build(
      drafts: const [TaskDraft(title: 'Gym', startMinute: 18 * 60, durationMinutes: 60)],
      prior: RhythmPrior.morning,
      now: morningAt7,
    );
    expect(plan.single.startMinute, 18 * 60);
    expect(plan.single.dayOffset, 0);
  });

  test('work goes into the morning peak for a morning person', () {
    final plan = OnboardingPlan.build(
      drafts: const [
        TaskDraft(title: 'Write report', durationMinutes: 60, category: TaskCategory.work),
      ],
      prior: RhythmPrior.morning,
      now: morningAt7,
    );
    expect(plan.single.startMinute, inInclusiveRange(8 * 60, 9 * 60));
  });

  test('and into the evening for an evening person', () {
    final plan = OnboardingPlan.build(
      drafts: const [
        TaskDraft(title: 'Write report', durationMinutes: 60, category: TaskCategory.work),
      ],
      prior: RhythmPrior.evening,
      now: morningAt7,
    );
    expect(plan.single.startMinute, greaterThanOrEqualTo(18 * 60));
  });

  test('nothing flexible is placed before now', () {
    final plan = OnboardingPlan.build(
      drafts: const [TaskDraft(title: 'Groceries')],
      prior: RhythmPrior.morning,
      now: DateTime(2027, 1, 12, 15, 40),
    );
    expect(plan.single.startMinute, greaterThanOrEqualTo(15 * 60 + 45));
  });

  test('what does not fit today moves to tomorrow, flagged', () {
    final plan = OnboardingPlan.build(
      drafts: const [TaskDraft(title: 'Deep work', durationMinutes: 120, category: TaskCategory.work)],
      prior: RhythmPrior.morning,
      now: DateTime(2027, 1, 12, 21, 0),
    );
    expect(plan.single.dayOffset, 1);
    expect(plan.single.movedToTomorrow, isTrue);
  });

  test('"tomorrow" drafts are planned for tomorrow, not flagged as moved', () {
    final plan = OnboardingPlan.build(
      drafts: const [TaskDraft(title: 'Dentist', dayOffset: 1)],
      prior: RhythmPrior.notSure,
      now: morningAt7,
    );
    expect(plan.single.dayOffset, 1);
    expect(plan.single.movedToTomorrow, isFalse);
  });

  test('no two planned drafts on the same day overlap', () {
    final drafts = [
      for (var i = 0; i < 8; i++)
        TaskDraft(
          title: 't$i',
          durationMinutes: 45,
          category: TaskCategory.values[i % 4],
        ),
    ];
    final plan = OnboardingPlan.build(
      drafts: drafts,
      prior: RhythmPrior.midday,
      now: morningAt7,
    );
    expect(plan, hasLength(8));
    for (final a in plan) {
      for (final b in plan) {
        if (identical(a, b) || a.dayOffset != b.dayOffset) continue;
        expect(a.startMinute < b.endMinute && b.startMinute < a.endMinute, isFalse,
            reason: '${a.draft.title} overlaps ${b.draft.title}');
      }
    }
  });

  test('toTasks makes real tasks on the right days with unique ids', () {
    final plan = OnboardingPlan.build(
      drafts: const [
        TaskDraft(title: 'Meditate', durationMinutes: 10, category: TaskCategory.mindful),
        TaskDraft(title: 'Dentist', startMinute: 10 * 60, dayOffset: 1),
      ],
      prior: RhythmPrior.morning,
      now: morningAt7,
    );
    final tasks = OnboardingPlan.toTasks(plan, now: morningAt7, idPrefix: 'ob1');
    expect(tasks.map((t) => t.id).toSet(), hasLength(2));
    final meditate = tasks.firstWhere((t) => t.title == 'Meditate');
    final dentist = tasks.firstWhere((t) => t.title == 'Dentist');
    expect(meditate.priority, TaskPriority.zen);
    expect(meditate.date, DateTime(2027, 1, 12));
    expect(dentist.date, DateTime(2027, 1, 13));
    expect(dentist.startTime.hour, 10);
    expect(dentist.endTime.hour * 60 + dentist.endTime.minute, 10 * 60 + 30);
    expect(tasks.every((t) => t.status == TaskStatus.active), isTrue);
  });
}
