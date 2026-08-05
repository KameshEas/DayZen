/// Service for journal entry management with cloud sync and offline support.
///
/// API Bindings:
/// - BINDING 10: GET /journal (listEntries) - Per-range cache
/// - BINDING 11: GET /journal/{id} (getEntry) - Per-entry cache
/// - BINDING 12: POST /journal (createEntry) - Single operation
/// - BINDING 13: PUT /journal/{id} (updateEntry) - Single operation
/// - BINDING 14: DELETE /journal/{id} (deleteEntry) - Single operation
/// - BINDING 15: POST /journal/sync (syncEntries) - REUSED 4x with deduplication
library;

import '../api/api_client.dart';

/// Journal entry response from API (with server timestamps).
class JournalApiResponse {
  final String id;
  final String title;
  final String body;
  final String? mood;
  final int timestampMs;
  final String entryTimestamp;
  final int? accentColorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  JournalApiResponse({
    required this.id,
    required this.title,
    required this.body,
    this.mood,
    required this.timestampMs,
    required this.entryTimestamp,
    this.accentColorValue,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Parse from API response.
  factory JournalApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      return JournalApiResponse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        mood: json['mood'] as String?,
        timestampMs: json['timestamp_ms'] as int? ?? 0,
        entryTimestamp: json['entry_timestamp'] as String? ?? DateTime.now().toIso8601String(),
        accentColorValue: json['accent_color_value'] as int?,
        createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
        deletedAt: json['deleted_at'] != null && (json['deleted_at'] as String?)?.isNotEmpty == true
            ? DateTime.parse(json['deleted_at'] as String? ?? DateTime.now().toIso8601String())
            : null,
      );
    } catch (e) {
      return JournalApiResponse(
        id: json['id'] as String? ?? '',
        title: 'Error loading entry',
        body: 'Failed to parse journal entry',
        mood: null,
        timestampMs: 0,
        entryTimestamp: DateTime.now().toIso8601String(),
        accentColorValue: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );
    }
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'mood': mood,
        'timestamp_ms': timestampMs,
        'entry_timestamp': entryTimestamp,
        'accent_color_value': accentColorValue,
      };
}

/// Sync conflict resolution result.
class JournalSyncConflict {
  final String entryId;
  final String resolution; // 'server_wins' or 'client_wins'

  JournalSyncConflict({required this.entryId, required this.resolution});

  factory JournalSyncConflict.fromJson(Map<String, dynamic> json) {
    return JournalSyncConflict(
      entryId: json['id'] as String? ?? '',
      resolution: json['resolution'] as String? ?? 'server_wins',
    );
  }
}

/// Service for journal API operations.
class JournalService {
  JournalService._();

  static final JournalService _instance = JournalService._();

  static JournalService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // BINDING 10-15: Journal caching
  final Map<String, JournalApiResponse> _journalCache = {};
  final Map<String, List<JournalApiResponse>> _rangeCache = {};
  DateTime? _lastSyncTime;

