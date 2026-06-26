import 'package:flutter/material.dart';
import '../core/services/insights_sync_manager.dart';
import '../core/services/insights_service.dart';

/// Controls insights data and sync state.
/// Insights are read-only from client (computed by server).
class InsightsController extends ChangeNotifier {
  final InsightsSyncManager _syncManager = InsightsSyncManager.instance;

  // Current period insights
  DailyInsights? _todayInsights;
  WeeklyInsights? _thisWeekInsights;

  // Cache by date/week
  final Map<String, DailyInsights> _dailyCache = {};
  final Map<String, WeeklyInsights> _weeklyCache = {};

  DailyInsights? get todayInsights => _todayInsights;
  WeeklyInsights? get thisWeekInsights => _thisWeekInsights;

  bool get isSyncing => _syncManager.isSyncing;
  DateTime? get lastSync => _syncManager.lastSuccessfulSync;
  String? get syncError => _syncManager.syncError;

  /// Load insights for today.
  Future<void> loadTodayInsights() async {
    try {
      _todayInsights = await _syncManager.getTodayInsights();
      if (_todayInsights != null) {
        final key = _todayInsights!.date.toIso8601String().split('T').first;
        _dailyCache[key] = _todayInsights!;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load today insights: $e');
      notifyListeners();
    }
  }

  /// Load insights for current week.
  Future<void> loadWeekInsights() async {
    try {
      _thisWeekInsights = await _syncManager.getCurrentWeekInsights();
      if (_thisWeekInsights != null) {
        final key = _thisWeekInsights!.weekStart.toIso8601String().split('T').first;
        _weeklyCache[key] = _thisWeekInsights!;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load week insights: $e');
      notifyListeners();
    }
  }

  /// Load all insights for today and this week.
  Future<void> load() async {
    await Future.wait([
      loadTodayInsights(),
      loadWeekInsights(),
    ]);
  }

  /// Get insights for specific date (cached or from API).
  Future<DailyInsights?> getDateInsights(DateTime date) async {
    try {
      final key = date.toIso8601String().split('T').first;
      if (_dailyCache.containsKey(key)) {
        return _dailyCache[key]!;
      }
      final insights = await _syncManager.getDateInsights(date);
      if (insights != null) {
        _dailyCache[key] = insights;
      }
      return insights;
    } catch (e) {
      debugPrint('Failed to get date insights: $e');
      return null;
    }
  }

  /// Get insights for date range.
  Future<List<DailyInsights>> getRangeInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final insights = await _syncManager.getRangeInsights(
        startDate: startDate,
        endDate: endDate,
      );
      for (final insight in insights) {
        final key = insight.date.toIso8601String().split('T').first;
        _dailyCache[key] = insight;
      }
      return insights;
    } catch (e) {
      debugPrint('Failed to get range insights: $e');
      return [];
    }
  }

  /// Manually sync insights for date range.
  Future<void> syncInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _syncManager.syncInsights(startDate: startDate, endDate: endDate);
      // Reload today and week insights after sync
      await Future.wait([
        loadTodayInsights(),
        loadWeekInsights(),
      ]);
    } catch (e) {
      debugPrint('Failed to sync insights: $e');
      notifyListeners();
    }
  }

  /// Retry sync.
  Future<void> retrySyncInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _syncManager.retrySyncInsights(startDate: startDate, endDate: endDate);
      await Future.wait([
        loadTodayInsights(),
        loadWeekInsights(),
      ]);
    } catch (e) {
      debugPrint('Retry sync failed: $e');
      notifyListeners();
    }
  }

  /// Clear all data (on logout).
  Future<void> clearAll() async {
    _todayInsights = null;
    _thisWeekInsights = null;
    _dailyCache.clear();
    _weeklyCache.clear();
    _syncManager.clearSyncState();
    notifyListeners();
  }
}
