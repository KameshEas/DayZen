import 'package:flutter/foundation.dart';
import '../../core/logging/app_logger.dart';

/// Result of a single sync attempt. Subclasses log entity-specific conflict
/// details themselves (task/entry ids and resolutions differ per entity);
/// this only carries the count so the base class can log a summary line.
class SyncOutcome {
  const SyncOutcome({this.conflictCount = 0});
  final int conflictCount;
}

/// Base class for the offline-first "local write â†’ mark dirty â†’
/// background push â†’ clear dirty on success" sync pattern (Phase 3.2 of
/// docs/DEVELOPMENT_PLAN.md).
///
/// Extracted from `SyncManager` (tasks) and `JournalSyncManager` (journal
/// entries), which had hand-copied this exact state machine â€” the
/// `isSyncing` guard, sync-status time-ago formatting, retry wrapper, and
/// the create/delete-then-sync pattern â€” twice, with only the entity-
/// specific request/response shape actually differing between them.
/// Subclasses implement only [entityLabel] and [performSync]; everything
/// else lives here once.
///
/// **Not** used by `InsightsSyncManager`: insights are read-only/server-
/// computed from the client's perspective (see `InsightsController`'s own
/// doc comment) â€” there's no local write to push, only a cache-freshness
/// pull. That's a different pattern, and forcing it into this shape would
/// be a worse fit than leaving it separate. See docs/ARCHITECTURE.md.
abstract class SyncCoordinator<TController> extends ChangeNotifier {
  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Label used only in debug log lines (e.g. `"Task"`, `"Journal entry"`).
  String get entityLabel;

  /// Push local state (read from [controller]) to the server, and apply
  /// the server's response back onto [controller] (add/update/delete).
  /// Implementations own everything entity-specific â€” request shape,
  /// response parsing, and reconciliation.
  Future<SyncOutcome> performSync(TController controller);

  /// Sync with the server (offline-first, guarded against overlapping
  /// calls â€” a call that arrives while one is already in flight is a
  /// silent no-op, matching the original `SyncManager`/`JournalSyncManager`
  /// behavior).
  Future<void> sync(TController controller) async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final outcome = await performSync(controller);
      if (outcome.conflictCount > 0) {
        AppLogger.debug(
            '$entityLabel sync conflicts detected: ${outcome.conflictCount}');
      }
      _lastSuccessfulSync = DateTime.now();
      AppLogger.debug('$entityLabel sync successful at $_lastSuccessfulSync');
    } catch (e) {
      AppLogger.debug('$entityLabel sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Runs [localWrite], then attempts a sync. Matches the original
  /// `create*WithSync`/`delete*WithSync` behavior exactly: both the local
  /// write *and* the sync attempt are wrapped in the same try/catch, so a
  /// failing [localWrite] is logged and swallowed the same way a failing
  /// sync is â€” this preserves existing behavior as-is rather than fixing
  /// it as a side effect of this extraction (worth revisiting separately;
  /// see docs/ARCHITECTURE.md).
  Future<void> withSync(
    TController controller,
    Future<void> Function() localWrite,
  ) async {
    try {
      await localWrite();
      await sync(controller);
    } catch (e) {
      AppLogger.debug('$entityLabel changed locally but sync failed: $e');
    }
  }

  Future<void> retrySync(TController controller) async {
    try {
      await sync(controller);
    } catch (e) {
      AppLogger.debug('$entityLabel sync retry failed: $e');
      rethrow;
    }
  }

  /// Clear sync state (on logout).
  void clearSyncState() {
    _lastSuccessfulSync = null;
    _isSyncing = false;
  }

  /// Human-readable sync status for UI display.
  String get syncStatus {
    if (_isSyncing) return 'Syncing...';
    if (_lastSuccessfulSync == null) return 'Never synced';

    final minutesAgo =
        DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}


