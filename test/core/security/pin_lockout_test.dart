import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dayzen/core/app_prefs.dart';

/// The unlock page's old "Too many attempts" was cosmetic: input was never
/// blocked and the count reset on restart. The lockout is now persisted.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('lockout schedule: 5 free tries, then 30 s doubling, capped at 1 h', () {
    expect(AppPrefs.lockoutAfter(4), Duration.zero);
    expect(AppPrefs.lockoutAfter(5), const Duration(seconds: 30));
    expect(AppPrefs.lockoutAfter(6), const Duration(seconds: 60));
    expect(AppPrefs.lockoutAfter(8), const Duration(minutes: 4));
    expect(AppPrefs.lockoutAfter(50), const Duration(hours: 1));
  });

  test('wrong PINs count down, then lock; the PIN is not checked while locked',
      () async {
    await AppPrefs.savePin('1234');
    final t0 = DateTime(2026, 11, 20, 9);

    for (var i = 1; i <= 4; i++) {
      final r = await AppPrefs.attemptPin('0000', t0);
      expect(r.ok, isFalse);
      expect(r.remainingBeforeLock, 5 - i);
    }
    final fifth = await AppPrefs.attemptPin('0000', t0);
    expect(fifth.lockedUntil, t0.add(const Duration(seconds: 30)));

    // Correct PIN during the lockout is refused without being verified.
    final during = await AppPrefs.attemptPin('1234', t0.add(const Duration(seconds: 10)));
    expect(during.ok, isFalse);
    expect(during.lockedUntil, isNotNull);

    // After it expires the correct PIN works and the counter resets.
    final after = await AppPrefs.attemptPin('1234', t0.add(const Duration(seconds: 31)));
    expect(after.ok, isTrue);
    final next = await AppPrefs.attemptPin('0000', t0.add(const Duration(minutes: 1)));
    expect(next.remainingBeforeLock, 4);
  });

  test('the lockout survives a restart (persisted)', () async {
    await AppPrefs.savePin('1234');
    final t0 = DateTime.now();
    for (var i = 0; i < 5; i++) {
      await AppPrefs.attemptPin('0000', t0);
    }
    expect(await AppPrefs.pinLockedUntil(t0.add(const Duration(seconds: 5))),
        isNotNull);
  });
}
