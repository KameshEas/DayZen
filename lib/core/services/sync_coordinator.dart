import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/logging/app_logger.dart';

/// Persisted pull cursor ("server time of the last successful sync") per
/// entity. Kept in SharedPreferences so a cold start does a delta sync
/// instead of a full re-download.
class SyncCursor {
  SyncCursor._();

  static Future<DateTime?> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  static Future<void> save(String key, DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value.toUtc().toIso8601String());
  }

  static Future<void> clear(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

/// Result of a single sync attempt. Subclasses log entity-specific conflict
/// details themselves (task/entry ids and resolutions differ per entity);
/// this only carries the count so the base class can log a summary line.
class SyncOutcome {
  const SyncOutcome({this.conflictCount = 0});
  final int conflictCount;
}

/// Base class for the offline-first "local write → mark dirty →
/// background push → clear dirty on success" sync pattern (Phase 3.2 of
/// docs/DEVELOPMENT_PLAN.md).
///
/// Extracted from `SyncManager` (tasks) and `JournalSyncManager` (journal
/// entries), which had hand-copied this exact state machine — the
/// `isSyncing` guard, sync-status time-ago formatting, retry wrapper, and
/// the create/delete-then-sync pattern — twice, with only the entity-
/// specific request/response shape actually differing between them.
/// Subclasses implement only [entityLabel] and [performSync]; everything
/// else lives here once.
///
/// **Not** used by `InsightsSyncManager`: insights are read-only/server-
/// computed from the client's perspective (see `InsightsController`'s own
/// doc comment) — there's no local write to push, only a cache-freshness
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
  /// Implementations own everything entity-specific — request shape,
  /// response parsing, and reconciliation.
  Future<SyncOutcome> performSync(TController controller);

  /// Sync with the server (offline-first, guarded against overlapping
  /// calls — a call that arrives while one is already in flight is a
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

  bool _resyncRequested = false;

  /// Fire-and-forget push after a local write. Never throws.
  ///
  /// Controllers call this *after* they have written locally; it must never
  /// call back into a controller mutator. (The old `withSync(localWrite)`
  /// did, and since every mutator queued another `withSync`, each add or
  /// delete re-ran itself forever — see docs/MOBILE_PROJECT_PLAN.md P0-1.)
  ///
  /// A request that arrives while a sync is in flight is not dropped: it
  /// schedules exactly one follow-up sync, so a write made mid-sync is still
  /// pushed promptly.
  Future<void> requestSync(TController controller) async {
    if (_isSyncing) {
      _resyncRequested = true;
      return;
    }
    do {
      _resyncRequested = false;
      try {
        await sync(controller);
      } catch (e) {
        AppLogger.debug('$entityLabel sync failed; changes stay queued: $e');
        return;
      }
    } while (_resyncRequested);
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
    _resyncRequested = false;
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


