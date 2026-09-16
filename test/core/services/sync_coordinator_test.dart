import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/services/sync_coordinator.dart';

/// Minimal fake "controller" — SyncCoordinator is generic over the
/// controller type, and doesn't touch it directly (only performSync does),
/// so any type works for exercising the shared state machine in isolation.
class _FakeController {
  int localWrites = 0;
}

class _FakeSyncCoordinator extends SyncCoordinator<_FakeController> {
  /// Set per-test to control success/failure/timing.
  Future<SyncOutcome> Function(_FakeController)? performSyncImpl;

  int performSyncCallCount = 0;

  @override
  String get entityLabel => 'Fake';

  @override
  Future<SyncOutcome> performSync(_FakeController controller) async {
    performSyncCallCount++;
    if (performSyncImpl != null) return performSyncImpl!(controller);
    return const SyncOutcome();
  }
}

void main() {
  late _FakeSyncCoordinator coordinator;
  late _FakeController controller;

  setUp(() {
    coordinator = _FakeSyncCoordinator();
    controller = _FakeController();
  });

  group('SyncCoordinator.sync', () {
    test('sets isSyncing true during and false after a successful sync', () async {
      final completer = Completer<SyncOutcome>();
      coordinator.performSyncImpl = (_) => completer.future;

      final syncFuture = coordinator.sync(controller);
      // performSync hasn't resolved yet — should be mid-sync.
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.isSyncing, isTrue);

      completer.complete(const SyncOutcome());
      await syncFuture;

      expect(coordinator.isSyncing, isFalse);
      expect(coordinator.lastSuccessfulSync, isNotNull);
    });

    test('a second overlapping call is a silent no-op', () async {
      final completer = Completer<SyncOutcome>();
      coordinator.performSyncImpl = (_) => completer.future;

      final first = coordinator.sync(controller);
      await Future<void>.delayed(Duration.zero);
      final second = coordinator.sync(controller); // should return immediately

      await second;
      expect(coordinator.performSyncCallCount, 1);

      completer.complete(const SyncOutcome());
      await first;
    });

    test('resets isSyncing and rethrows on failure, without setting lastSuccessfulSync', () async {
      coordinator.performSyncImpl = (_) => Future.error(Exception('boom'));

      await expectLater(coordinator.sync(controller), throwsException);

      expect(coordinator.isSyncing, isFalse);
      expect(coordinator.lastSuccessfulSync, isNull);
    });
  });

  group('SyncCoordinator.withSync', () {
    test('runs the local write then syncs', () async {
      await coordinator.withSync(controller, () async {
        controller.localWrites++;
      });

      expect(controller.localWrites, 1);
      expect(coordinator.performSyncCallCount, 1);
      expect(coordinator.lastSuccessfulSync, isNotNull);
    });

    test('swallows a failing local write without rethrowing', () async {
      await coordinator.withSync(controller, () async {
        throw Exception('local write failed');
      });
      // No exception propagates — matches the original
      // create*WithSync/delete*WithSync behavior being preserved as-is.
    });

    test('swallows a failing sync without rethrowing', () async {
      coordinator.performSyncImpl = (_) => Future.error(Exception('sync failed'));

      await coordinator.withSync(controller, () async {
        controller.localWrites++;
      });

      expect(controller.localWrites, 1); // local write still happened
    });
  });

  group('SyncCoordinator.retrySync', () {
    test('succeeds silently on success', () async {
      await coordinator.retrySync(controller);
      expect(coordinator.lastSuccessfulSync, isNotNull);
    });

    test('rethrows on failure (unlike withSync)', () async {
      coordinator.performSyncImpl = (_) => Future.error(Exception('retry failed'));
      await expectLater(coordinator.retrySync(controller), throwsException);
    });
  });

  group('SyncCoordinator.syncStatus', () {
    test('is "Never synced" before any sync', () {
      expect(coordinator.syncStatus, 'Never synced');
    });

    test('is "Syncing..." while a sync is in flight', () async {
      final completer = Completer<SyncOutcome>();
      coordinator.performSyncImpl = (_) => completer.future;

      final syncFuture = coordinator.sync(controller);
      await Future<void>.delayed(Duration.zero);
      expect(coordinator.syncStatus, 'Syncing...');

      completer.complete(const SyncOutcome());
      await syncFuture;
    });

    test('is "Just now" immediately after a successful sync', () async {
      await coordinator.sync(controller);
      expect(coordinator.syncStatus, 'Just now');
    });
  });

  group('SyncCoordinator.clearSyncState', () {
    test('resets lastSuccessfulSync and isSyncing', () async {
      await coordinator.sync(controller);
      expect(coordinator.lastSuccessfulSync, isNotNull);

      coordinator.clearSyncState();

      expect(coordinator.lastSuccessfulSync, isNull);
      expect(coordinator.isSyncing, isFalse);
      expect(coordinator.syncStatus, 'Never synced');
    });
  });
}
