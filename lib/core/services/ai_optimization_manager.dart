/// Manages AI optimization features and recommendations.
library;

import 'package:flutter/foundation.dart';
import 'ai_service.dart';
import 'achievement_service.dart';
import '../../core/logging/app_logger.dart';

/// Handles AI-powered optimization coordination.
class AIOPtimizationManager extends ChangeNotifier {
  AIOPtimizationManager._();

  static final AIOPtimizationManager _instance = AIOPtimizationManager._();

  static AIOPtimizationManager get instance => _instance;

  static final AIService _aiService = AIService.instance;
  static final AchievementService _achievementService = AchievementService.instance;

  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;
  String? _syncError;

  // Cached data
  List<TaskRecommendation>? _recommendations;
  List<ScheduleOptimization>? _optimizations;
  List<ProductivityInsight>? _insights;
  List<SmartReminder>? _reminders;
  List<Achievement>? _achievements;
  ScheduleSuggestions? _scheduleSuggestions;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  String? get syncError => _syncError;

  List<TaskRecommendation>? get recommendations => _recommendations;
  List<ScheduleOptimization>? get optimizations => _optimizations;
  List<ProductivityInsight>? get insights => _insights;
  List<SmartReminder>? get reminders => _reminders;
  List<Achievement>? get achievements => _achievements;
  ScheduleSuggestions? get scheduleSuggestions => _scheduleSuggestions;

  /// Sync all AI data.
  Future<void> syncAIData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_isSyncing) return;

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final result = await _aiService.syncAIData(
        startDate: startDate,
        endDate: endDate,
      );

      _recommendations = result['recommendations'] as List<TaskRecommendation>;
      _optimizations = result['optimizations'] as List<ScheduleOptimization>;
      _insights = result['insights'] as List<ProductivityInsight>;
      _reminders = result['reminders'] as List<SmartReminder>;

      _lastSuccessfulSync = DateTime.now();
      _syncError = null;
      AppLogger.debug('AI optimization sync successful at $_lastSuccessfulSync');
    } catch (e) {
      _syncError = e.toString();
      AppLogger.debug('AI optimization sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get recommendations for date.
  Future<List<TaskRecommendation>> getRecommendations({
    required DateTime date,
  }) async {
    try {
      final recommendations = await _aiService.getTaskRecommendations(date: date);
      _recommendations = recommendations;
      notifyListeners();
      return recommendations;
    } catch (e) {
      AppLogger.debug('Failed to get recommendations: $e');
      return [];
    }
  }

  /// Get schedule optimizations for date.
  Future<List<ScheduleOptimization>> getOptimizations({
    required DateTime date,
  }) async {
    try {
      final optimizations = await _aiService.getScheduleOptimizations(date: date);
      _optimizations = optimizations;
      notifyListeners();
      return optimizations;
    } catch (e) {
      AppLogger.debug('Failed to get optimizations: $e');
      return [];
    }
  }

  /// Get productivity insights.
  Future<List<ProductivityInsight>> getInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final insights = await _aiService.getProductivityInsights(
        startDate: startDate,
        endDate: endDate,
      );
      _insights = insights;
      notifyListeners();
      return insights;
    } catch (e) {
      AppLogger.debug('Failed to get insights: $e');
      return [];
    }
  }

  /// Get smart reminders for date.
  Future<List<SmartReminder>> getReminders({
    required DateTime date,
  }) async {
    try {
      final reminders = await _aiService.getSmartReminders(date: date);
      _reminders = reminders;
      notifyListeners();
      return reminders;
    } catch (e) {
      AppLogger.debug('Failed to get reminders: $e');
      return [];
    }
  }

  /// Get all achievements for current user.
  Future<List<Achievement>> getAchievements({
    bool forceRefresh = false,
  }) async {
    try {
      final achievements = await _achievementService.getAchievements(forceRefresh: forceRefresh);
      _achievements = achievements;
      notifyListeners();
      return achievements;
    } catch (e) {
      AppLogger.debug('Failed to get achievements: $e');
      return [];
    }
  }

  /// Get schedule suggestions based on tasks and availability.
  Future<ScheduleSuggestions> getScheduleSuggestions({
    required List<Map<String, dynamic>> tasks,
    required int startHour,
    required int endHour,
    List<int>? peakHours,
    int breakFrequencyMinutes = 90,
    int minBreakDurationMinutes = 10,
  }) async {
    try {
      final suggestions = await _aiService.getScheduleSuggestions(
        tasks: tasks,
        startHour: startHour,
        endHour: endHour,
        peakHours: peakHours,
        breakFrequencyMinutes: breakFrequencyMinutes,
        minBreakDurationMinutes: minBreakDurationMinutes,
      );
      _scheduleSuggestions = suggestions;
      notifyListeners();
      return suggestions;
    } catch (e) {
      AppLogger.debug('Failed to get schedule suggestions: $e');
      rethrow;
    }
  }

  /// Manual retry sync.
  Future<void> retrySyncAI({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await syncAIData(startDate: startDate, endDate: endDate);
    } catch (e) {
      AppLogger.debug('AI sync retry failed: $e');
      rethrow;
    }
  }

  /// Clear all data (on logout).
  void clearAll() {
    _recommendations = null;
    _optimizations = null;
    _insights = null;
    _reminders = null;
    _achievements = null;
    _scheduleSuggestions = null;
    _lastSuccessfulSync = null;
    _syncError = null;
    _isSyncing = false;
  }

  /// Get sync status for UI.
  String get syncStatus {
    if (_isSyncing) return 'Analyzing...';
    if (_syncError != null) return 'Analysis error';
    if (_lastSuccessfulSync == null) return 'No analysis yet';

    final minutesAgo = DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}


