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
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      progress: AchievementProgress.fromJson(json['progress'] as Map<String, dynamic>),
      unlockedAt: json['unlocked_at'] != null ? DateTime.parse(json['unlocked_at'] as String) : null,
    );
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

  static final ApiClient _apiClient = ApiClient();

  // Cache
  List<Achievement>? _cachedAchievements;
  DateTime? _lastFetchTime;

  static const int _cacheDurationHours = 24;

  /// BINDING 25: Get all achievements for current user.
  /// API: GET /achievements
  /// Cache: 24 hours
  /// Returns: List of achievements with progress and unlock status
  Future<List<Achievement>> getAchievements({
    bool forceRefresh = false,
  }) async {
    try {
      // Check cache validity
      if (!forceRefresh && _cachedAchievements != null && _lastFetchTime != null) {
        final hoursSinceFetch = DateTime.now().difference(_lastFetchTime!).inHours;
        if (hoursSinceFetch < _cacheDurationHours) {
          return _cachedAchievements!;
        }
      }

      // Fetch fresh achievements
      final response = await _apiClient.get('/achievements');

      final achievements = (response['achievements'] as List<dynamic>?)
          ?.map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList() ?? [];

      // Cache the result
      _cachedAchievements = achievements;
      _lastFetchTime = DateTime.now();

      return achievements;
    } on ApiException {
      // Return cached if available
      if (_cachedAchievements != null) {
        return _cachedAchievements!;
      }
      rethrow;
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

  /// Clear cache (on logout).
  void clearCache() {
    _cachedAchievements = null;
    _lastFetchTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
