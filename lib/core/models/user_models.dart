/// Data models for user profile and settings.
library;

/// User profile information from API.
class UserProfileModel {
  final String firebaseUid;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfileModel({
    required this.firebaseUid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'avatar_url': avatarUrl,
  };

  /// Create a copy with optional overrides.
  UserProfileModel copyWith({
    String? firebaseUid,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// User settings/preferences from API.
class UserSettingsModel {
  final bool quietHoursEnabled;
  final bool focusAlertsEnabled;
  final String timezone;
  final String themeMode;
  final String accentColor;
  final String fontSize;
  final bool biometricEnabled;
  final int biometricTimeout;
  final String aiPersonality;
  final String tipFrequency;
  final String analysisDepth;
  final bool use24Hour;
  final bool metricUnits;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.quietHoursEnabled,
    required this.focusAlertsEnabled,
    required this.timezone,
    required this.themeMode,
    required this.accentColor,
    required this.fontSize,
    required this.biometricEnabled,
    required this.biometricTimeout,
    required this.aiPersonality,
    required this.tipFrequency,
    required this.analysisDepth,
    required this.use24Hour,
    required this.metricUnits,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? true,
      focusAlertsEnabled: json['focus_alerts_enabled'] as bool? ?? true,
      timezone: json['timezone'] as String? ?? 'UTC',
      themeMode: json['theme_mode'] as String? ?? 'dark',
      accentColor: json['accent_color'] as String? ?? 'Zen Green',
      fontSize: json['font_size'] as String? ?? 'Standard (16px)',
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      biometricTimeout: json['biometric_timeout'] as int? ?? 5,
      aiPersonality: json['ai_personality'] as String? ?? 'Supportive & Calm',
      tipFrequency: json['tip_frequency'] as String? ?? 'Twice daily during peaks',
      analysisDepth: json['analysis_depth'] as String? ?? 'Comprehensive local processing',
      use24Hour: json['use_24_hour'] as bool? ?? true,
      metricUnits: json['metric_units'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'quiet_hours_enabled': quietHoursEnabled,
    'focus_alerts_enabled': focusAlertsEnabled,
    'timezone': timezone,
    'theme_mode': themeMode,
    'accent_color': accentColor,
    'font_size': fontSize,
    'biometric_enabled': biometricEnabled,
    'biometric_timeout': biometricTimeout,
    'ai_personality': aiPersonality,
    'tip_frequency': tipFrequency,
    'analysis_depth': analysisDepth,
    'use_24_hour': use24Hour,
    'metric_units': metricUnits,
  };

  /// Create a copy with optional overrides.
  UserSettingsModel copyWith({
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
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      focusAlertsEnabled: focusAlertsEnabled ?? this.focusAlertsEnabled,
      timezone: timezone ?? this.timezone,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricTimeout: biometricTimeout ?? this.biometricTimeout,
      aiPersonality: aiPersonality ?? this.aiPersonality,
      tipFrequency: tipFrequency ?? this.tipFrequency,
      analysisDepth: analysisDepth ?? this.analysisDepth,
      use24Hour: use24Hour ?? this.use24Hour,
      metricUnits: metricUnits ?? this.metricUnits,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
