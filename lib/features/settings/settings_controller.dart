import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted settings for the DayZen app.
class SettingsController extends ChangeNotifier {
  // ── Device biometric capability (set once at startup, not persisted) ───
  bool _deviceHasBiometrics = false;
  bool get deviceHasBiometrics => _deviceHasBiometrics;

  void setDeviceHasBiometrics(bool value) {
    _deviceHasBiometrics = value;
    // If device lost biometrics, auto-disable the setting
    if (!value && _biometricEnabled) {
      _biometricEnabled = false;
      _save();
    }
    notifyListeners();
  }

  // ── Theme ──────────────────────────────────────────────────────────────
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  String get themeModeLabel => switch (_themeMode) {
        ThemeMode.system => 'System default applied',
        ThemeMode.light => 'Light mode applied',
        ThemeMode.dark => 'Dark mode applied',
      };

  // ── Accent ─────────────────────────────────────────────────────────────
  static const accentOptions = ['Zen Green', 'Ocean Blue', 'Sunset Orange', 'Lavender'];
  String _accent = 'Zen Green';
  String get accent => _accent;

  // ── Font size ──────────────────────────────────────────────────────────
  static const fontSizeOptions = ['Small (14px)', 'Standard (16px)', 'Large (18px)'];
  String _fontSize = 'Standard (16px)';
  String get fontSize => _fontSize;

  // ── Notifications ──────────────────────────────────────────────────────
  bool _quietHours = true;
  bool get quietHours => _quietHours;

  bool _focusAlerts = true;
  bool get focusAlerts => _focusAlerts;

  // ── Units ──────────────────────────────────────────────────────────────
  bool _use24Hour = true;
  bool get use24Hour => _use24Hour;

  bool _metricUnits = true;
  bool get metricUnits => _metricUnits;

  String get unitsLabel {
    final unit = _metricUnits ? 'Metric' : 'Imperial';
    final clock = _use24Hour ? '24-hour clock' : '12-hour clock';
    return '$unit, $clock';
  }

  // ── Biometric lock ────────────────────────────────────────────────────
  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  int _lockTimeout = 5; // minutes
  int get lockTimeout => _lockTimeout;

  String get biometricLabel => _biometricEnabled
      ? 'Locked after $_lockTimeout mins of inactivity'
      : 'Disabled';

  // ── AI Settings ────────────────────────────────────────────────────────
  static const personalityOptions = ['Supportive & Calm', 'Motivational', 'Analytical'];
  String _aiPersonality = 'Supportive & Calm';
  String get aiPersonality => _aiPersonality;

  static const tipFrequencyOptions = [
    'Once daily',
    'Twice daily during peaks',
    'Every few hours',
  ];
  String _tipFrequency = 'Twice daily during peaks';
  String get tipFrequency => _tipFrequency;

  static const analysisDepthOptions = [
    'Light local processing',
    'Comprehensive local processing',
  ];
  String _analysisDepth = 'Comprehensive local processing';
  String get analysisDepth => _analysisDepth;

  // ── Load / Save ────────────────────────────────────────────────────────

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('s_themeMode') ?? 0];
    _accent = prefs.getString('s_accent') ?? 'Zen Green';
    _fontSize = prefs.getString('s_fontSize') ?? 'Standard (16px)';
    _quietHours = prefs.getBool('s_quietHours') ?? true;
    _focusAlerts = prefs.getBool('s_focusAlerts') ?? true;
    _use24Hour = prefs.getBool('s_use24Hour') ?? true;
    _metricUnits = prefs.getBool('s_metricUnits') ?? true;
    _biometricEnabled = prefs.getBool('s_biometricEnabled') ?? false;
    _lockTimeout = prefs.getInt('s_lockTimeout') ?? 5;
    _aiPersonality = prefs.getString('s_aiPersonality') ?? 'Supportive & Calm';
    _tipFrequency = prefs.getString('s_tipFrequency') ?? 'Twice daily during peaks';
    _analysisDepth = prefs.getString('s_analysisDepth') ?? 'Comprehensive local processing';
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('s_themeMode', _themeMode.index);
    await prefs.setString('s_accent', _accent);
    await prefs.setString('s_fontSize', _fontSize);
    await prefs.setBool('s_quietHours', _quietHours);
    await prefs.setBool('s_focusAlerts', _focusAlerts);
    await prefs.setBool('s_use24Hour', _use24Hour);
    await prefs.setBool('s_metricUnits', _metricUnits);
    await prefs.setBool('s_biometricEnabled', _biometricEnabled);
    await prefs.setInt('s_lockTimeout', _lockTimeout);
    await prefs.setString('s_aiPersonality', _aiPersonality);
    await prefs.setString('s_tipFrequency', _tipFrequency);
    await prefs.setString('s_analysisDepth', _analysisDepth);
  }

  // ── Mutators ───────────────────────────────────────────────────────────

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _save();
  }

  void setAccent(String value) {
    _accent = value;
    notifyListeners();
    _save();
  }

  void setFontSize(String value) {
    _fontSize = value;
    notifyListeners();
    _save();
  }

  void setQuietHours(bool value) {
    _quietHours = value;
    notifyListeners();
    _save();
  }

  void setFocusAlerts(bool value) {
    _focusAlerts = value;
    notifyListeners();
    _save();
  }

  void setUse24Hour(bool value) {
    _use24Hour = value;
    notifyListeners();
    _save();
  }

  void setMetricUnits(bool value) {
    _metricUnits = value;
    notifyListeners();
    _save();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    notifyListeners();
    _save();
  }

  void setLockTimeout(int minutes) {
    _lockTimeout = minutes;
    notifyListeners();
    _save();
  }

  void setAiPersonality(String value) {
    _aiPersonality = value;
    notifyListeners();
    _save();
  }

  void setTipFrequency(String value) {
    _tipFrequency = value;
    notifyListeners();
    _save();
  }

  void setAnalysisDepth(String value) {
    _analysisDepth = value;
    notifyListeners();
    _save();
  }
}
