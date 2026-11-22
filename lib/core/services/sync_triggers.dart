import 'dart:async';

import 'package:flutter/foundation.dart';

/// Starts a sync at the moments the app used to miss:
///
/// - **Sign-in.** Controllers only synced on app start and after a local
///   change, so signing in on a phone showed none of the account's existing
///   tasks or journal entries until the user edited something.
/// - **Resume.** Coming back to the app (e.g. after editing on another
///   device) didn't pull anything either.
///
/// [isSignedIn] is read on every auth change; [syncAll] must never throw.
class SyncTriggers {
  SyncTriggers({
    required Listenable auth,
    required bool Function() isSignedIn,
    required Future<void> Function() syncAll,
  })  : _auth = auth,
        _isSignedIn = isSignedIn,
        _syncAll = syncAll;

  final Listenable _auth;
  final bool Function() _isSignedIn;
  final Future<void> Function() _syncAll;
  bool _wasSignedIn = false;
  bool _attached = false;

  void attach() {
    if (_attached) return;
    _attached = true;
    _wasSignedIn = _isSignedIn();
    _auth.addListener(_onAuthChanged);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    _auth.removeListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    final signedIn = _isSignedIn();
    // Only the signed-out -> signed-in edge: token refreshes also notify.
    if (signedIn && !_wasSignedIn) unawaited(_syncAll());
    _wasSignedIn = signedIn;
  }

  /// Call when the app returns to the foreground.
  void onResume() {
    if (_isSignedIn()) unawaited(_syncAll());
  }
}
