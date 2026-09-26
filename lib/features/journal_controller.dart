import 'package:flutter/material.dart';
import '../core/data/journal_repository.dart';
import '../core/domain/journal_analytics.dart';
import '../core/services/journal_sync_manager.dart';
import 'journal/models/journal_entry.dart';
import '../../core/logging/app_logger.dart';

class JournalController extends ChangeNotifier {
  List<JournalEntry> _entries = [];

  /// Entries sorted newest-first.
  List<JournalEntry> get all => List.unmodifiable(_entries);

  /// Count of entries logged in the current calendar week (Monâ€“Sun).
  /// Thin delegate to JournalAnalytics (lib/core/domain/journal_analytics.dart)
  /// â€” no business logic lives here as of Phase 3.1.
  int get thisWeekCount => JournalAnalytics.thisWeekCount(_entries);

  // â”€â”€ CRUD â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> load() async {
    _entries = await JournalRepository.loadAll();
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
    // Sync with server in background
    syncWithServer();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await insertLocal(entry);
    // Queue for sync (fire-and-forget)
    JournalSyncManager.instance.createEntryWithSync(this, entry);
  }

  Future<void> deleteEntry(String id) async {
    await removeLocal(id);
    // Queue for sync (fire-and-forget)
    JournalSyncManager.instance.deleteEntryWithSync(this, id);
  }

  /// Local-only write path (no sync queuing). Used by [addEntry] above and
  /// by [JournalSyncManager] when reconciling server state â€” calling
  /// [addEntry] from there would re-queue a sync on every reconciled entry
  /// and recurse forever (each pass re-inserting the same entry, which is
  /// what previously caused the entry count to grow unbounded while the
  /// app stayed open).
  Future<void> insertLocal(JournalEntry entry) async {
    _entries.insert(0, entry);
    // Single-row insert â€” see docs/DATABASE_SCHEMA.md. Replaces the old
    // "re-serialize and rewrite every entry" pattern.
    await JournalRepository.insertEntry(entry);
    notifyListeners();
  }

  /// Local-only delete path (no sync queuing) â€” see [insertLocal].
  Future<void> removeLocal(String id) async {
    _entries.removeWhere((e) => e.id == id);
    // Soft delete (deleted_at set, row retained for sync visibility) â€” see
    // docs/DATABASE_SCHEMA.md.
    await JournalRepository.deleteEntry(id);
    notifyListeners();
  }

  /// Sync entries with server (background operation).
  Future<void> syncWithServer() async {
    try {
      await JournalSyncManager.instance.syncEntries(this);
    } catch (e) {
      AppLogger.debug('Background journal sync failed: $e');
      // Silently fail - local state is preserved
    }
  }

  Future<void> clearAll() async {
    _entries.clear();
    // Hard delete every row â€” this is the one place that's actually
    // destructive; everyday deletes go through deleteEntry's soft delete.
    await JournalRepository.clearAll();
    notifyListeners();
  }
}


