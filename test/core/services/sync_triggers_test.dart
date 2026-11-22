import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/services/sync_triggers.dart';

/// Before SyncTriggers the app synced only on start and after a local edit:
/// signing in showed none of the account's data, and resuming the app pulled
/// nothing (found testing on a device against a local API).
class _Auth extends ChangeNotifier {
  bool signedIn = false;
  void set(bool value) {
    signedIn = value;
    notifyListeners();
  }
}

void main() {
  late _Auth auth;
  late int syncs;
  late SyncTriggers triggers;

  setUp(() {
    auth = _Auth();
    syncs = 0;
    triggers = SyncTriggers(
      auth: auth,
      isSignedIn: () => auth.signedIn,
      syncAll: () async => syncs++,
    )..attach();
  });

  tearDown(() => triggers.detach());

  test('signing in starts one sync', () async {
    auth.set(true);
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 1);
  });

  test('token refreshes while signed in do not sync again', () async {
    auth
      ..set(true)
      ..set(true); // e.g. a refreshed token notifies listeners
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 1);
  });

  test('signing out does not sync; signing in again does', () async {
    auth
      ..set(true)
      ..set(false)
      ..set(true);
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 2);
  });

  test('resume syncs only when signed in', () async {
    triggers.onResume();
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 0);

    auth.signedIn = true; // already signed in, no transition
    triggers.onResume();
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 1);
  });

  test('already signed in at attach: no sync until resume or a new sign-in',
      () async {
    triggers.detach();
    auth.signedIn = true;
    triggers = SyncTriggers(
      auth: auth,
      isSignedIn: () => auth.signedIn,
      syncAll: () async => syncs++,
    )..attach();
    auth.set(true);
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 0); // controllers' own load() covers app start
  });

  test('detach stops listening', () async {
    triggers.detach();
    auth.set(true);
    await Future<void>.delayed(Duration.zero);
    expect(syncs, 0);
  });
}
