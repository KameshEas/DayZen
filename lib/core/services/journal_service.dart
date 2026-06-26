/// Service for journal entry management with cloud sync and offline support.
library;

import '../api/api_client.dart';

/// Journal entry response from API (with server timestamps).
class JournalApiResponse {
  final String id;
  final DateTime date;
  final String content;
  final String? mood;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  JournalApiResponse({
    required this.id,
    required this.date,
    required this.content,
    this.mood,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Parse from API response.
  factory JournalApiResponse.fromJson(Map<String, dynamic> json) {
    return JournalApiResponse(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      content: json['content'] as String,
      mood: json['mood'] as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for API requests.
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'mood': mood,
        'tags': tags,
      };
}

/// Sync conflict resolution result.
class JournalSyncConflict {
  final String entryId;
  final String resolution; // 'server_wins' or 'client_wins'

  JournalSyncConflict({required this.entryId, required this.resolution});

  factory JournalSyncConflict.fromJson(Map<String, dynamic> json) {
    return JournalSyncConflict(
      entryId: json['id'] as String,
      resolution: json['resolution'] as String,
    );
  }
}

/// Service for journal API operations.
class JournalService {
  JournalService._();

  static final JournalService _instance = JournalService._();

  static JournalService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // Cache
  final Map<String, JournalApiResponse> _journalCache = {};
  DateTime? _lastSyncTime;

  /// List journal entries with optional filters.
  Future<List<JournalApiResponse>> listEntries({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? since,
  }) async {
    try {
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

      // Cache the entries
      for (final entry in entries) {
        _journalCache[entry.id] = entry;
      }

      return entries;
    } on ApiException {
      // Return cached entries if available
      if (_journalCache.isNotEmpty) {
        return _journalCache.values.toList();
      }
      rethrow;
    }
  }

  /// Get a single journal entry.
  Future<JournalApiResponse> getEntry(String entryId) async {
    try {
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

  /// Create a new journal entry.
  Future<JournalApiResponse> createEntry(JournalApiResponse entry) async {
    try {
      final response = await _apiClient.post('/journal', entry.toJson());
      final apiEntry = JournalApiResponse.fromJson(response);
      _journalCache[apiEntry.id] = apiEntry;
      return apiEntry;
    } on ApiException {
      rethrow;
    }
  }

  /// Update an existing journal entry.
  Future<JournalApiResponse> updateEntry(
    String entryId,
    JournalApiResponse entry,
  ) async {
    try {
      final body = <String, dynamic>{
        'content': entry.content,
        'mood': entry.mood,
        'tags': entry.tags,
      };

      final response = await _apiClient.put('/journal/$entryId', body);
      final apiEntry = JournalApiResponse.fromJson(response);
      _journalCache[entryId] = apiEntry;
      return apiEntry;
    } on ApiException {
      rethrow;
    }
  }

  /// Delete a journal entry (soft delete on server).
  Future<void> deleteEntry(String entryId) async {
    try {
      await _apiClient.delete('/journal/$entryId');
      _journalCache.remove(entryId);
    } on ApiException {
      rethrow;
    }
  }

  /// Sync journal entries with server (last-write-wins conflict resolution).
  Future<Map<String, dynamic>> syncEntries({
    DateTime? lastSyncAt,
    required List<JournalApiResponse> localEntries,
  }) async {
    try {
      final entries = localEntries.map((e) => {
        'id': e.id,
        'date': e.date.toIso8601String(),
        'content': e.content,
        'mood': e.mood,
        'tags': e.tags,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
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

      // Cache server entries
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

      _lastSyncTime = DateTime.now();

      return {
        'entries': serverEntries,
        'deleted_ids': deletedIds,
        'conflicts': conflicts,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      rethrow;
    }
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear cache (on logout).
  void clearCache() {
    _journalCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
