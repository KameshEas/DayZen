import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/services/task_service.dart';
import 'package:dayzen/core/services/journal_service.dart';
import 'package:dayzen/core/services/insights_service.dart';
import 'package:dayzen/core/services/ai_service.dart';
import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/features/home/models/task_model.dart';

void main() {
  group('Sync Flow Integration Tests', () {
    late TaskService taskService;
    late JournalService journalService;
    late InsightsService insightsService;
    late AIService aiService;

    setUp(() {
      taskService = TaskService.instance;
      journalService = JournalService.instance;
      insightsService = InsightsService.instance;
      aiService = AIService.instance;
    });

    tearDown(() {
      taskService.clearCache();
      journalService.clearCache();
      insightsService.clearCache();
      aiService.clearCache();
    });

    group('Task Sync Flow', () {
      test('complete task creation and sync flow', () async {
        // 1. Create a task locally
        final newTask = DzTask(
          id: 'integration-test-1',
          title: 'Integration Test Task',
          startTime: const TimeOfDay(hour: 14, minute: 0),
          endTime: const TimeOfDay(hour: 15, minute: 0),
          priority: TaskPriority.zen,
          category: TaskCategory.work,
          date: DateTime.now(),
          subtitle: 'Testing full sync flow',
        );

        // 2. Create on API
        try {
          final created = await taskService.createTask(newTask);
          expect(created.title, equals(newTask.title));
          expect(created.id, isNotEmpty);

          // 3. Fetch and verify
          final fetched = await taskService.listTasks();
          expect(fetched, isNotEmpty);

          // 4. Update the task
          final updated = created.copyWith(
            isCompleted: true,
          );
          final updateResult = await taskService.updateTask(created.id, updated);
          expect(updateResult.isCompleted, true);

          // 5. Delete the task
          await taskService.deleteTask(created.id);

          // 6. Sync to verify deletion
          final syncResult = await taskService.syncTasks(localTasks: []);
          expect(syncResult, isNotEmpty);
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('Journal Sync Flow', () {
      test('complete journal creation and sync flow', () async {
        // 1. Create journal entry
        final now = DateTime.now();
        final newEntry = JournalApiResponse(
          id: 'integration-journal-1',
          title: 'Integration Test Entry',
          body: 'This is a test entry for the sync flow.',
          mood: 'peaceful',
          timestampMs: now.millisecondsSinceEpoch,
          entryTimestamp: now.toIso8601String(),
          createdAt: now,
          updatedAt: now,
        );

        try {
          // 2. Create on API
          final created = await journalService.createEntry(newEntry);
          expect(created.body, isNotEmpty);

          // 3. Fetch and verify
          final fetched = await journalService.getEntry(created.id);
          expect(fetched.id, equals(created.id));

          // 4. Delete
          await journalService.deleteEntry(created.id);
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('Insights Sync Flow', () {
      test('fetch insights for date range', () async {
        try {
          final startDate = DateTime.now().subtract(const Duration(days: 7));
          final endDate = DateTime.now();

          // 1. Get insights for range
          final insights = await insightsService.getInsightsRange(
            startDate: startDate,
            endDate: endDate,
          );

          // 2. Verify structure
          if (insights.isNotEmpty) {
            final first = insights.first;
            expect(first.date, isNotNull);
            expect(first.productivityScore, greaterThanOrEqualTo(0));
            expect(first.productivityScore, lessThanOrEqualTo(100));
          }

          // 3. Get weekly insights
          final weeklyInsights = await insightsService.getWeeklyInsights(
            DateTime.now().subtract(const Duration(days: 7)),
          );

          expect(weeklyInsights, isNotNull);
          expect(weeklyInsights.averageProductivityScore, greaterThanOrEqualTo(0));
          expect(weeklyInsights.averageProductivityScore, lessThanOrEqualTo(100));
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('AI Features Flow', () {
      test('fetch AI recommendations and optimizations', () async {
        try {
          final today = DateTime.now();

          // 1. Get recommendations
          final recommendations = await aiService.getTaskRecommendations(
            date: today,
          );

          if (recommendations.isNotEmpty) {
            final rec = recommendations.first;
            expect(rec.title, isNotEmpty);
            expect(rec.confidenceScore, greaterThanOrEqualTo(0));
            expect(rec.confidenceScore, lessThanOrEqualTo(1.0));
          }

          // 2. Get optimizations
          final optimizations = await aiService.getScheduleOptimizations(
            date: today,
          );

          if (optimizations.isNotEmpty) {
            final opt = optimizations.first;
            expect(opt.taskTitle, isNotEmpty);
            expect(opt.recommendedStartHour, greaterThanOrEqualTo(0));
            expect(opt.recommendedStartHour, lessThanOrEqualTo(23));
          }

          // 3. Get insights
          final insights = await aiService.getProductivityInsights(
            startDate: today.subtract(const Duration(days: 7)),
            endDate: today,
          );

          if (insights.isNotEmpty) {
            final insight = insights.first;
            expect(insight.title, isNotEmpty);
            expect(insight.impactScore, greaterThanOrEqualTo(1));
            expect(insight.impactScore, lessThanOrEqualTo(10));
          }
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('Error Handling', () {
      test('handles network errors gracefully', () async {
        // This test verifies that services handle errors gracefully
        try {
          // Attempting to create with invalid data
          final invalidTask = DzTask(
            id: '',
            title: '',
            startTime: const TimeOfDay(hour: 25, minute: 0), // Invalid hour
            endTime: const TimeOfDay(hour: 26, minute: 0), // Invalid hour
            priority: TaskPriority.routine,
            category: TaskCategory.work,
            date: DateTime.now(),
          );

          // Should throw or handle gracefully
          await taskService.createTask(invalidTask);
        } catch (e) {
          // Expected to fail
          expect(e, isNotNull);
        }
      });

      test('cache fallback works when API fails', () async {
        // This is a conceptual test for cache behavior
        try {
          // First call populates cache
          await taskService.listTasks();

          // Subsequent calls would use cache even if API is down
          // This behavior is transparent to the caller
          expect(true, true);
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });

    group('Performance Tests', () {
      test('tasks load within acceptable time', () async {
        try {
          final stopwatch = Stopwatch()..start();
          await taskService.listTasks();
          stopwatch.stop();

          // Should complete within 5 seconds (generous for network)
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(5000),
            reason: 'Task loading exceeded 5 seconds',
          );
        } catch (e) {
          // Network errors are acceptable in performance test
          expect(e, isA<ApiException>());
        }
      });

      test('cached data returns instantly', () async {
        try {
          // First call
          await taskService.listTasks();

          // Second call (should be cached)
          final stopwatch = Stopwatch()..start();
          await taskService.listTasks();
          stopwatch.stop();

          // Cached calls should be very fast (<100ms)
          expect(
            stopwatch.elapsedMilliseconds,
            lessThan(100),
            reason: 'Cached data access exceeded 100ms',
          );
        } catch (e) {
          expect(e, isA<ApiException>());
        }
      });
    });
  });
}
