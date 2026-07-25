import 'package:flutter/material.dart';
import '../core/services/ai_optimization_manager.dart';
import '../core/services/ai_service.dart';
import '../../core/logging/app_logger.dart';

/// Controls AI optimization features.
class AIOptimizationController extends ChangeNotifier {
  final AIOPtimizationManager _manager = AIOPtimizationManager.instance;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;
  bool get isSyncing => _manager.isSyncing;
  String? get syncError => _manager.syncError;

  List<TaskRecommendation>? get recommendations => _manager.recommendations;
  List<ScheduleOptimization>? get optimizations => _manager.optimizations;
  List<ProductivityInsight>? get insights => _manager.insights;
  List<SmartReminder>? get reminders => _manager.reminders;

  /// Load AI data for today.
  Future<void> load() async {
    await loadForDate(DateTime.now());
  }

  /// Load AI data for specific date.
  Future<void> loadForDate(DateTime date) async {
    _selectedDate = date;
    await Future.wait([
      _getRecommendations(date),
      _getOptimizations(date),
      _getReminders(date),
    ]);
  }

  /// Get insights for date range.
  Future<void> loadInsights({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      await _manager.getInsights(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Failed to load insights: $e');
      notifyListeners();
    }
  }

  /// Get recommendations for date.
  Future<void> _getRecommendations(DateTime date) async {
    try {
      await _manager.getRecommendations(date: date);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Failed to get recommendations: $e');
      notifyListeners();
    }
  }

  /// Get optimizations for date.
  Future<void> _getOptimizations(DateTime date) async {
    try {
      await _manager.getOptimizations(date: date);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Failed to get optimizations: $e');
      notifyListeners();
    }
  }

  /// Get reminders for date.
  Future<void> _getReminders(DateTime date) async {
    try {
      await _manager.getReminders(date: date);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Failed to get reminders: $e');
      notifyListeners();
    }
  }

  /// Sync all AI data.
  Future<void> syncAI({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();
      await _manager.syncAIData(startDate: start, endDate: end);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Failed to sync AI data: $e');
      notifyListeners();
    }
  }

  /// Retry sync.
  Future<void> retrySyncAI({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
      final end = endDate ?? DateTime.now();
      await _manager.retrySyncAI(startDate: start, endDate: end);
      notifyListeners();
    } catch (e) {
      AppLogger.debug('Retry sync failed: $e');
      notifyListeners();
    }
  }

  /// Clear all data (on logout).
  Future<void> clearAll() async {
    _manager.clearAll();
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  /// Get analysis status.
  String get analysisStatus => _manager.syncStatus;
}


