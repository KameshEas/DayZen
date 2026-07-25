/// Service for AI-powered optimization, recommendations, and insights.
///
/// API Bindings:
/// - BINDING 20: GET /ai/recommendations/tasks (getTaskRecommendations) - Per-date cache
/// - BINDING 21: GET /ai/optimization/schedule (getScheduleOptimizations) - Per-date cache
/// - BINDING 22: GET /ai/insights/productivity (getProductivityInsights) - REUSED 3x with range cache
/// - BINDING 23: GET /ai/reminders/smart (getSmartReminders) - Per-date cache
/// - BINDING 24: POST /ai/sync (syncAIData) - Bulk refresh
/// - BINDING 25: POST /ai/schedule (getScheduleSuggestions) - Task scheduling with availability
library;

import '../api/api_client.dart';

/// Task recommendation from AI.
class TaskRecommendation {
  final String id;
  final String title;
  final String reason;
  final int priorityScore; // 0-100
  final DateTime suggestedDate;
  final int suggestedStartHour;
  final int suggestedStartMinute;
  final String category;
  final double confidenceScore; // 0-1.0

  TaskRecommendation({
    required this.id,
    required this.title,
    required this.reason,
    required this.priorityScore,
    required this.suggestedDate,
    required this.suggestedStartHour,
    required this.suggestedStartMinute,
    required this.category,
    required this.confidenceScore,
  });

  factory TaskRecommendation.fromJson(Map<String, dynamic> json) {
    return TaskRecommendation(
      id: json['id'] as String,
      title: json['title'] as String,
      reason: json['reason'] as String,
      priorityScore: json['priority_score'] as int? ?? 50,
      suggestedDate: DateTime.parse(json['suggested_date'] as String),
      suggestedStartHour: json['suggested_start_hour'] as int? ?? 9,
      suggestedStartMinute: json['suggested_start_minute'] as int? ?? 0,
      category: json['category'] as String? ?? 'work',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.7,
    );
  }
}

/// Schedule optimization suggestion.
class ScheduleOptimization {
  final String taskId;
  final String taskTitle;
  final int currentStartHour;
  final int currentStartMinute;
  final int recommendedStartHour;
  final int recommendedStartMinute;
  final String reason;
  final double confidenceScore; // 0-1.0

  ScheduleOptimization({
    required this.taskId,
    required this.taskTitle,
    required this.currentStartHour,
    required this.currentStartMinute,
    required this.recommendedStartHour,
    required this.recommendedStartMinute,
    required this.reason,
    required this.confidenceScore,
  });

  factory ScheduleOptimization.fromJson(Map<String, dynamic> json) {
    return ScheduleOptimization(
      taskId: json['task_id'] as String,
      taskTitle: json['task_title'] as String,
      currentStartHour: json['current_start_hour'] as int,
      currentStartMinute: json['current_start_minute'] as int,
      recommendedStartHour: json['recommended_start_hour'] as int,
      recommendedStartMinute: json['recommended_start_minute'] as int,
      reason: json['reason'] as String,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.7,
    );
  }
}

/// AI-generated productivity insight.
class ProductivityInsight {
  final String title;
  final String description;
  final String category; // habit, timing, focus, etc.
  final String? actionableAdvice;
  final int impactScore; // 1-10

  ProductivityInsight({
    required this.title,
    required this.description,
    required this.category,
    this.actionableAdvice,
    required this.impactScore,
  });

  factory ProductivityInsight.fromJson(Map<String, dynamic> json) {
    return ProductivityInsight(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'general',
      actionableAdvice: json['actionable_advice'] as String?,
      impactScore: json['impact_score'] as int? ?? 5,
    );
  }
}

/// Smart reminder suggestion.
class SmartReminder {
  final String id;
  final String taskId;
  final String taskTitle;
  final DateTime reminderTime;
  final String reminderType; // before_deadline, optimal_time, focus_block, etc.
  final String message;
  final double confidenceScore;

  SmartReminder({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.reminderTime,
    required this.reminderType,
    required this.message,
    required this.confidenceScore,
  });

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      taskTitle: json['task_title'] as String,
      reminderTime: DateTime.parse(json['reminder_time'] as String),
      reminderType: json['reminder_type'] as String,
      message: json['message'] as String,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.7,
    );
  }
}

/// Scheduled task suggestion (part of schedule suggestions).
class ScheduledTask {
  final String taskId;
  final String suggestedStartTime; // HH:MM format
  final String suggestedEndTime; // HH:MM format
  final String reason;
  final double confidence; // 0-1.0

