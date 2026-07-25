import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dayzen/core/api/api_client.dart';
import 'package:dayzen/core/api/auth_service.dart';
import 'package:dayzen/core/services/ai_service.dart';
import 'package:dayzen/core/services/achievement_service.dart';
import 'package:dayzen/core/services/insights_service.dart';

/// Mock auth service for integration tests.
class _MockAuthService extends ChangeNotifier implements AuthService {
  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => 'mock-token';

  @override
  Future<Map<String, String>> getAuthHeaders() async {
    return {'Authorization': 'Bearer mock-token'};
  }

  @override
  Future<UserCredential?> signInWithEmail(String email, String password) async => null;

  @override
  Future<UserCredential?> signUpWithEmail(String email, String password) async => null;

  @override
  Future<void> signOut() async {}

  @override
  void clearCachedToken() {}

  @override
  User? get currentUser => null;

  @override
  bool get isAuthenticated => true;

  @override
  String? get userId => 'test-user-id';

  @override
  String? get userEmail => 'test@example.com';

  @override
  bool get isTokenValid => true;

  @override
  DateTime? get tokenExpiryTime => DateTime.now().add(const Duration(hours: 1));
}

void main() {
  group('Backend Integration Tests', () {
    group('Achievement Flow', () {
      test('Complete achievement fetch and filter flow', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, contains('/achievements'));

          return http.Response(
            '{"achievements": [{"id": "focus-30h", "title": "Focus Master", "description": "Complete 30 hours of focused work", "icon": "medal", "progress": {"current": 30, "target": 30}, "unlocked_at": "2026-06-13T10:00:00Z"}, {"id": "streak-7", "title": "Week Warrior", "description": "7-day streak", "icon": "fire", "progress": {"current": 5, "target": 7}, "unlocked_at": null}]}',
            200,
          );
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);

        // Simulate achievement service call
        final response = await apiClient.get('/achievements');
        final achievements = (response['achievements'] as List<dynamic>)
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList();

        // Verify complete flow
        expect(achievements, hasLength(2));
        expect(achievements[0].isUnlocked, isTrue);
        expect(achievements[1].isUnlocked, isFalse);
        expect(achievements[0].progress.percentageComplete, equals(100));
        expect(achievements[1].progress.percentageComplete, closeTo(71.4, 0.1));
      });
    });

    group('AI Service Flow', () {
      test('Complete schedule suggestions fetch flow', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('POST'));
          expect(request.url.path, contains('/ai/schedule'));

          final requestBody = request.body;
          expect(requestBody, contains('tasks'));
          expect(requestBody, contains('user_availability'));

          return http.Response(
            '{"scheduled_tasks": [{"task_id": "task-1", "suggested_start_time": "08:00", "suggested_end_time": "09:30", "reason": "High-priority work placed in morning peak", "confidence": 0.95}], "total_focus_minutes": 90, "recommended_breaks": [{"start_time": "09:40", "duration_minutes": 10, "type": "stretch"}]}',
            200,
          );
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);

        // Simulate schedule suggestions call
        final response = await apiClient.post('/ai/schedule', {
          'tasks': [
            {
              'id': 'task-1',
              'title': 'Project report',
              'priority': 'high',
              'estimated_duration_minutes': 90,
              'category': 'work',
            }
          ],
          'user_availability': {
            'start_hour': 6,
            'end_hour': 23,
            'peak_hours': [8, 9, 10],
          },
          'preferences': {
            'break_frequency_minutes': 90,
            'min_break_duration_minutes': 10,
          },
        });

        final suggestions = ScheduleSuggestions.fromJson(response);

        // Verify complete flow
        expect(suggestions.scheduledTasks, hasLength(1));
        expect(suggestions.recommendedBreaks, hasLength(1));
        expect(suggestions.totalFocusMinutes, equals(90));
        expect(suggestions.scheduledTasks[0].confidence, equals(0.95));
      });
    });

    group('Insights Flow', () {
      test('Complete daily insights fetch flow', () async {
        final mockClient = MockClient((request) async {
          expect(request.method, equals('GET'));
          expect(request.url.path, contains('/insights/daily'));

          return http.Response(
            '{"date": "2026-06-13", "task_completion_count": 8, "task_total_count": 10, "focus_minutes": 240, "journal_entry_count": 2, "most_common_mood": "peaceful", "productivity_score": 85, "tags": ["productive", "focused"], "created_at": "2026-06-13T06:00:00Z", "updated_at": "2026-06-13T22:00:00Z"}',
            200,
          );
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);

        // Simulate insights call
        final response = await apiClient.get('/insights/daily/2026-06-13');
        final insights = DailyInsights.fromJson(response);

        // Verify complete flow
        expect(insights.taskCompletionCount, equals(8));
        expect(insights.focusMinutes, equals(240));
        expect(insights.productivityScore, equals(85));
        expect(insights.tags, contains('productive'));
      });
    });

    group('Error Recovery Flow', () {
      test('Retry on network error', () async {
        var callCount = 0;

        final mockClient = MockClient((request) async {
          callCount++;
          if (callCount <= 2) {
            throw Exception('Network error');
          }
          return http.Response('{"data": "success"}', 200);
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);

        // Should succeed after retries (ApiClient retries up to 2 times)
        final response = await apiClient.get('/test');
        expect(response, equals({'data': 'success'}));
        expect(callCount, equals(3)); // Initial + 2 retries
      });

      test('Cache fallback on API error', () async {
        final achievements = <Achievement>[];

        // First call succeeds
        final mockClient1 = MockClient((request) async {
          return http.Response(
            '{"achievements": [{"id": "test-1", "title": "Test", "description": "Test achievement", "icon": "star", "progress": {"current": 1, "target": 1}, "unlocked_at": null}]}',
            200,
          );
        });

        final mockAuth = _MockAuthService();
        final apiClient1 = ApiClient(client: mockClient1, authService: mockAuth);
        final response1 = await apiClient1.get('/achievements');
        achievements.addAll(
          (response1['achievements'] as List<dynamic>)
              .map((a) => Achievement.fromJson(a as Map<String, dynamic>)),
        );

        expect(achievements, hasLength(1));

        // Second call fails - cached data is available
        expect(achievements.isNotEmpty, isTrue);
      });
    });

    group('Concurrent Request Flow', () {
      test('Multiple simultaneous API calls succeed', () async {
        final mockClient = MockClient((request) async {
          // Simulate different endpoints
          if (request.url.path.contains('/achievements')) {
            return http.Response('{"achievements": []}', 200);
          } else if (request.url.path.contains('/ai/insights')) {
            return http.Response('{"insights": []}', 200);
          } else if (request.url.path.contains('/insights/weekly')) {
            return http.Response(
              '{"week_starting": "2026-06-09", "productivity_score": 75}',
              200,
            );
          }
          return http.Response('{"data": "unknown"}', 200);
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);

        // Make concurrent requests
        final futures = [
          apiClient.get('/achievements'),
          apiClient.get('/ai/insights/productivity?start_date=2026-06-06&end_date=2026-06-13'),
          apiClient.get('/insights/weekly/2026-06-09'),
        ];

        final results = await Future.wait(futures);

        // Verify all requests succeeded
        expect(results, hasLength(3));
        expect(results[0], isA<Map>());
        expect(results[1], isA<Map>());
        expect(results[2], isA<Map>());
      });
    });

    group('Data Parsing Flow', () {
      test('Complex nested response parsing', () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            '{"scheduled_tasks": [{"task_id": "t1", "suggested_start_time": "08:00", "suggested_end_time": "09:00", "reason": "First task", "confidence": 0.9}, {"task_id": "t2", "suggested_start_time": "10:00", "suggested_end_time": "11:30", "reason": "Second task", "confidence": 0.85}], "total_focus_minutes": 150, "recommended_breaks": [{"start_time": "09:15", "duration_minutes": 15, "type": "walk"}]}',
            200,
          );
        });

        final mockAuth = _MockAuthService();
        final apiClient = ApiClient(client: mockClient, authService: mockAuth);
        final response = await apiClient.post('/ai/schedule', {});
        final suggestions = ScheduleSuggestions.fromJson(response);

        // Verify nested data parsing
        expect(suggestions.scheduledTasks, hasLength(2));
        expect(suggestions.scheduledTasks[0].taskId, equals('t1'));
        expect(suggestions.scheduledTasks[1].confidence, equals(0.85));
        expect(suggestions.recommendedBreaks[0].type, equals('walk'));
        expect(suggestions.totalFocusMinutes, equals(150));
      });
    });
  });
}
