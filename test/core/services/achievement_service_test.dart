import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/services/achievement_service.dart';

void main() {
  group('AchievementService', () {
    group('Achievement Model', () {
      test('creates achievement from JSON', () {
        final json = {
          'id': 'focus-30h',
          'title': 'Focus Master',
          'description': 'Complete 30 hours of focused work',
          'icon': 'medal',
          'progress': {'current': 28, 'target': 30},
          'unlocked_at': null,
        };

        final achievement = Achievement.fromJson(json);

        expect(achievement.id, equals('focus-30h'));
        expect(achievement.title, equals('Focus Master'));
        expect(achievement.isUnlocked, isFalse);
        expect(achievement.progress.percentageComplete, closeTo(93.33, 0.1));
      });

      test('parses unlocked_at timestamp', () {
        final json = {
          'id': 'early-bird',
          'title': 'Early Bird',
          'description': 'Complete 10 tasks before 9 AM',
          'icon': 'sun',
          'progress': {'current': 10, 'target': 10},
          'unlocked_at': '2026-06-13T08:45:00Z',
        };

        final achievement = Achievement.fromJson(json);

        expect(achievement.isUnlocked, isTrue);
        expect(achievement.unlockedAt, isNotNull);
      });
    });

    group('AchievementProgress Model', () {
      test('calculates percentage complete', () {
        final progress = AchievementProgress(current: 75, target: 100);
        expect(progress.percentageComplete, equals(75));
        expect(progress.isComplete, isFalse);
      });

      test('marks complete when current >= target', () {
        final progress = AchievementProgress(current: 100, target: 100);
        expect(progress.isComplete, isTrue);
      });

      test('clamps percentage to 0-100', () {
        final progress = AchievementProgress(current: 150, target: 100);
        expect(progress.percentageComplete, equals(100));
      });
    });

    group('getAchievements API', () {
      test('parses achievements list from API response', () {
        final json = {
          'achievements': [
            {
              'id': 'focus-30h',
              'title': 'Focus Master',
              'description': 'Complete 30 hours',
              'icon': 'medal',
              'progress': {'current': 28, 'target': 30},
              'unlocked_at': null,
            },
            {
              'id': 'streak-7',
              'title': 'Week Warrior',
              'description': '7-day streak',
              'icon': 'fire',
              'progress': {'current': 5, 'target': 7},
              'unlocked_at': null,
            }
          ]
        };

        final achievements = (json['achievements'] as List<dynamic>)
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList();

        expect(achievements, hasLength(2));
        expect(achievements[0].title, equals('Focus Master'));
        expect(achievements[1].title, equals('Week Warrior'));
      });
    });

    group('Achievement filtering', () {
      test('correctly identifies unlocked achievements', () {
        final unlocked = Achievement(
          id: 'test-1',
          title: 'Test',
          description: 'Test',
          icon: 'star',
          progress: AchievementProgress(current: 10, target: 10),
          unlockedAt: DateTime.now(),
        );

        final locked = Achievement(
          id: 'test-2',
          title: 'Test',
          description: 'Test',
          icon: 'star',
          progress: AchievementProgress(current: 5, target: 10),
          unlockedAt: null,
        );

        expect(unlocked.isUnlocked, isTrue);
        expect(locked.isUnlocked, isFalse);
      });
    });
  });
}
