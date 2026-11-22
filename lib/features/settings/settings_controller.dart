import 'package:flutter/material.dart';
import '../../core/domain/quiet_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/journal_sync_manager.dart';
import '../../core/services/jwt_auth_service.dart';
import '../../core/services/sync_manager.dart';

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
  // 'Brand Navy' is navy in light mode and flips to Sunrise in dark mode.
  static const accentOptions = ['Brand Navy', 'Sunrise', 'Sage', 'Lavender'];
  static const defaultAccent = 'Brand Navy';
  static const accentColorMap = <String, Color>{
    'Brand Navy': DzColors.navy,
    'Sunrise': DzColors.sunrise,
    'Sage': DzColors.zenGreen,
    'Lavender': DzColors.lavender,
  };
  String _accent = defaultAccent;
  String get accent => _accent;
  Color get accentColor => accentColorMap[_accent] ?? DzColors.navy;

  // ── Font size ──────────────────────────────────────────────────────────
  static const fontSizeOptions = ['Small (14px)', 'Standard (16px)', 'Large (18px)'];
  String _fontSize = 'Standard (16px)';
  String get fontSize => _fontSize;

  // ── Notifications ──────────────────────────────────────────────────────
  /// Task reminders on/off (P1-10: used to be "quiet hours OR focus
  /// alerts", where turning quiet hours on enabled reminders).
  bool _remindersEnabled = true;
  bool get remindersEnabled => _remindersEnabled;

  /// Reminders inside this daily window stay silent; null = no quiet hours.
  QuietWindow? _quietWindow;
  QuietWindow? get quietWindow => _quietWindow;


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

  // ── Account ─────────────────────────────────────────────────────────────
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  String? _userEmail;
  String? get userEmail => _userEmail;

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
    final savedAccent = prefs.getString('s_accent');
    // Older builds saved names (e.g. 'Zen Green') that no longer exist.
    _accent = accentColorMap.containsKey(savedAccent) ? savedAccent! : defaultAccent;
    _fontSize = prefs.getString('s_fontSize') ?? 'Standard (16px)';
    // Older builds stored two flags; reminders were on if either was on.
    // Quiet hours start off for them: the old "quiet hours" flag never
    // silenced anything, so turning a window on would change behaviour.
    _remindersEnabled = prefs.getBool('s_reminders') ??
        ((prefs.getBool('s_quietHours') ?? true) ||
            (prefs.getBool('s_focusAlerts') ?? true));
    final quietStart = prefs.getInt('s_quietStart');
    final quietEnd = prefs.getInt('s_quietEnd');
    _quietWindow = quietStart != null && quietEnd != null
        ? QuietWindow(startMinutes: quietStart, endMinutes: quietEnd)
        : null;
    _use24Hour = prefs.getBool('s_use24Hour') ?? true;
    _metricUnits = prefs.getBool('s_metricUnits') ?? true;
    _biometricEnabled = prefs.getBool('s_biometricEnabled') ?? false;
    _lockTimeout = prefs.getInt('s_lockTimeout') ?? 5;
    _aiPersonality = prefs.getString('s_aiPersonality') ?? 'Supportive & Calm';
    _tipFrequency = prefs.getString('s_tipFrequency') ?? 'Twice daily during peaks';
    _analysisDepth = prefs.getString('s_analysisDepth') ?? 'Comprehensive local processing';
    _isSignedIn = prefs.getBool('s_isSignedIn') ?? false;
    _userEmail = prefs.getString('s_userEmail');

    // Reconcile with the real JWT session (source of truth), in case a prior
    // sign-in/sign-up flow didn't update this flag — e.g. accounts created
    // before this flag existed, or before sign-up wired it up.
    // Must be the shared instance: a second instance re-reads storage and
    // can refresh the same refresh token concurrently with the real one,
    // which (with rotating refresh tokens) signs the user out.
    final authService = JwtAuthService.instance;
    if (!authService.isInitialized) await authService.initialize();
    if (authService.isAuthenticated != _isSignedIn ||
        authService.userEmail != _userEmail) {
      _isSignedIn = authService.isAuthenticated;
      _userEmail = authService.isAuthenticated ? authService.userEmail : null;
      await _save();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('s_themeMode', _themeMode.index);
    await prefs.setString('s_accent', _accent);
    await prefs.setString('s_fontSize', _fontSize);
    await prefs.setBool('s_reminders', _remindersEnabled);
    final window = _quietWindow;
    if (window != null) {
      await prefs.setInt('s_quietStart', window.startMinutes);
      await prefs.setInt('s_quietEnd', window.endMinutes);
    } else {
      await prefs.remove('s_quietStart');
      await prefs.remove('s_quietEnd');
    }
    await prefs.remove('s_quietHours'); // legacy
    await prefs.remove('s_focusAlerts'); // legacy
    await prefs.setBool('s_use24Hour', _use24Hour);
    await prefs.setBool('s_metricUnits', _metricUnits);
    await prefs.setBool('s_biometricEnabled', _biometricEnabled);
    await prefs.setInt('s_lockTimeout', _lockTimeout);
    await prefs.setString('s_aiPersonality', _aiPersonality);
    await prefs.setString('s_tipFrequency', _tipFrequency);
    await prefs.setString('s_analysisDepth', _analysisDepth);
    await prefs.setBool('s_isSignedIn', _isSignedIn);
    if (_userEmail != null) {
      await prefs.setString('s_userEmail', _userEmail!);
    } else {
      await prefs.remove('s_userEmail');
    }
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

  void setRemindersEnabled(bool value) {
    _remindersEnabled = value;
    notifyListeners();
    _save();
  }

  void setQuietWindow(QuietWindow? window) {
    _quietWindow = window;
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

  void setSignedIn(bool value, [String? email]) {
    _isSignedIn = value;
    _userEmail = value ? email : null;
    notifyListeners();
    _save();
  }

  Future<void> signOut() async {
    _isSignedIn = false;
    _userEmail = null;
    notifyListeners();
    _save();
    // Forget the pull cursors so a later sign-in does a full pull.
    SyncManager.instance.clearSyncState();
    JournalSyncManager.instance.clearSyncState();
    await JwtAuthService.instance.signOut();
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
