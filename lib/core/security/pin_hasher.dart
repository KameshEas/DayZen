import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 hashing for the app-lock PIN.
///
/// Internal to [AppPrefs] — the raw PIN is never persisted, only a salted
/// hash. dkLen is fixed at 32 bytes (one SHA-256 block), so this only ever
/// needs to compute the first PBKDF2 block (`T_1`).
class PinHasher {
  PinHasher._();

  /// Iteration count. Chosen as a balance between brute-force resistance and
  /// keeping unlock latency imperceptible on low-end devices — this runs
  /// synchronously after every 4-digit PIN entry.
  static const int iterations = 10000;
  static const int _keyLengthBytes = 32;

  /// Generates a cryptographically random 16-byte salt, base64-encoded.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Derives a PBKDF2-HMAC-SHA256 hash of [pin] using [saltBase64].
  static String hash(String pin, String saltBase64) {
    final salt = base64Decode(saltBase64);
    final password = utf8.encode(pin);
    final hmac = Hmac(sha256, password);

    // T_1 = U_1 ^ U_2 ^ ... ^ U_iterations
    // U_1 = HMAC(password, salt || INT_32_BE(1))
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final t = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    return base64Encode(t.sublist(0, _keyLengthBytes));
  }

  /// Constant-time string comparison to avoid timing side-channels on PIN
  /// verification.
  static bool constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
