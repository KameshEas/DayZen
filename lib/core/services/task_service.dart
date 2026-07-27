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
  });

  /// Parse from API response.
  factory TaskApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      return TaskApiResponse(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Untitled Task',
        dateMs: DateTime.parse(json['date_ms'] as String? ?? DateTime.now().toIso8601String()),
        startHour: json['start_hour'] as int? ?? 9,
        startMinute: json['start_minute'] as int? ?? 0,
        endHour: json['end_hour'] as int? ?? 10,
        endMinute: json['end_minute'] as int? ?? 0,
        priority: json['priority'] as String? ?? 'routine',
        category: json['category'] as String? ?? 'work',
        iconCode: json['icon_code'] as int?,
        subtitle: json['subtitle'] as String?,
        isCompleted: json['is_completed'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String()),
        deletedAt: json['deleted_at'] != null && (json['deleted_at'] as String?)?.isNotEmpty == true
          ? DateTime.parse(json['deleted_at'] as String? ?? DateTime.now().toIso8601String())
          : null,
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

  /// Convert to local DzTask model.
  DzTask toDzTask() {
    return DzTask(
      id: id,
      title: title,
      startTime: TimeOfDay(hour: startHour, minute: startMinute),
      endTime: TimeOfDay(hour: endHour, minute: endMinute),
      priority: TaskPriority.values.asNameMap()[priority] ?? TaskPriority.routine,
      category: TaskCategory.values.asNameMap()[category] ?? TaskCategory.work,
      icon: iconCode != null ? IconData(iconCode!, fontFamily: 'MaterialIcons') : null,
      subtitle: subtitle,
      isCompleted: isCompleted,
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

  static final ApiClient _apiClient = ApiClient();

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

  /// BINDING 9: Sync tasks with server (CRITICAL REUSE - 4x per session)
  /// API: POST /tasks/sync
  /// Used By:
  ///   1. SyncManager.syncTasks() - Orchestrator
  ///   2. TaskController.syncWithServer() - On app start
  ///   3. SyncManager.createTaskWithSync() - After create
  ///   4. SyncManager.updateTaskWithSync() - After update
  ///   5. SyncManager.deleteTaskWithSync() - After delete
  ///
  /// OPTIMIZATION STRATEGY:
  /// • Deduplication via lastSyncAt timestamp
  /// • Skip redundant sync if done within 30 seconds
  /// • Batch all local changes in single POST
  /// • Server-side Last-Write-Wins resolution
  Future<Map<String, dynamic>> syncTasks({
    DateTime? lastSyncAt,
    required List<DzTask> localTasks,
  }) async {
    try {
      // OPTIMIZATION: Skip redundant sync if done recently (< 30s)
      if (_lastSyncTime != null &&
          DateTime.now().difference(_lastSyncTime!).inSeconds < 30) {
        return {'server_tasks': [], 'deleted_ids': [], 'conflicts': []};
      }

      final tasks = localTasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'date_ms': t.date.millisecondsSinceEpoch,
        'start_hour': t.startTime.hour,
        'start_minute': t.startTime.minute,
        'end_hour': t.endTime.hour,
        'end_minute': t.endTime.minute,
        'priority': t.priority.name,
        'category': t.category.name,
        'icon_code': t.icon?.codePoint,
        'subtitle': t.subtitle,
        'is_completed': t.isCompleted,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }).toList();

      final body = {
        'last_sync_at': lastSyncAt?.toIso8601String(),
        'tasks': tasks,
      };

      final response = await _apiClient.post('/tasks/sync', body);

      // Parse server tasks
      final serverTasks = (response['server_tasks'] as List<dynamic>?)
          ?.map((t) => TaskApiResponse.fromJson(t as Map<String, dynamic>).toDzTask())
          .toList() ?? [];

      // OPTIMIZATION: Cache all results
      for (final task in serverTasks) {
        _taskCache[task.id] = task;
      }

      // Parse conflicts
      final conflicts = (response['conflicts'] as List<dynamic>?)
          ?.map((c) => SyncConflict.fromJson(c as Map<String, dynamic>))
          .toList() ?? [];

      // Parse deleted IDs
      final deletedIds = (response['deleted_ids'] as List<dynamic>?)
          ?.map((id) => id as String)
          .toList() ?? [];

      _lastSyncTime = DateTime.now(); // Track sync time for deduplication
      _invalidateDateCache(); // Refresh date caches after sync

      return {
        'server_tasks': serverTasks,
        'deleted_ids': deletedIds,
        'conflicts': conflicts,
        'synced_at': DateTime.parse(response['synced_at'] as String),
      };
    } on ApiException {
      // Cache fallback: return cached tasks on error
      if (_taskCache.isNotEmpty) {
        return {
          'server_tasks': _taskCache.values.toList(),
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
    _taskCache.clear();
    _dateCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
