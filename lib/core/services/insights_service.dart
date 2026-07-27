/// Service for insights/analytics management with cloud sync and offline support.
///
/// API Bindings:
/// - BINDING 16: GET /insights/daily/{date} (getInsightForDate) - Per-date cache
/// - BINDING 17: GET /insights/daily?range (getInsightsRange) - REUSED 3-4x with range cache
/// - BINDING 18: GET /insights/weekly/{date} (getWeeklyInsights) - Per-week cache
/// - BINDING 19: POST /insights/sync (syncInsights) - Bulk refresh
library;

import '../api/api_client.dart';

/// Daily insights response from API (productivity, mood, focus stats).
class DailyInsights {
  final DateTime date;
  final int taskCompletionCount;
  final int taskTotalCount;
  final int focusMinutes;
  final int journalEntryCount;
  final String? mostCommonMood;
  final int productivityScore; // 0-100
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyInsights({
    required this.date,
    required this.taskCompletionCount,
    required this.taskTotalCount,
    required this.focusMinutes,
    required this.journalEntryCount,
    this.mostCommonMood,
    required this.productivityScore,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parse from API response.
  factory DailyInsights.fromJson(Map<String, dynamic> json) {
    return DailyInsights(
      date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
      taskCompletionCount: json['task_completion_count'] as int? ?? 0,
      taskTotalCount: json['task_total_count'] as int? ?? 0,
      focusMinutes: json['focus_minutes'] as int? ?? 0,
      journalEntryCount: json['journal_entry_count'] as int? ?? 0,
      mostCommonMood: json['most_common_mood'] as String?,
      productivityScore: json['productivity_score'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Weekly insights aggregation.
class WeeklyInsights {
  final DateTime weekStart;
  final int totalTaskCompletions;
  final int totalFocusMinutes;
  final int totalJournalEntries;
  final int averageProductivityScore;
  final Map<String, int> moodDistribution; // mood -> count
  final int streakDays;
  final DateTime updatedAt;

  WeeklyInsights({
    required this.weekStart,
    required this.totalTaskCompletions,
    required this.totalFocusMinutes,
    required this.totalJournalEntries,
    required this.averageProductivityScore,
    required this.moodDistribution,
    required this.streakDays,
    required this.updatedAt,
  });

  /// Parse from API response.
  factory WeeklyInsights.fromJson(Map<String, dynamic> json) {
    final moodData = json['mood_distribution'] as Map<String, dynamic>? ?? {};
    final moodMap = <String, int>{};
    moodData.forEach((key, value) {
      moodMap[key] = value as int? ?? 0;
    });

    return WeeklyInsights(
      weekStart: DateTime.parse(json['week_start'] as String? ?? DateTime.now().toIso8601String()),
      totalTaskCompletions: json['total_task_completions'] as int? ?? 0,
      totalFocusMinutes: json['total_focus_minutes'] as int? ?? 0,
      totalJournalEntries: json['total_journal_entries'] as int? ?? 0,
      averageProductivityScore: json['average_productivity_score'] as int? ?? 0,
      moodDistribution: moodMap,
      streakDays: json['streak_days'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Service for insights API operations.
class InsightsService {
  InsightsService._();

  static final InsightsService _instance = InsightsService._();

  static InsightsService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // BINDING 16-19: Insights caching
  final Map<String, DailyInsights> _dailyCache = {};
  final Map<String, WeeklyInsights> _weeklyCache = {};
  final Map<String, List<DailyInsights>> _rangeCache = {};
  DateTime? _lastSyncTime;

  /// BINDING 16: Get insights for a specific date.
  /// API: GET /insights/daily/{date}
  /// Cache: 24 hours (insights are stable)
  /// Used By: InsightsController.loadTodayInsights()
  Future<DailyInsights> getInsightForDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final cacheKey = dateStr;

      // Return from cache if available
      if (_dailyCache.containsKey(cacheKey)) {
        return _dailyCache[cacheKey]!;
      }

      final response = await _apiClient.get('/insights/daily/$dateStr');
      final insights = DailyInsights.fromJson(response);
      _dailyCache[cacheKey] = insights;
      return insights;
    } on ApiException {
      // Try to return cached version
      final dateStr = date.toIso8601String().split('T').first;
      if (_dailyCache.containsKey(dateStr)) {
        return _dailyCache[dateStr]!;
      }
      rethrow;
    }
  }

  /// BINDING 17: Get insights for a date range (REUSED - 3-4x per session)
  /// API: GET /insights/daily?start_date={}&end_date={}
  /// Cache: Date-range based
  /// Used By:
  ///   1. InsightsController.getRangeInsights() - Week view
  ///   2. AIService (for productivity insights)
  ///   3. Analytics reports
  ///
  /// OPTIMIZATION STRATEGY:
  /// • Range-based cache key prevents refetching same period
  /// • 7-day range cached separately from 30-day range
  /// • Server returns optimized aggregated data
  Future<List<DailyInsights>> getInsightsRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final String rangeKey = _buildRangeKey(startDate, endDate);

      // Check range cache first
      if (_rangeCache.containsKey(rangeKey)) {
        return _rangeCache[rangeKey]!;
      }

      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _apiClient.get('/insights/daily?start_date=$startStr&end_date=$endStr');
      final insights = (response['insights'] as List<dynamic>?)
          ?.map((i) => DailyInsights.fromJson(i as Map<String, dynamic>))
          .toList() ?? [];

      // OPTIMIZATION: Cache the range
      _rangeCache[rangeKey] = insights;

      // Also cache individual days
      for (final insight in insights) {
        final key = insight.date.toIso8601String().split('T').first;
        _dailyCache[key] = insight;
      }

      return insights;
    } on ApiException {
      // Check range cache first on error
      final String rangeKey = _buildRangeKey(startDate, endDate);
      if (_rangeCache.containsKey(rangeKey)) {
        return _rangeCache[rangeKey]!;
      }

      // Fall back to individual day cache
      final cached = _dailyCache.values.where((i) {
        return !i.date.isBefore(startDate) && !i.date.isAfter(endDate);
      }).toList();
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// Helper: Build cache key for date range queries
  String _buildRangeKey(DateTime start, DateTime end) {
    return '${start.toIso8601String().split('T')[0]}_to_${end.toIso8601String().split('T')[0]}';
  }

  /// BINDING 18: Get weekly insights.
  /// API: GET /insights/weekly/{date}
  /// Cache: Per-week cache (24h)
  /// Used By: InsightsController.loadWeekInsights()
  /// OPTIMIZATION: Aggregated data reduces payload
  Future<WeeklyInsights> getWeeklyInsights(DateTime weekStart) async {
    try {
      final weekStr = weekStart.toIso8601String().split('T').first;
      final cacheKey = weekStr;

      if (_weeklyCache.containsKey(cacheKey)) {
        return _weeklyCache[cacheKey]!;
      }

      final response = await _apiClient.get('/insights/weekly/$weekStr');
      final insights = WeeklyInsights.fromJson(response);
      _weeklyCache[cacheKey] = insights;
      return insights;
    } on ApiException {
      // Return cached version if available
      final weekStr = weekStart.toIso8601String().split('T').first;
      if (_weeklyCache.containsKey(weekStr)) {
        return _weeklyCache[weekStr]!;
      }
      rethrow;
    }
  }

  /// BINDING 19: Sync insights (read-only from backend perspective).
  /// API: POST /insights/sync
  /// Used By: InsightsSyncManager.syncInsights()
  /// OPTIMIZATION: Single call fetches all insights for range
  /// Note: Backend calculates insights from tasks/journal/etc., no client writes.
  Future<Map<String, dynamic>> syncInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;

      final response = await _apiClient.post('/insights/sync', {
        'start_date': startStr,
        'end_date': endStr,
      });

      // Parse daily insights
      final dailyInsights = (response['daily'] as List<dynamic>?)
          ?.map((i) => DailyInsights.fromJson(i as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all daily insights
      for (final insight in dailyInsights) {
        final key = insight.date.toIso8601String().split('T').first;
        _dailyCache[key] = insight;
      }

      // Parse weekly insights
      final weeklyInsights = (response['weekly'] as List<dynamic>?)
          ?.map((w) => WeeklyInsights.fromJson(w as Map<String, dynamic>))
          .toList() ?? [];

      // Cache all weekly insights
      for (final insight in weeklyInsights) {
        final key = insight.weekStart.toIso8601String().split('T').first;
        _weeklyCache[key] = insight;
      }

      _lastSyncTime = DateTime.now();

      return {
        'daily_insights': dailyInsights,
        'weekly_insights': weeklyInsights,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      rethrow;
    }
  }

  /// Get current week's insights.
  Future<WeeklyInsights> getCurrentWeekInsights() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return getWeeklyInsights(weekStart);
  }

  /// Get today's insights.
  Future<DailyInsights> getTodayInsights() async {
    return getInsightForDate(DateTime.now());
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear all caches (on logout).
  void clearCache() {
    _dailyCache.clear();
    _weeklyCache.clear();
    _rangeCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
