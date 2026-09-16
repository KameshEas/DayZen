/// Manages insights data synchronization (read-only from client).
library;

import 'package:flutter/foundation.dart';
import 'insights_service.dart';
import '../../core/logging/app_logger.dart';

/// Handles insights sync coordination.
/// Insights are computed by server from tasks/journal/etc., so client is read-only.
class InsightsSyncManager extends ChangeNotifier {
  InsightsSyncManager._();

  static final InsightsSyncManager _instance = InsightsSyncManager._();

  static InsightsSyncManager get instance => _instance;

  static final InsightsService _insightsService = InsightsService.instance;

  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;
  String? _syncError;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  String? get syncError => _syncError;

  /// Sync insights data from server (read-only).
  /// Insights are calculated by backend from user's tasks/journal entries.
  Future<Map<String, dynamic>> syncInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (_isSyncing) return {};

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final result = await _insightsService.syncInsights(
        startDate: startDate,
        endDate: endDate,
      );

      _lastSuccessfulSync = DateTime.now();
      _syncError = null;
      AppLogger.debug('Insights sync successful at $_lastSuccessfulSync');

      return result;
    } catch (e) {
      _syncError = e.toString();
      AppLogger.debug('Insights sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Get today's insights (with sync).
  Future<DailyInsights?> getTodayInsights() async {
    try {
      return await _insightsService.getTodayInsights();
    } catch (e) {
      AppLogger.debug('Failed to get today insights: $e');
      return null;
    }
  }

  /// Get current week's insights (with sync).
  Future<WeeklyInsights?> getCurrentWeekInsights() async {
    try {
      return await _insightsService.getCurrentWeekInsights();
    } catch (e) {
      AppLogger.debug('Failed to get week insights: $e');
      return null;
    }
  }

  /// Get insights for specific date.
  Future<DailyInsights?> getDateInsights(DateTime date) async {
    try {
      return await _insightsService.getInsightForDate(date);
    } catch (e) {
      AppLogger.debug('Failed to get date insights: $e');
      return null;
    }
  }

  /// Get insights for date range.
  Future<List<DailyInsights>> getRangeInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _insightsService.getInsightsRange(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      AppLogger.debug('Failed to get range insights: $e');
      return [];
    }
  }

  /// Manual retry sync.
  Future<void> retrySyncInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await syncInsights(startDate: startDate, endDate: endDate);
    } catch (e) {
      AppLogger.debug('Insights sync retry failed: $e');
      rethrow;
    }
  }

  /// Clear sync state (on logout).
  void clearSyncState() {
    _lastSuccessfulSync = null;
    _syncError = null;
    _isSyncing = false;
  }

  /// Get sync status for UI.
  String get syncStatus {
    if (_isSyncing) return 'Syncing insights...';
    if (_syncError != null) return 'Sync error';
    if (_lastSuccessfulSync == null) return 'Never synced';

    final minutesAgo = DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}