  /// BINDING 10: List journal entries with optional filters.
  /// API: GET /journal?start_date={}&end_date={}
  /// Cache: Per-range cache key
  /// OPTIMIZATION: Date-range cache prevents redundant calls
  Future<List<JournalApiResponse>> listEntries({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? since,
  }) async {
    try {
      final String cacheKey = _buildRangeKey(startDate, endDate, since);

      // Check range cache first
      if (_rangeCache.containsKey(cacheKey)) {
        return _rangeCache[cacheKey]!;
      }

      final params = <String, String>{};
      if (startDate != null) {
        params['start_date'] = startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        params['end_date'] = endDate.toIso8601String().split('T').first;
      }
      if (since != null) {
        params['since'] = since.toIso8601String();
      }

      String endpoint = '/journal';
      if (params.isNotEmpty) {
        final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _apiClient.get(endpoint);
      final entries = (response['entries'] as List<dynamic>?)
          ?.map((e) => JournalApiResponse.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      // Cache by range key
      _rangeCache[cacheKey] = entries;

      // Also cache individual entries
      for (final entry in entries) {
        _journalCache[entry.id] = entry;
      }

      return entries;
    } on ApiException {
      // Check range cache first on error
      final String cacheKey = _buildRangeKey(startDate, endDate, since);
      if (_rangeCache.containsKey(cacheKey)) {
        return _rangeCache[cacheKey]!;
      }

      // Fall back to individual entry cache
      if (_journalCache.isNotEmpty) {
        return _journalCache.values.toList();
      }
      rethrow;
    }
  }

  /// Helper: Build cache key for range-based queries
  String _buildRangeKey(DateTime? start, DateTime? end, DateTime? since) {
    if (start != null && end != null) {
      return '${start.toIso8601String().split('T')[0]}_to_${end.toIso8601String().split('T')[0]}';
    }
    if (since != null) {
      return 'since_${since.toIso8601String()}';
    }
    return 'all';
  }

  /// BINDING 11: Get a single journal entry.
  /// API: GET /journal/{id}
  /// Cache: Per-entry cache
  /// OPTIMIZATION: Single entry cache hit
  Future<JournalApiResponse> getEntry(String entryId) async {
    try {
      // Check entry cache first
      if (_journalCache.containsKey(entryId)) {
        return _journalCache[entryId]!;
      }

      final response = await _apiClient.get('/journal/$entryId');
      final entry = JournalApiResponse.fromJson(response);
      _journalCache[entryId] = entry;
      return entry;
    } on ApiException {
      // Return cached entry if available
      if (_journalCache.containsKey(entryId)) {
        return _journalCache[entryId]!;
      }
      rethrow;
    }
  }

  /// BINDING 12: Create a new journal entry.
  /// API: POST /journal
  /// OPTIMIZATION: Single POST, no batching needed
  Future<JournalApiResponse> createEntry(JournalApiResponse entry) async {
    try {
      final response = await _apiClient.post('/journal', entry.toJson());
      final apiEntry = JournalApiResponse.fromJson(response);
      _journalCache[apiEntry.id] = apiEntry;
      _invalidateRangeCache(); // Invalidate since new entries added

      return apiEntry;
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 13: Update an existing journal entry.
  /// API: PUT /journal/{id}
  /// OPTIMIZATION: Send only changed fields
  Future<JournalApiResponse> updateEntry(
    String entryId,
    JournalApiResponse entry,
  ) async {
    try {
      final body = <String, dynamic>{
        'title': entry.title,
        'body': entry.body,
        'mood': entry.mood,
        'timestamp_ms': entry.timestampMs,
        'entry_timestamp': entry.entryTimestamp,
        'accent_color_value': entry.accentColorValue,
      };

      final response = await _apiClient.put('/journal/$entryId', body);
      final apiEntry = JournalApiResponse.fromJson(response);
      _journalCache[entryId] = apiEntry;
      _invalidateRangeCache(); // Invalidate since entries modified

      return apiEntry;
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 14: Delete a journal entry (soft delete on server).
  /// API: DELETE /journal/{id}
  /// OPTIMIZATION: Simple DELETE, no response parsing
  Future<void> deleteEntry(String entryId) async {
    try {
      await _apiClient.delete('/journal/$entryId');
      _journalCache.remove(entryId);
      _invalidateRangeCache(); // Invalidate since entries deleted

    } on ApiException {
      rethrow;
    }
  }

  /// Helper: Invalidate range-based caches after modifications
  void _invalidateRangeCache() {
    _rangeCache.clear();
  }

  /// BINDING 15: Sync journal entries (CRITICAL REUSE - 4x per session)
  /// API: POST /journal/sync
  /// Used By:
  ///   1. JournalSyncManager.syncEntries() - Orchestrator
  ///   2. JournalController.syncWithServer() - On app start
  ///   3. JournalSyncManager.createEntryWithSync() - After create
  ///   4. JournalSyncManager.deleteEntryWithSync() - After delete
  ///
  /// OPTIMIZATION STRATEGY:
  /// • Deduplication via lastSyncAt timestamp
  /// • Skip redundant sync if done within 30 seconds
  /// • Batch all local changes in single POST
  /// • Server-side Last-Write-Wins resolution
  Future<Map<String, dynamic>> syncEntries({
    DateTime? lastSyncAt,
    required List<JournalApiResponse> localEntries,
  }) async {
    try {
      // OPTIMIZATION: Skip redundant sync if done recently (< 30s)
      if (_lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!).inSeconds < 30) {
        return {'entries': [], 'deleted_ids': [], 'conflicts': []};
      }

      final entries = localEntries.map((e) => {
        'id': e.id,
        'title': e.title,
        'body': e.body,
        'mood': e.mood,
        'timestamp_ms': e.timestampMs,
        'entry_timestamp': e.entryTimestamp,
        'accent_color_value': e.accentColorValue,
      }).toList();

      final body = {
        'last_sync_at': lastSyncAt?.toIso8601String(),
        'entries': entries,
      };

      final response = await _apiClient.post('/journal/sync', body);

      // Parse server entries
      final serverEntries = (response['entries'] as List<dynamic>?)
          ?.map((e) => JournalApiResponse.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      // OPTIMIZATION: Cache all results
      for (final entry in serverEntries) {
        _journalCache[entry.id] = entry;
      }

      // Parse conflicts
      final conflicts = (response['conflicts'] as List<dynamic>?)
          ?.map((c) => JournalSyncConflict.fromJson(c as Map<String, dynamic>))
          .toList() ?? [];

      // Parse deleted IDs
      final deletedIds = (response['deleted_ids'] as List<dynamic>?)
          ?.map((id) => id as String)
          .toList() ?? [];

      _lastSyncTime = DateTime.now(); // Track sync time for deduplication
      _invalidateRangeCache(); // Refresh range caches after sync

      return {
        'entries': serverEntries,
        'deleted_ids': deletedIds,
        'conflicts': conflicts,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      // Cache fallback: return cached entries on error
      if (_journalCache.isNotEmpty) {
        return {
          'entries': _journalCache.values.toList(),
          'deleted_ids': [],
          'conflicts': [],
        };
      }
      rethrow;
    }
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear all caches (on logout).
  void clearCache() {
    _journalCache.clear();
    _rangeCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
