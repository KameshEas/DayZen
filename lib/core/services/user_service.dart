/// Service for managing user profile and settings with cloud sync.
library;

import '../api/api_client.dart';
import '../models/user_models.dart';

// Convenience aliases for backwards compatibility
typedef UserProfile = UserProfileModel;
typedef UserSettings = UserSettingsModel;

/// Service for user profile and settings management.
class UserService {
  UserService._();

  static final UserService _instance = UserService._();

  static UserService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // BINDING 1-2: Profile cache (24h TTL)
  UserProfileModel? _cachedProfile;
  DateTime? _lastProfileFetch;

  // BINDING 3-4: Settings cache (1h TTL - settings change frequently)
  UserSettingsModel? _cachedSettings;
  DateTime? _lastSettingsFetch;

  /// Get current user profile.
  /// BINDING 1: GET /users/me
  /// Cache: 24 hours (user changes infrequently)
  /// Used By: SettingsController, UserService.loadProfile()
  /// OPTIMIZATION: Cache prevents repeated calls
  Future<UserProfileModel> getUserProfile({bool forceRefresh = false}) async {
    try {
      // Check cache validity (24h TTL)
      if (!forceRefresh && _cachedProfile != null && _lastProfileFetch != null) {
        final hoursSince = DateTime.now().difference(_lastProfileFetch!).inHours;
        if (hoursSince < 24) {
          return _cachedProfile!;
        }
      }

      // Fetch from API
      final response = await _apiClient.get('/users/me');
      _cachedProfile = UserProfileModel.fromJson(response);
      _lastProfileFetch = DateTime.now();

      return _cachedProfile!;
    } on ApiException {
      // Cache fallback: return cached if available
      if (_cachedProfile != null) {
        return _cachedProfile!;
      }
      rethrow;
    }
  }

  /// Update user profile (display name and/or avatar).
  /// BINDING 2: PUT /users/me
  /// Cache: Invalidate immediately
  /// Used By: SettingsController.updateProfile()
  /// OPTIMIZATION: Single PUT, no batching needed
  Future<UserProfileModel> updateUserProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final response = await _apiClient.put('/users/me', body);
      _cachedProfile = UserProfileModel.fromJson(response);
      _lastProfileFetch = DateTime.now();

      return _cachedProfile!;
    } on ApiException {
      rethrow;
    }
  }

  /// Get user settings.
  /// BINDING 3: GET /users/me/settings
  /// Cache: 1 hour (settings change frequently)
  /// Used By: SettingsController.load(), All controllers
  /// OPTIMIZATION: Shorter TTL due to user preference changes
  Future<UserSettingsModel> getUserSettings({bool forceRefresh = false}) async {
    try {
      // Check cache validity (1 hour for settings - more frequent updates)
      if (!forceRefresh && _cachedSettings != null && _lastSettingsFetch != null) {
        final minutesSince = DateTime.now().difference(_lastSettingsFetch!).inMinutes;
        if (minutesSince < 60) {
          return _cachedSettings!;
        }
      }

      // Fetch from API
      final response = await _apiClient.get('/users/me/settings');
      _cachedSettings = UserSettingsModel.fromJson(response);
      _lastSettingsFetch = DateTime.now();

      return _cachedSettings!;
    } on ApiException {
      // Cache fallback: return cached if available
      if (_cachedSettings != null) {
        return _cachedSettings!;
      }
      rethrow;
    }
  }

  /// Update user settings.
  /// BINDING 4: PUT /users/me/settings
  /// Cache: Invalidate immediately
  /// Used By: SettingsController.updateSetting()
  /// OPTIMIZATION: Send only changed fields (partial update)
  Future<UserSettingsModel> updateUserSettings({
    bool? quietHoursEnabled,
    bool? focusAlertsEnabled,
    String? timezone,
    String? themeMode,
    String? accentColor,
    String? fontSize,
    bool? biometricEnabled,
    int? biometricTimeout,
    String? aiPersonality,
    String? tipFrequency,
    String? analysisDepth,
    bool? use24Hour,
    bool? metricUnits,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (quietHoursEnabled != null) body['quiet_hours_enabled'] = quietHoursEnabled;
      if (focusAlertsEnabled != null) body['focus_alerts_enabled'] = focusAlertsEnabled;
      if (timezone != null) body['timezone'] = timezone;
      if (themeMode != null) body['theme_mode'] = themeMode;
      if (accentColor != null) body['accent_color'] = accentColor;
      if (fontSize != null) body['font_size'] = fontSize;
      if (biometricEnabled != null) body['biometric_enabled'] = biometricEnabled;
      if (biometricTimeout != null) body['biometric_timeout'] = biometricTimeout;
      if (aiPersonality != null) body['ai_personality'] = aiPersonality;
      if (tipFrequency != null) body['tip_frequency'] = tipFrequency;
      if (analysisDepth != null) body['analysis_depth'] = analysisDepth;
      if (use24Hour != null) body['use_24_hour'] = use24Hour;
      if (metricUnits != null) body['metric_units'] = metricUnits;

      final response = await _apiClient.put('/users/me/settings', body);
      _cachedSettings = UserSettingsModel.fromJson(response);
      _lastSettingsFetch = DateTime.now();

      return _cachedSettings!;
    } on ApiException {
      rethrow;
    }
  }

  /// Clear all cached user data (call on logout).
  void clearCache() {
    _cachedProfile = null;
    _cachedSettings = null;
    _lastProfileFetch = null;
    _lastSettingsFetch = null;
  }

  /// Sync user profile and settings from server.
  /// Useful after authentication or after detecting changes.
  Future<Map<String, dynamic>> syncAll() async {
    try {
      final profile = await getUserProfile(forceRefresh: true);
      final settings = await getUserSettings(forceRefresh: true);

      return {
        'profile': profile,
        'settings': settings,
        'synced_at': DateTime.now(),
      };
    } on ApiException {
      rethrow;
    }
  }

  /// Get user-friendly error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
