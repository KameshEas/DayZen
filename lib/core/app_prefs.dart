import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'security/pin_hasher.dart';

/// Thin wrapper around SharedPreferences for app-level flags, and
/// FlutterSecureStorage (Keychain/Keystore-backed) for the PIN.
///
/// The PIN itself is never persisted in plaintext — only a PBKDF2-HMAC-SHA256
/// hash + salt, held in secure storage. See [PinHasher].
class AppPrefs {
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyBiometricEnabled = 's_biometricEnabled';

  /// Set when the user explicitly declines to set a PIN (skips PIN setup, or
  /// turns "PIN Lock" off in Settings). PIN is optional, so this stops the
  /// app from re-prompting for PIN setup on every subsequent sign-in.
  static const _keyPinOptedOut = 's_pinOptedOut';

  /// Legacy plaintext PIN key. Read once (if present) to migrate into
  /// secure storage, then deleted. Do not write to this key going forward.
  static const _legacyKeyPin = 'app_pin';

  static const _secureKeyPinHash = 'app_pin_hash';
  static const _secureKeyPinSalt = 'app_pin_salt';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

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

  /// Returns true if a PIN has been set. Runs the legacy-plaintext migration
  /// as a side effect, so this should be called at least once on app start
  /// (it already is, via `main.dart`'s startup `Future.wait`).
  static Future<bool> hasPin() async {
    await _migrateLegacyPinIfNeeded();
    final hash = await _secureStorage.read(key: _secureKeyPinHash);
    return hash != null;
  }

  /// Hashes and salts [pin] (PBKDF2-HMAC-SHA256) and persists the result to
  /// secure storage. The raw PIN is never written to disk.
  static Future<void> savePin(String pin) async {
    final salt = PinHasher.generateSalt();
    final hash = PinHasher.hash(pin, salt);
    await _secureStorage.write(key: _secureKeyPinSalt, value: salt);
    await _secureStorage.write(key: _secureKeyPinHash, value: hash);
    // A PIN now exists, so any earlier opt-out no longer applies.
    await setPinOptedOut(false);
  }

  /// Verifies [input] against the stored hash. Returns false if no PIN has
  /// been set. Migrates a legacy plaintext PIN into secure storage first if
  /// one is found (so upgrading users' existing PIN keeps working).
  static Future<bool> verifyPin(String input) async {
    await _migrateLegacyPinIfNeeded();
    final salt = await _secureStorage.read(key: _secureKeyPinSalt);
    final storedHash = await _secureStorage.read(key: _secureKeyPinHash);
    if (salt == null || storedHash == null) return false;
    final inputHash = PinHasher.hash(input, salt);
    return PinHasher.constantTimeEquals(inputHash, storedHash);
  }

  /// Returns the stored PIN hash and salt (for syncing to the backend so the
  /// PIN can be restored after an uninstall/reinstall), or null if unset.
  static Future<({String hash, String salt})?> getPinHashAndSalt() async {
    await _migrateLegacyPinIfNeeded();
    final hash = await _secureStorage.read(key: _secureKeyPinHash);
    final salt = await _secureStorage.read(key: _secureKeyPinSalt);
    if (hash == null || salt == null) return null;
    return (hash: hash, salt: salt);
  }

  /// Writes an already-hashed PIN (fetched from the backend) directly to
  /// secure storage, restoring a previously-set PIN on a fresh install
  /// without requiring the user to re-enter or re-create it.
  static Future<void> restoreHashedPin(String hash, String salt) async {
    await _secureStorage.write(key: _secureKeyPinSalt, value: salt);
    await _secureStorage.write(key: _secureKeyPinHash, value: hash);
  }

  static Future<void> clearPin() async {
    await _secureStorage.delete(key: _secureKeyPinHash);
    await _secureStorage.delete(key: _secureKeyPinSalt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyKeyPin);
  }

  /// Whether the user has explicitly chosen not to use a PIN (skipped setup,
  /// or turned "PIN Lock" off in Settings). PIN is optional — this is what
  /// stops the app from re-prompting on every subsequent sign-in.
  static Future<bool> isPinOptedOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPinOptedOut) ?? false;
  }

  static Future<void> setPinOptedOut(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPinOptedOut, value);
  }

  /// One-time migration: if an old plaintext PIN exists in SharedPreferences
  /// (pre-hardening installs), hash it into secure storage and delete the
  /// legacy key. Safe to call repeatedly — no-ops once migrated.
  static Future<void> _migrateLegacyPinIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyPin = prefs.getString(_legacyKeyPin);
    if (legacyPin == null) return;

    final alreadyMigrated =
        await _secureStorage.read(key: _secureKeyPinHash) != null;
    if (!alreadyMigrated) {
      await savePin(legacyPin);
    }
    await prefs.remove(_legacyKeyPin);
  }

  // ── Biometric ───────────────────────────────────────────────────────────

  /// Returns true if the user has opted into biometric lock.
  /// Reads the same key used by [SettingsController].
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }
}
