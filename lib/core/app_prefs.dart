import 'package:flutter/foundation.dart' show compute, visibleForTesting;
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
  static const _keyFirstUse = 'first_use_date';

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

  // ── First use ───────────────────────────────────────────────────────────

  /// Remembers the day the app was first opened. Only ever written once, so
  /// calling it on every start is safe. The Planner lets you browse back to this
  /// day (DayZen works offline, so there is no stored account-creation date).
  static Future<void> recordFirstUse([DateTime? now]) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_keyFirstUse)) return;
    final d = now ?? DateTime.now();
    await prefs.setString(_keyFirstUse, DateTime(d.year, d.month, d.day).toIso8601String());
  }

  /// The day the app was first opened, or null before [recordFirstUse] has run.
  static Future<DateTime?> firstUseDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyFirstUse);
    return raw == null ? null : DateTime.tryParse(raw);
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
    final hash = await _hashOffMainThread(pin, salt);
    await _secureStorage.write(key: _secureKeyPinSalt, value: salt);
    await _secureStorage.write(key: _secureKeyPinHash, value: hash);
  }

  /// Verifies [input] against the stored hash. Returns false if no PIN has
  /// been set. Migrates a legacy plaintext PIN into secure storage first if
  /// one is found (so upgrading users' existing PIN keeps working).
  static Future<bool> verifyPin(String input) async {
    await _migrateLegacyPinIfNeeded();
    final salt = await _secureStorage.read(key: _secureKeyPinSalt);
    final storedHash = await _secureStorage.read(key: _secureKeyPinHash);
    if (salt == null || storedHash == null) return false;
    final inputHash = await _hashOffMainThread(input, salt);
    return PinHasher.constantTimeEquals(inputHash, storedHash);
  }

  /// PBKDF2 (10k HMAC rounds) on a background isolate so the PIN pad
  /// doesn't drop frames on low-end devices.
  static Future<String> _hashOffMainThread(String pin, String salt) =>
      compute(_hashPinArgs, [pin, salt]);

  // ── PIN attempt lockout ─────────────────────────────────────────────────

  static const _keyPinFailures = 'pin_failed_attempts';
  static const _keyPinLockedUntil = 'pin_locked_until';

  /// Wrong PINs allowed before the first lockout.
  static const pinFreeAttempts = 5;

  /// Lockout after [failures] consecutive wrong PINs: none for the first
  /// [pinFreeAttempts], then 30 s, doubling each further failure, capped at
  /// 1 hour. Persisted, so restarting the app does not reset it.
  @visibleForTesting
  static Duration lockoutAfter(int failures) {
    if (failures < pinFreeAttempts) return Duration.zero;
    final doublings = (failures - pinFreeAttempts).clamp(0, 7);
    final seconds = 30 * (1 << doublings);
    return Duration(seconds: seconds.clamp(0, 3600));
  }

  /// When the PIN pad unlocks again, or null if it isn't locked.
  static Future<DateTime?> pinLockedUntil([DateTime? now]) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyPinLockedUntil);
    final until = raw == null ? null : DateTime.tryParse(raw);
    if (until == null || !until.isAfter(now ?? DateTime.now())) return null;
    return until;
  }

  /// Verifies [input] while enforcing the lockout. Never checks the PIN while
  /// locked out.
  static Future<PinAttempt> attemptPin(String input, [DateTime? now]) async {
    final at = now ?? DateTime.now();
    final lockedUntil = await pinLockedUntil(at);
    if (lockedUntil != null) return PinAttempt.locked(lockedUntil);

    final prefs = await SharedPreferences.getInstance();
    if (await verifyPin(input)) {
      await prefs.remove(_keyPinFailures);
      await prefs.remove(_keyPinLockedUntil);
      return const PinAttempt.success();
    }

    final failures = (prefs.getInt(_keyPinFailures) ?? 0) + 1;
    await prefs.setInt(_keyPinFailures, failures);
    final lockout = lockoutAfter(failures);
    if (lockout > Duration.zero) {
      final until = at.add(lockout);
      await prefs.setString(_keyPinLockedUntil, until.toIso8601String());
      return PinAttempt.locked(until);
    }
    return PinAttempt.wrong(pinFreeAttempts - failures);
  }

  static Future<void> clearPin() async {
    await _secureStorage.delete(key: _secureKeyPinHash);
    await _secureStorage.delete(key: _secureKeyPinSalt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_legacyKeyPin);
    await prefs.remove(_keyPinFailures);
    await prefs.remove(_keyPinLockedUntil);
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

String _hashPinArgs(List<String> args) => PinHasher.hash(args[0], args[1]);

/// Outcome of [AppPrefs.attemptPin].
class PinAttempt {
  const PinAttempt.success()
      : ok = true,
        remainingBeforeLock = 0,
        lockedUntil = null;
  const PinAttempt.wrong(this.remainingBeforeLock)
      : ok = false,
        lockedUntil = null;
  const PinAttempt.locked(DateTime this.lockedUntil)
      : ok = false,
        remainingBeforeLock = 0;

  final bool ok;

  /// Wrong attempts left before a lockout starts (only for a wrong PIN).
  final int remainingBeforeLock;

  /// Set when the PIN pad is locked.
  final DateTime? lockedUntil;
}
