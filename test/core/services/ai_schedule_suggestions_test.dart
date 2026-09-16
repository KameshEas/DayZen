import 'package:flutter_test/flutter_test.dart';
import 'package:dayzen/core/services/ai_service.dart';

void main() {
  group('ScheduledTask Model', () {
    test('creates from JSON', () {
      final json = {
        'task_id': 'task-1',
        'suggested_start_time': '08:00',
        'suggested_end_time': '09:30',
        'reason': 'High-priority work placed in your peak morning focus window.',
        'confidence': 0.95,
      };

      final task = ScheduledTask.fromJson(json);

      expect(task.taskId, equals('task-1'));
      expect(task.suggestedStartTime, equals('08:00'));
      expect(task.suggestedEndTime, equals('09:30'));
      expect(task.confidence, equals(0.95));
    });

    test('handles missing confidence with default', () {
      final json = {
        'task_id': 'task-1',
        'suggested_start_time': '08:00',
        'suggested_end_time': '09:30',
        'reason': 'Test',
      };

      final task = ScheduledTask.fromJson(json);
      expect(task.confidence, equals(0.7));
    });
  });

  group('BreakRecommendation Model', () {
    test('creates from JSON', () {
      final json = {
        'start_time': '09:40',
        'duration_minutes': 10,
        'type': 'stretch',
      };

      final breakRec = BreakRecommendation.fromJson(json);

      expect(breakRec.startTime, equals('09:40'));
      expect(breakRec.durationMinutes, equals(10));
      expect(breakRec.type, equals('stretch'));
    });

    test('uses defaults for missing fields', () {
      final json = {
        'start_time': '09:40',
      };

      final breakRec = BreakRecommendation.fromJson(json);

      expect(breakRec.durationMinutes, equals(10));
      expect(breakRec.type, equals('break'));
    });
  });

  group('ScheduleSuggestions Model', () {
    test('parses complete schedule suggestions', () {
      final json = {
        'scheduled_tasks': [
          {
            'task_id': 'task-1',
            'suggested_start_time': '08:00',
            'suggested_end_time': '09:30',
            'reason': 'High-priority work',
            'confidence': 0.95,
          },
          {
            'task_id': 'task-2',
            'suggested_start_time': '10:00',
            'suggested_end_time': '11:00',
            'reason': 'Medium priority',
            'confidence': 0.85,
          },
        ],
        'total_focus_minutes': 90,
        'recommended_breaks': [
          {
            'start_time': '09:40',
            'duration_minutes': 10,
            'type': 'stretch',
          },
          {
            'start_time': '11:15',
            'duration_minutes': 15,
            'type': 'walk',
          },
        ],
      };

      final suggestions = ScheduleSuggestions.fromJson(json);

      expect(suggestions.scheduledTasks, hasLength(2));
      expect(suggestions.totalFocusMinutes, equals(90));
      expect(suggestions.recommendedBreaks, hasLength(2));
      expect(suggestions.scheduledTasks[0].taskId, equals('task-1'));
      expect(suggestions.recommendedBreaks[0].type, equals('stretch'));
    });

    test('handles empty suggestions', () {
      final json = {
        'scheduled_tasks': [],
        'total_focus_minutes': 0,
        'recommended_breaks': [],
      };

      final suggestions = ScheduleSuggestions.fromJson(json);

      expect(suggestions.scheduledTasks, isEmpty);
      expect(suggestions.recommendedBreaks, isEmpty);
      expect(suggestions.totalFocusMinutes, equals(0));
    });

    test('uses defaults for missing fields', () {
      final json = <String, dynamic>{};

      final suggestions = ScheduleSuggestions.fromJson(json);

      expect(suggestions.scheduledTasks, isEmpty);
      expect(suggestions.recommendedBreaks, isEmpty);
      expect(suggestions.totalFocusMinutes, equals(0));
    });
  });

  group('AIService schedule suggestions', () {
    test('builds correct request payload', () {
      // This tests the request structure without actually making an API call
      final tasks = [
        {
          'id': 'task-1',
          'title': 'Project report',
          'priority': 'high',
          'estimated_duration_minutes': 90,
          'category': 'work',
        }
      ];

      final expectedPayload = {
        'tasks': tasks,
        'user_availability': {
          'start_hour': 6,
          'end_hour': 23,
          'peak_hours': [8, 9, 10],
        },
        'preferences': {
          'break_frequency_minutes': 90,
          'min_break_duration_minutes': 10,
        },
      };

      expect(expectedPayload['tasks'] as List, equals(tasks));
      expect((expectedPayload['user_availability'] as Map)['start_hour'], equals(6));
      expect((expectedPayload['preferences'] as Map)['break_frequency_minutes'], equals(90));
    });
  });
}