  ScheduledTask({
    required this.taskId,
    required this.suggestedStartTime,
    required this.suggestedEndTime,
    required this.reason,
    required this.confidence,
  });

  factory ScheduledTask.fromJson(Map<String, dynamic> json) {
    return ScheduledTask(
      taskId: json['task_id'] as String,
      suggestedStartTime: json['suggested_start_time'] as String,
      suggestedEndTime: json['suggested_end_time'] as String,
      reason: json['reason'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }
}

/// Break recommendation (part of schedule suggestions).
class BreakRecommendation {
  final String startTime; // HH:MM format
  final int durationMinutes;
  final String type; // stretch, walk, meditate, etc.

  BreakRecommendation({
    required this.startTime,
    required this.durationMinutes,
    required this.type,
  });

  factory BreakRecommendation.fromJson(Map<String, dynamic> json) {
    return BreakRecommendation(
      startTime: json['start_time'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 10,
      type: json['type'] as String? ?? 'break',
    );
  }
}

/// Complete schedule suggestions with tasks and breaks.
class ScheduleSuggestions {
  final List<ScheduledTask> scheduledTasks;
  final int totalFocusMinutes;
  final List<BreakRecommendation> recommendedBreaks;

  ScheduleSuggestions({
    required this.scheduledTasks,
    required this.totalFocusMinutes,
    required this.recommendedBreaks,
  });

  factory ScheduleSuggestions.fromJson(Map<String, dynamic> json) {
    return ScheduleSuggestions(
      scheduledTasks: (json['scheduled_tasks'] as List<dynamic>?)
          ?.map((t) => ScheduledTask.fromJson(t as Map<String, dynamic>))
          .toList() ?? [],
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
      recommendedBreaks: (json['recommended_breaks'] as List<dynamic>?)
          ?.map((b) => BreakRecommendation.fromJson(b as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Service for AI operations.
class AIService {
  AIService._();

  static final AIService _instance = AIService._();

  static AIService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // Cache
  final Map<String, List<TaskRecommendation>> _recommendationCache = {};
  final Map<String, List<ScheduleOptimization>> _optimizationCache = {};
  final Map<String, List<ProductivityInsight>> _insightCache = {};
  final Map<String, List<SmartReminder>> _reminderCache = {};
  DateTime? _lastSyncTime;

  /// BINDING 20: Get AI task recommendations for date.
  /// API: GET /ai/recommendations/tasks?date={}
  /// Cache: Per-date (24h)
  /// Used By: AIOptimizationController.getRecommendations()
  Future<List<TaskRecommendation>> getTaskRecommendations({
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'recommendations_$dateStr';

      // Return from cache if available
      if (_recommendationCache.containsKey(cacheKey)) {
        return _recommendationCache[cacheKey]!;
      }

      final response = await _apiClient.get('/ai/recommendations/tasks?date=$dateStr');
      final recommendations = (response['recommendations'] as List<dynamic>?)
          ?.map((r) => TaskRecommendation.fromJson(r as Map<String, dynamic>))
          .toList() ?? [];

      _recommendationCache[cacheKey] = recommendations;
      return recommendations;
    } on ApiException {
      // Return cached if available
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'recommendations_$dateStr';
      if (_recommendationCache.containsKey(cacheKey)) {
        return _recommendationCache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// BINDING 21: Get schedule optimization suggestions.
  /// API: GET /ai/optimization/schedule?date={}
  /// Cache: Per-date (24h)
  /// Used By: AIOptimizationController.getOptimizations()
  Future<List<ScheduleOptimization>> getScheduleOptimizations({
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'optimizations_$dateStr';

      if (_optimizationCache.containsKey(cacheKey)) {
        return _optimizationCache[cacheKey]!;
      }

      final response = await _apiClient.get('/ai/optimization/schedule?date=$dateStr');
      final optimizations = (response['optimizations'] as List<dynamic>?)
          ?.map((o) => ScheduleOptimization.fromJson(o as Map<String, dynamic>))
          .toList() ?? [];

      _optimizationCache[cacheKey] = optimizations;
      return optimizations;
    } on ApiException {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'optimizations_$dateStr';
      if (_optimizationCache.containsKey(cacheKey)) {
        return _optimizationCache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// BINDING 22: Get productivity insights (REUSED - 3x per session)
  /// API: GET /ai/insights/productivity?start_date={}&end_date={}
  /// Cache: Date-range based
  /// Used By:
  ///   1. AIOptimizationController.getInsights() - AI insights view
  ///   2. InsightsPage (productivity recommendations)
  ///   3. Dashboard (summary insights)
  ///
  /// OPTIMIZATION: Cache by date range to prevent refetching
  Future<List<ProductivityInsight>> getProductivityInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();
      final startStr = start.toIso8601String().split('T').first;
      final endStr = end.toIso8601String().split('T').first;
      final cacheKey = 'insights_${startStr}_$endStr';

      if (_insightCache.containsKey(cacheKey)) {
        return _insightCache[cacheKey]!;
      }

      final response = await _apiClient.get(
        '/ai/insights/productivity?start_date=$startStr&end_date=$endStr',
      );
      final insights = (response['insights'] as List<dynamic>?)
          ?.map((i) => ProductivityInsight.fromJson(i as Map<String, dynamic>))
          .toList() ?? [];

      _insightCache[cacheKey] = insights;
      return insights;
    } on ApiException {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();
      final startStr = start.toIso8601String().split('T').first;
      final endStr = end.toIso8601String().split('T').first;
      final cacheKey = 'insights_${startStr}_$endStr';
      if (_insightCache.containsKey(cacheKey)) {
        return _insightCache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// BINDING 23: Get smart reminder suggestions.
  /// API: GET /ai/reminders/smart?date={}
  /// Cache: Per-date (24h)
  /// Used By: AIOptimizationController.getReminders()
  Future<List<SmartReminder>> getSmartReminders({
    required DateTime date,
  }) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'reminders_$dateStr';

      if (_reminderCache.containsKey(cacheKey)) {
        return _reminderCache[cacheKey]!;
      }

      final response = await _apiClient.get('/ai/reminders/smart?date=$dateStr');
      final reminders = (response['reminders'] as List<dynamic>?)
          ?.map((r) => SmartReminder.fromJson(r as Map<String, dynamic>))
          .toList() ?? [];

      _reminderCache[cacheKey] = reminders;
      return reminders;
    } on ApiException {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = 'reminders_$dateStr';
      if (_reminderCache.containsKey(cacheKey)) {
        return _reminderCache[cacheKey]!;
      }
      rethrow;
    }
  }

  /// BINDING 24: Sync all AI data for date range.
  /// API: POST /ai/sync
  /// Used By: AIOPtimizationManager.syncAIData()
  /// OPTIMIZATION: Single call fetches all AI features
  Future<Map<String, dynamic>> syncAIData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _apiClient.post('/ai/sync', {
        'start_date': startStr,
        'end_date': endStr,
      });

      // Parse recommendations
      final recommendations = (response['recommendations'] as List<dynamic>?)
          ?.map((r) => TaskRecommendation.fromJson(r as Map<String, dynamic>))
          .toList() ?? [];

      // Parse optimizations
      final optimizations = (response['optimizations'] as List<dynamic>?)
          ?.map((o) => ScheduleOptimization.fromJson(o as Map<String, dynamic>))
          .toList() ?? [];

      // Parse insights
      final insights = (response['insights'] as List<dynamic>?)
          ?.map((i) => ProductivityInsight.fromJson(i as Map<String, dynamic>))
          .toList() ?? [];

      // Parse reminders
      final reminders = (response['reminders'] as List<dynamic>?)
          ?.map((r) => SmartReminder.fromJson(r as Map<String, dynamic>))
          .toList() ?? [];

      _lastSyncTime = DateTime.now();

      return {
        'recommendations': recommendations,
        'optimizations': optimizations,
        'insights': insights,
        'reminders': reminders,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 25: Get task scheduling suggestions based on availability.
  /// API: POST /ai/schedule
  /// Request includes: tasks list, user availability (hours, peak hours), break preferences
  /// Response: Scheduled tasks with times + recommended breaks
  /// Used By: Planner/Schedule optimization features
  Future<ScheduleSuggestions> getScheduleSuggestions({
    required List<Map<String, dynamic>> tasks,
    required int startHour,
    required int endHour,
    List<int>? peakHours,
    int breakFrequencyMinutes = 90,
    int minBreakDurationMinutes = 10,
  }) async {
    try {
      final request = {
        'tasks': tasks,
        'user_availability': {
          'start_hour': startHour,
          'end_hour': endHour,
          if (peakHours != null) 'peak_hours': peakHours,
        },
        'preferences': {
          'break_frequency_minutes': breakFrequencyMinutes,
          'min_break_duration_minutes': minBreakDurationMinutes,
        },
      };

      final response = await _apiClient.post('/ai/schedule', request);
      return ScheduleSuggestions.fromJson(response);
    } on ApiException {
      rethrow;
    }
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear cache (on logout).
  void clearCache() {
    _recommendationCache.clear();
    _optimizationCache.clear();
    _insightCache.clear();
    _reminderCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
