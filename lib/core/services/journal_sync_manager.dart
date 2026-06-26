/// Manages offline-first synchronization for journal entries.
library;

import 'package:flutter/foundation.dart';
import 'journal_service.dart';
import '../../features/journal/models/journal_entry.dart';
import '../../features/journal_controller.dart';

/// Handles journal sync coordination with conflict resolution.
class JournalSyncManager extends ChangeNotifier {
  JournalSyncManager._();

  static final JournalSyncManager _instance = JournalSyncManager._();

  static JournalSyncManager get instance => _instance;

  static final JournalService _journalService = JournalService.instance;

  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;

  /// Sync all journal entries with server (offline-first).
  Future<void> syncEntries(JournalController journalController) async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final localEntries = journalController.all
          .map((e) => JournalApiResponse(
                id: e.id,
                date: DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day),
                content: '${e.title}\n\n${e.body}',
                mood: e.mood.name,
                tags: [],
                createdAt: e.timestamp,
                updatedAt: e.timestamp,
              ))
          .toList();

      final result = await _journalService.syncEntries(
        lastSyncAt: _lastSuccessfulSync,
        localEntries: localEntries,
      );

      final serverEntries = result['entries'] as List<JournalApiResponse>;
      final deletedIds = result['deleted_ids'] as List<String>;
      final conflicts = result['conflicts'] as List<JournalSyncConflict>;

      await _applyServerEntries(journalController, serverEntries, deletedIds);

      if (conflicts.isNotEmpty) {
        debugPrint('Journal sync conflicts detected: ${conflicts.length}');
        for (final conflict in conflicts) {
          debugPrint('  - Entry ${conflict.entryId}: ${conflict.resolution}');
        }
      }

      _lastSuccessfulSync = DateTime.now();
      debugPrint('Journal sync successful at $_lastSuccessfulSync');
    } catch (e) {
      debugPrint('Journal sync failed: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Apply server state to local controller.
  Future<void> _applyServerEntries(
    JournalController controller,
    List<JournalApiResponse> serverEntries,
    List<String> deletedIds,
  ) async {
    // Delete entries removed on server
    for (final id in deletedIds) {
      await controller.deleteEntry(id);
    }

    // Update local entries with server versions
    for (final serverEntry in serverEntries) {
      final localIdx = controller.all.indexWhere((e) => e.id == serverEntry.id);

      if (localIdx == -1) {
        // New entry from server - parse content back into title/body
        final parts = serverEntry.content.split('\n\n');
        final title = parts.first;
        final body = parts.length > 1 ? parts.sublist(1).join('\n\n') : '';

        final newEntry = JournalEntry(
          id: serverEntry.id,
          title: title,
          body: body,
          mood: JournalMood.values.asNameMap()[serverEntry.mood] ?? JournalMood.peaceful,
          timestamp: serverEntry.date,
        );
        await controller.addEntry(newEntry);
      } else {
        // Update existing entry - for now, server wins
        final parts = serverEntry.content.split('\n\n');
        final title = parts.first;
        final body = parts.length > 1 ? parts.sublist(1).join('\n\n') : '';

        final updatedEntry = JournalEntry(
          id: serverEntry.id,
          title: title,
          body: body,
          mood: JournalMood.values.asNameMap()[serverEntry.mood] ??
                controller.all[localIdx].mood,
          timestamp: serverEntry.date,
          accentColor: controller.all[localIdx].accentColor,
        );

        await controller.deleteEntry(serverEntry.id);
        await controller.addEntry(updatedEntry);
      }
    }
  }

  /// Create a new entry locally and queue for sync.
  Future<void> createEntryWithSync(
    JournalController controller,
    JournalEntry entry,
  ) async {
    try {
      await controller.addEntry(entry);
      await syncEntries(controller);
    } catch (e) {
      debugPrint('Entry created locally but sync failed: $e');
    }
  }

  /// Delete an entry locally and queue for sync.
  Future<void> deleteEntryWithSync(
    JournalController controller,
    String entryId,
  ) async {
    try {
      await controller.deleteEntry(entryId);
      await syncEntries(controller);
    } catch (e) {
      debugPrint('Entry deleted locally but sync failed: $e');
    }
  }

  /// Manual retry sync.
  Future<void> retrySyncEntries(JournalController journalController) async {
    try {
      await syncEntries(journalController);
    } catch (e) {
      debugPrint('Journal sync retry failed: $e');
      rethrow;
    }
  }

  /// Clear sync state (on logout).
  void clearSyncState() {
    _lastSuccessfulSync = null;
    _isSyncing = false;
  }

  /// Get sync status for UI.
  String get syncStatus {
    if (_isSyncing) return 'Syncing...';
    if (_lastSuccessfulSync == null) return 'Never synced';

    final minutesAgo = DateTime.now().difference(_lastSuccessfulSync!).inMinutes;
    if (minutesAgo == 0) return 'Just now';
    if (minutesAgo < 60) return '$minutesAgo min ago';

    final hoursAgo = (minutesAgo / 60).floor();
    if (hoursAgo < 24) return '$hoursAgo h ago';

    final daysAgo = (hoursAgo / 24).floor();
    return '$daysAgo d ago';
  }
}
