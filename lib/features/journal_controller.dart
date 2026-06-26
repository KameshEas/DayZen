import 'package:flutter/material.dart';
import '../core/data/journal_repository.dart';
import '../core/services/journal_sync_manager.dart';
import 'journal/models/journal_entry.dart';

class JournalController extends ChangeNotifier {
  List<JournalEntry> _entries = [];

  /// Entries sorted newest-first.
  List<JournalEntry> get all => List.unmodifiable(_entries);

  /// Count of entries logged in the current calendar week (Mon–Sun).
  int get thisWeekCount {
    final now = DateTime.now();
    final monday = DateTime(
        now.year, now.month, now.day - (now.weekday - 1));
    return _entries.where((e) {
      final d = e.timestamp;
      final day = DateTime(d.year, d.month, d.day);
      return !day.isBefore(monday);
    }).length;
  }

  // ── CRUD ──────────────────────────────────────────────────────────

  Future<void> load() async {
    _entries = await JournalRepository.load();
    _entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
    // Sync with server in background
    syncWithServer();
  }

  Future<void> addEntry(JournalEntry entry) async {
    _entries.insert(0, entry);
    await JournalRepository.save(_entries);
    notifyListeners();
    // Queue for sync (fire-and-forget)
    JournalSyncManager.instance.createEntryWithSync(this, entry);
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await JournalRepository.save(_entries);
    notifyListeners();
    // Queue for sync (fire-and-forget)
    JournalSyncManager.instance.deleteEntryWithSync(this, id);
  }

  /// Sync entries with server (background operation).
  Future<void> syncWithServer() async {
    try {
      await JournalSyncManager.instance.syncEntries(this);
    } catch (e) {
      debugPrint('Background journal sync failed: $e');
      // Silently fail - local state is preserved
    }
  }

  Future<void> clearAll() async {
    _entries.clear();
    await JournalRepository.save(_entries);
    notifyListeners();
  }
}
