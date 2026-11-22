/// Service for task management with cloud sync and offline support.
///
/// API Bindings:
/// - BINDING 5: GET /tasks (listTasks) - Per-date cache
/// - BINDING 6: POST /tasks (createTask) - Single operation
/// - BINDING 7: PUT /tasks/{id} (updateTask) - Single operation
/// - BINDING 8: DELETE /tasks/{id} (deleteTask) - Single operation
/// - BINDING 9: POST /tasks/sync (syncTasks) - REUSED 4x with deduplication
library;

import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../../features/home/models/task_model.dart';

/// Task response from API (with server timestamps).
class TaskApiResponse {
  final String id;
  final String title;
  final DateTime dateMs;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final String priority;
  final String category;
  final int? iconCode;
  final String? subtitle;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // v2 fields (server migration 012). Each `has…` flag is false when the
  // server didn't send the key at all (an older server), so the local value
  // is kept instead of being reset. A key sent as null clears the value.
  final TaskStatus? status;
  final bool hasCompletedAt;
  final DateTime? completedAt;
  final int? rolloverCount;
  final bool hasEffort;
  final int? effort;
  final bool hasOriginalDate;
  final DateTime? originalDate;

  TaskApiResponse({
    required this.id,
    required this.title,
    required this.dateMs,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.priority,
    required this.category,
    this.iconCode,
    this.subtitle,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status,
    this.hasCompletedAt = false,
    this.completedAt,
    this.rolloverCount,
    this.hasEffort = false,
    this.effort,
    this.hasOriginalDate = false,
    this.originalDate,
  });

  static DateTime? _parseDate(Object? raw) =>
      raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

  /// Parse from API response (handles both old and new backend formats).
  factory TaskApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Parse date - support both old date_ms and new scheduled_date format
      DateTime dateMs;
      if (json['date_ms'] != null) {
        dateMs = DateTime.parse(json['date_ms'] as String);
      } else if (json['scheduled_date'] != null) {
        dateMs = DateTime.parse(json['scheduled_date'] as String);
      } else {
        dateMs = DateTime.now();
      }

      return TaskApiResponse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled Task',
        dateMs: dateMs,
        startHour: json['start_hour'] as int? ?? 9,
        startMinute: json['start_minute'] as int? ?? 0,
        endHour: json['end_hour'] as int? ?? 10,
        endMinute: json['end_minute'] as int? ?? 0,
        priority: json['priority'] as String? ?? 'routine',
        category: json['category'] as String? ?? 'work',
        iconCode: json['icon_code'] as int?,
        subtitle: json['subtitle'] as String? ?? json['description'] as String?, // Support both field names
        isCompleted: json['is_completed'] as bool? ?? false,
        createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
        updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
        deletedAt: json['deleted_at'] != null && (json['deleted_at'] as String?)?.isNotEmpty == true
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
        status: TaskStatus.values.asNameMap()[json['status']],
        hasCompletedAt: json.containsKey('completed_at'),
        // Server timestamps are UTC; the app works in local time.
        completedAt: _parseDate(json['completed_at'])?.toLocal(),
        rolloverCount: json['rollover_count'] as int?,
        hasEffort: json.containsKey('effort'),
        effort: json['effort'] as int?,
        hasOriginalDate: json.containsKey('original_date'),
        originalDate: _parseDate(json['original_date']),
      );
    } catch (e) {
      return TaskApiResponse(
        id: json['id'] as String? ?? '',
        title: 'Error loading task',
        dateMs: DateTime.now(),
        startHour: 9,
        startMinute: 0,
        endHour: 10,
        endMinute: 0,
        priority: 'routine',
        category: 'work',
        iconCode: null,
        subtitle: 'Failed to parse task data',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deletedAt: null,
      );
    }
  }

  /// Convert to the local model. [local] is the copy already on the phone,
  /// if any: fields an older server doesn't send keep their local value.
  DzTask toDzTask({DzTask? local}) {
    // No `status` from the server (pre-v2): follow is_completed, but never
    // turn a task the user released back into active or done. Mirrors the
    // server's rule A2 for old clients.
    final TaskStatus resolvedStatus = status ??
        (local?.status == TaskStatus.released
            ? TaskStatus.released
            : (isCompleted ? TaskStatus.done : TaskStatus.active));
    final DateTime? resolvedCompletedAt = resolvedStatus != TaskStatus.done
        ? null
        : (hasCompletedAt ? completedAt : local?.completedAt);
    return DzTask(
      id: id,
      title: title,
      startTime: TimeOfDay(hour: startHour, minute: startMinute),
      endTime: TimeOfDay(hour: endHour, minute: endMinute),
      priority: TaskPriority.values.asNameMap()[priority] ?? TaskPriority.routine,
      category: TaskCategory.values.asNameMap()[category] ?? TaskCategory.work,
      icon: iconCode != null ? IconData(iconCode!, fontFamily: 'MaterialIcons') : null,
      subtitle: subtitle,
      status: resolvedStatus,
      completedAt: resolvedCompletedAt,
      rolloverCount: rolloverCount ?? local?.rolloverCount ?? 0,
      effort: hasEffort ? effort : local?.effort,
      originalDate: hasOriginalDate ? originalDate : local?.originalDate,
      date: dateMs,
    );
  }
}

