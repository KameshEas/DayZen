/// Helper to sync user settings between backend API and local SettingsController.
library;

import 'package:flutter/material.dart';
import 'user_service.dart';
import '../domain/quiet_window.dart';
import '../../features/settings/settings_controller.dart';
import '../../core/logging/app_logger.dart';

/// Syncs user settings from backend to local controller.
Future<void> syncSettingsFromBackend(SettingsController controller) async {
  try {
    final settings = await UserService.instance.getUserSettings();

    // Update theme mode
    controller.setThemeMode(_parseThemeMode(settings.themeMode));

    // Update accent color
    controller.setAccent(settings.accentColor);

    // Update font size
    controller.setFontSize(settings.fontSize);

    // Update notification settings
    // Older servers only have the two legacy flags (reminders were on if
    // either was on).
    controller.setRemindersEnabled(settings.remindersEnabled ??
        (settings.quietHoursEnabled || settings.focusAlertsEnabled));
    final start = QuietWindow.parse(settings.quietStart);
    final end = QuietWindow.parse(settings.quietEnd);
    controller.setQuietWindow(start != null && end != null
        ? QuietWindow(startMinutes: start, endMinutes: end)
        : null);

    // Update units
    controller.setUse24Hour(settings.use24Hour);
    controller.setMetricUnits(settings.metricUnits);

    // Update biometric settings
    controller.setBiometricEnabled(settings.biometricEnabled);
    controller.setLockTimeout(settings.biometricTimeout);

    // Update AI settings
    controller.setAiPersonality(settings.aiPersonality);
    controller.setTipFrequency(settings.tipFrequency);
    controller.setAnalysisDepth(settings.analysisDepth);
  } catch (e) {
    // Silently fail - use local settings if sync fails
    AppLogger.info('Failed to sync settings from backend: $e');
  }
}

/// Syncs user settings from local controller to backend.
Future<void> syncSettingsToBackend(SettingsController controller) async {
  try {
    await UserService.instance.updateUserSettings(
      themeMode: _themeModeToString(controller.themeMode),
      accentColor: controller.accent,
      fontSize: controller.fontSize,
      remindersEnabled: controller.remindersEnabled,
      quietHoursEnabled: controller.quietWindow != null,
      sendQuietWindow: true,
      quietStart: controller.quietWindow == null
          ? null
          : QuietWindow.format(controller.quietWindow!.startMinutes),
      quietEnd: controller.quietWindow == null
          ? null
          : QuietWindow.format(controller.quietWindow!.endMinutes),
      use24Hour: controller.use24Hour,
      metricUnits: controller.metricUnits,
      biometricEnabled: controller.biometricEnabled,
      biometricTimeout: controller.lockTimeout,
      aiPersonality: controller.aiPersonality,
      tipFrequency: controller.tipFrequency,
      analysisDepth: controller.analysisDepth,
    );
  } catch (e) {
    AppLogger.info('Failed to sync settings to backend: $e');
    rethrow;
  }
}

/// Parse theme mode string from backend.
ThemeMode _parseThemeMode(String? mode) {
  switch (mode?.toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}

/// Convert theme mode to string for backend.
String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}


