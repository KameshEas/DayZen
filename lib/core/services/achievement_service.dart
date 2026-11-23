/// Gentle milestones (plan M-1.13), computed on the device.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/models/task_model.dart';
import '../api/api_client.dart';
import '../data/checkin_repository.dart';
import '../data/day_close_repository.dart';
import '../data/journal_repository.dart';
import '../data/task_repository.dart';
import '../domain/gentle_milestones.dart';
import '../logging/app_logger.dart';

/// Individual achievement with progress tracking.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementProgress progress;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.progress,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory Achievement.fromJson(Map<String, dynamic> json) {
    try {
      final progressData = json['progress'] as Map<String, dynamic>?;
      return Achievement(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Achievement',
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '🏆',
        progress: progressData != null ? AchievementProgress.fromJson(progressData) : AchievementProgress(current: 0, target: 1),
        unlockedAt: json['unlocked_at'] != null && (json['unlocked_at'] as String?)?.isNotEmpty == true
            ? DateTime.parse(json['unlocked_at'] as String? ?? DateTime.now().toIso8601String())
            : null,
      );
    } catch (e) {
      return Achievement(
        id: json['id'] as String? ?? '',
        title: 'Error loading achievement',
        description: 'Failed to parse achievement data',
        icon: '❌',
        progress: AchievementProgress(current: 0, target: 1),
        unlockedAt: null,
      );
    }
  }
}

/// Progress tracking for an achievement.
class AchievementProgress {
  final int current;
  final int target;

  AchievementProgress({
    required this.current,
    required this.target,
  });

  double get percentageComplete => target > 0 ? (current / target * 100).clamp(0, 100) : 0;

  bool get isComplete => current >= target;

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      current: json['current'] as int? ?? 0,
      target: json['target'] as int? ?? 1,
    );
  }
}

/// Achievement service for fetching gamification data.
class AchievementService {
  AchievementService._();

  static final AchievementService _instance = AchievementService._();

  static AchievementService get instance => _instance;

  static const _unlockedKey = 'milestones_unlocked_at';

  /// Every gentle milestone with its progress. Computed from local data (the
  /// DayZen API has no achievements endpoint). A milestone, once reached,
  /// stays reached: its unlock time is saved, so deleting tasks later never
  /// takes it away. [stats] is a test seam.
  Future<List<Achievement>> getAchievements({
    bool forceRefresh = false,
    MilestoneStats? stats,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final s = stats ?? await _collectStats();
    final prefs = await SharedPreferences.getInstance();
    final unlocked = <String, String>{
      ...((jsonDecode(prefs.getString(_unlockedKey) ?? '{}') as Map)
          .cast<String, String>()),
    };
    var changed = false;
    final out = <Achievement>[];
    for (final m in GentleMilestones.evaluate(s)) {
      if (m.reached && !unlocked.containsKey(m.def.id)) {
        unlocked[m.def.id] = at.toIso8601String();
        changed = true;
      }
      final unlockedAt = DateTime.tryParse(unlocked[m.def.id] ?? '');
      out.add(Achievement(
        id: m.def.id,
        title: m.def.title,
        description: m.def.description,
        icon: m.def.icon,
        progress: AchievementProgress(
          current: unlockedAt != null ? m.def.target : m.current,
          target: m.def.target,
        ),
        unlockedAt: unlockedAt,
      ));
    }
    if (changed) await prefs.setString(_unlockedKey, jsonEncode(unlocked));
    return out;
  }

  Future<MilestoneStats> _collectStats() async {
    try {
      final tasks = await TaskRepository.loadAll();
      final journal = await JournalRepository.loadAll();
      final closes = await const DayCloseRepository()
          .between(DateTime(2000), DateTime(2100));
      final checkins = await const CheckinRepository().since(DateTime(2000));
      return MilestoneStats(
        tasksPlanned: tasks.length,
        tasksDone: tasks.where((t) => t.status == TaskStatus.done).length,
        tasksLetGo: tasks.where((t) => t.status == TaskStatus.released).length,
        daysClosed: closes.length,
        journalEntries: journal.length,
        checkins: checkins.length,
      );
    } catch (e) {
      AppLogger.warning('Milestone stats unavailable: $e');
      return const MilestoneStats();
    }
  }

  /// Get only unlocked achievements.
  Future<List<Achievement>> getUnlockedAchievements({
    bool forceRefresh = false,
  }) async {
    final all = await getAchievements(forceRefresh: forceRefresh);
    return all.where((a) => a.isUnlocked).toList();
  }

  /// Get only locked achievements.
  Future<List<Achievement>> getLockedAchievements({
    bool forceRefresh = false,
  }) async {
    final all = await getAchievements(forceRefresh: forceRefresh);
    return all.where((a) => !a.isUnlocked).toList();
  }

  /// Get newly unlocked achievements (unlocked in the last 24 hours).
  Future<List<Achievement>> getNewlyUnlockedAchievements({
    bool forceRefresh = false,
  }) async {
    final all = await getAchievements(forceRefresh: forceRefresh);
    final now = DateTime.now();
    return all
        .where((a) => a.isUnlocked && a.unlockedAt != null && now.difference(a.unlockedAt!).inHours < 24)
        .toList();
  }

  /// Get achievement by ID.
  Future<Achievement?> getAchievementById(String id, {bool forceRefresh = false}) async {
    final all = await getAchievements(forceRefresh: forceRefresh);
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievement completion percentage (0-100).
  Future<double> getOverallCompletion({bool forceRefresh = false}) async {
    final all = await getAchievements(forceRefresh: forceRefresh);
    if (all.isEmpty) return 0;

    final totalPercentage = all.fold<double>(
      0,
      (sum, achievement) => sum + achievement.progress.percentageComplete,
    );

    return totalPercentage / all.length;
  }

  /// Nothing is cached (see [getAchievements]); kept for callers.
  void clearCache() {}

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
