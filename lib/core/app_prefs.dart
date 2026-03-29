import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for app-level flags.
class AppPrefs {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyPin = 'app_pin';

  // ── Onboarding ──────────────────────────────────────────────────────────

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingSeen) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, true);
  }

  // ── PIN ─────────────────────────────────────────────────────────────────

  /// Returns the stored PIN, or null if none has been set.
  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin);
  }

  /// Persists [pin] (plain 4-digit string).
  /// For a production app use a secure hashing approach (e.g. PBKDF2).
  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
  }

  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPin);
  }

  static Future<bool> hasPin() async => (await getPin()) != null;
}