/// Sync conflict resolution result.
class SyncConflict {
  final String taskId;
  final String resolution; // 'server_wins' or 'client_wins'

  SyncConflict({required this.taskId, required this.resolution});

  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      taskId: json['id'] as String? ?? '',
      resolution: json['resolution'] as String? ?? 'server_wins',
    );
  }
}

/// Service for task API operations.
class TaskService {
  TaskService._();

  static final TaskService _instance = TaskService._();

  static TaskService get instance => _instance;

  static ApiClient _apiClient = ApiClient();

  /// Test seam: route this service through a client backed by a mock HTTP
  /// client.
  @visibleForTesting
  static set apiClientForTesting(ApiClient client) => _apiClient = client;

  // BINDING 5-9: Task caching
  final Map<String, DzTask> _taskCache = {};
  final Map<String, List<DzTask>> _dateCache = {};
  DateTime? _lastSyncTime;

  /// BINDING 5: List tasks with optional filters.
  /// API: GET /tasks?date={date}&since={since}
  /// Cache: Per-date cache key
  /// OPTIMIZATION: Date-based cache key prevents redundant calls
  Future<List<DzTask>> listTasks({
    DateTime? date,
    DateTime? since,
  }) async {
    try {
      final String cacheKey = _buildCacheKey(date, since);

      // Check date cache first
      if (_dateCache.containsKey(cacheKey)) {
        return _dateCache[cacheKey]!;
      }

      final params = <String, String>{};
      if (date != null) {
        params['date'] = date.toIso8601String().split('T').first;
      }
      if (since != null) {
        params['since'] = since.toIso8601String();
      }

      String endpoint = '/tasks';
      if (params.isNotEmpty) {
        endpoint += '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
      }

      final response = await _apiClient.get(endpoint);
      final tasks = (response['tasks'] as List<dynamic>?)
          ?.map((t) => TaskApiResponse.fromJson(t as Map<String, dynamic>).toDzTask())
          .toList() ?? [];

      // Cache by date key
      _dateCache[cacheKey] = tasks;

      // Also cache individual tasks
      for (final task in tasks) {
        _taskCache[task.id] = task;
      }

      return tasks;
    } on ApiException {
      // Check date cache first on error
      final String cacheKey = _buildCacheKey(date, since);
      if (_dateCache.containsKey(cacheKey)) {
        return _dateCache[cacheKey]!;
      }

      // Fall back to individual task cache
      if (_taskCache.isNotEmpty) {
        return _taskCache.values.toList();
      }
      rethrow;
    }
  }

  /// Helper: Build cache key for date-based queries
  String _buildCacheKey(DateTime? date, DateTime? since) {
    if (date != null) {
      return 'date_${date.toIso8601String().split('T')[0]}';
    }
    if (since != null) {
      return 'since_${since.toIso8601String()}';
    }
    return 'all';
  }

  /// Helper: Invalidate date-based caches after modifications
  void _invalidateDateCache() {
    _dateCache.clear();
  }

