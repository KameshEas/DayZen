import 'package:dayzen/core/domain/gentle_milestones.dart';
import 'package:dayzen/core/services/achievement_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GentleMilestones', () {
    test('nothing is reached with no activity', () {
      final s = GentleMilestones.evaluate(const MilestoneStats());
      expect(s.where((m) => m.reached), isEmpty);
      expect(s, hasLength(GentleMilestones.all.length));
    });

    test('progress is capped at the target', () {
      final s = GentleMilestones.evaluate(const MilestoneStats(tasksDone: 500));
      final ten = s.firstWhere((m) => m.def.id == 'ten-done');
      expect(ten.current, 10);
      expect(ten.reached, isTrue);
    });

    test('letting a task go is a milestone, not a failure', () {
      final s = GentleMilestones.evaluate(const MilestoneStats(tasksLetGo: 1));
      expect(s.firstWhere((m) => m.def.id == 'first-let-go').reached, isTrue);
    });

    test('nothing is framed as a streak or a loss', () {
      for (final d in GentleMilestones.all) {
        final text = '${d.title} ${d.description}'.toLowerCase();
        for (final word in ['streak', 'in a row', 'lose', 'lost', 'miss', 'fail', 'overdue']) {
          expect(RegExp(r'\b' + word + r'\b').hasMatch(text), isFalse,
              reason: '${d.id}: "$word"');
        }
      }
    });

    test('ids are unique', () {
      final ids = GentleMilestones.all.map((d) => d.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
    });
  });

  group('AchievementService milestones', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('turns stats into achievements with unlock times', () async {
      final now = DateTime(2027, 2, 1, 10);
      final list = await AchievementService.instance.getAchievements(
        stats: const MilestoneStats(tasksPlanned: 3, tasksDone: 1),
        now: now,
      );
      final firstDone = list.firstWhere((a) => a.id == 'first-done');
      expect(firstDone.isUnlocked, isTrue);
      expect(firstDone.unlockedAt, now);
      expect(list.firstWhere((a) => a.id == 'ten-done').isUnlocked, isFalse);
      expect(list.firstWhere((a) => a.id == 'ten-done').progress.current, 1);
    });

    test('a reached milestone stays reached when the count drops', () async {
      final first = DateTime(2027, 2, 1);
      await AchievementService.instance.getAchievements(
        stats: const MilestoneStats(tasksDone: 12),
        now: first,
      );
      final later = await AchievementService.instance.getAchievements(
        stats: const MilestoneStats(tasksDone: 2), // tasks deleted since
        now: first.add(const Duration(days: 3)),
      );
      final ten = later.firstWhere((a) => a.id == 'ten-done');
      expect(ten.isUnlocked, isTrue);
      expect(ten.unlockedAt, first, reason: 'first unlock time kept');
      expect(ten.progress.isComplete, isTrue);
    });
  });
}
