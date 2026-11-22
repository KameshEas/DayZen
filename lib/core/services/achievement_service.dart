/// Service for achievement/gamification management.
///
/// API Binding:
/// - BINDING 25: GET /achievements (getAchievements)
library;

import '../api/api_client.dart';

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

  /// All achievements with progress and unlock status.
  ///
  /// There is no server source: the app used to call GET /achievements,
  /// which the DayZen API has never had, so the page always showed an error.
  /// Achievements will be computed on the device (planned: gentle
  /// milestones); until then there are none.
  Future<List<Achievement>> getAchievements({
    bool forceRefresh = false,
  }) async =>
      const [];

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