  /// BINDING 6: Create a new task.
  /// API: POST /tasks
  /// OPTIMIZATION: Single POST, no batching needed
  Future<DzTask> createTask(DzTask task) async {
    try {
      final body = {
        'id': task.id,
        'title': task.title,
        'date_ms': task.date.millisecondsSinceEpoch,
        'start_hour': task.startTime.hour,
        'start_minute': task.startTime.minute,
        'end_hour': task.endTime.hour,
        'end_minute': task.endTime.minute,
        'priority': task.priority.name,
        'category': task.category.name,
        'icon_code': task.icon?.codePoint,
        'subtitle': task.subtitle,
        'is_completed': task.isCompleted,
      };

      final response = await _apiClient.post('/tasks', body);
      final apiTask = TaskApiResponse.fromJson(response);
      final localTask = apiTask.toDzTask();

      _taskCache[localTask.id] = localTask;
      _invalidateDateCache(); // Invalidate since new tasks added

      return localTask;
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 7: Update an existing task.
  /// API: PUT /tasks/{id}
  /// OPTIMIZATION: Send only changed fields
  Future<DzTask> updateTask(String taskId, DzTask task) async {
    try {
      final body = <String, dynamic>{};
      if (task.title.isNotEmpty) body['title'] = task.title;
      if (task.subtitle != null) body['subtitle'] = task.subtitle;
      body['is_completed'] = task.isCompleted;
      body['start_hour'] = task.startTime.hour;
      body['end_hour'] = task.endTime.hour;

      final response = await _apiClient.put('/tasks/$taskId', body);
      final apiTask = TaskApiResponse.fromJson(response);
      final localTask = apiTask.toDzTask();

      _taskCache[localTask.id] = localTask;
      _invalidateDateCache(); // Invalidate since tasks modified

      return localTask;
    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 8: Delete a task (soft delete on server).
  /// API: DELETE /tasks/{id}
  /// OPTIMIZATION: Simple DELETE, no response parsing
  Future<void> deleteTask(String taskId) async {
    try {
      await _apiClient.delete('/tasks/$taskId');
      _taskCache.remove(taskId);
      _invalidateDateCache(); // Invalidate since tasks deleted

    } on ApiException {
      rethrow;
    }
  }

  /// BINDING 9: Push local changes and pull server changes (POST /tasks/sync).
  ///
  /// [localTasks] are the rows with unpushed changes (see
  /// `TaskRepository.dirtyRows`), not the whole list. [deletedAt] marks which
  /// of them are local deletes (tombstones), so deletes reach the server.
  ///
  /// Throws [ApiException] on failure. It never substitutes cached data for a
  /// server answer: the caller applies the result as server truth, so stale
  /// data here would overwrite newer local edits.
  ///
  /// Returns `server_tasks` (live tasks to apply), `deleted_ids` (server
  /// deletes, including any server task that came back with `deleted_at`),
  /// `conflicts` and `synced_at` (server time, null if the server omits it).
  Future<Map<String, dynamic>> syncTasks({
    DateTime? lastSyncAt,
    required List<DzTask> localTasks,
    Map<String, DateTime> deletedAt = const {},
    DzTask? Function(String id)? localFor,
  }) async {
    final tasks = localTasks.map((t) => taskSyncJson(t, deletedAt: deletedAt[t.id])).toList();

    final body = {
      'last_sync_at': lastSyncAt?.toUtc().toIso8601String(),
      'tasks': tasks,
    };

    final response = await _apiClient.post('/tasks/sync', body);

    final serverTasks = <DzTask>[];
    final deletedIds = <String>[
      ...?(response['deleted_ids'] as List<dynamic>?)?.whereType<String>(),
    ];
    for (final raw in (response['server_tasks'] as List<dynamic>?) ?? const []) {
      final apiTask = TaskApiResponse.fromJson(raw as Map<String, dynamic>);
      if (apiTask.id.isEmpty) continue;
      if (apiTask.deletedAt != null) {
        deletedIds.add(apiTask.id);
      } else {
        serverTasks.add(apiTask.toDzTask(local: localFor?.call(apiTask.id)));
      }
    }

    for (final task in serverTasks) {
      _taskCache[task.id] = task;
    }

    final conflicts = (response['conflicts'] as List<dynamic>?)
            ?.map((c) => SyncConflict.fromJson(c as Map<String, dynamic>))
            .toList() ??
        <SyncConflict>[];

    _lastSyncTime = DateTime.now();
    _invalidateDateCache();

    final syncedAtRaw = response['synced_at'];
    return {
      'server_tasks': serverTasks,
      'deleted_ids': deletedIds,
      'conflicts': conflicts,
      'synced_at': syncedAtRaw is String ? DateTime.tryParse(syncedAtRaw) : null,
    };
  }

  /// Wire format for one task in a sync push. Carries the start/end times
  /// (previously omitted, so the server's copy fell back to 09:00-10:00 and
  /// then overwrote the local task) and, for a local delete, `deleted_at`.
  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> taskSyncJson(DzTask t, {DateTime? deletedAt}) {
    final dateStr = _ymd(t.date);
    return {
      'id': t.id,
      'title': t.title,
      'description': t.subtitle,
      'scheduled_date': dateStr,
      'start_hour': t.startTime.hour,
      'start_minute': t.startTime.minute,
      'end_hour': t.endTime.hour,
      'end_minute': t.endTime.minute,
      'priority': t.priority.name,
      'category': t.category.name,
      'icon_code': t.icon?.codePoint,
      'is_completed': t.isCompleted,
      // v2 (server migration 012). Older servers ignore unknown keys.
      'status': t.status.name,
      'completed_at': t.completedAt?.toUtc().toIso8601String(),
      'rollover_count': t.rolloverCount,
      'effort': t.effort,
      'original_date': t.originalDate == null ? null : _ymd(t.originalDate!),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  /// Get last sync time.
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Clear all caches (on logout).
  void clearCache() {
    _taskCache.clear();
    _dateCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
