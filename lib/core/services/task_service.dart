/// Service for task management with cloud sync and offline support.
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
    return TaskApiResponse(
      id: json['id'] as String,
      title: json['title'] as String,
      dateMs: DateTime.parse(json['date_ms'].toString()),
      startHour: json['start_hour'] as int,
      startMinute: json['start_minute'] as int,
      endHour: json['end_hour'] as int,
      endMinute: json['end_minute'] as int,
      priority: json['priority'] as String? ?? 'routine',
      category: json['category'] as String? ?? 'work',
      iconCode: json['icon_code'] as int?,
      subtitle: json['subtitle'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
        ? DateTime.parse(json['deleted_at'] as String)
        : null,
    );
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
      taskId: json['id'] as String,
      resolution: json['resolution'] as String,
    );
  }
}

/// Service for task API operations.
class TaskService {
  TaskService._();

  static final TaskService _instance = TaskService._();

  static TaskService get instance => _instance;

  static final ApiClient _apiClient = ApiClient();

  // Cache
  final Map<String, DzTask> _taskCache = {};
  DateTime? _lastSyncTime;

  /// List tasks with optional filters.
  Future<List<DzTask>> listTasks({
    DateTime? date,
    DateTime? since,
  }) async {
    try {
      final params = <String, String>{};
      if (date != null) {
        params['date'] = date.toIso8601String().split('T').first;
      }
      if (since != null) {
        params['since'] = since.toIso8601String();
      }

      String endpoint = '/tasks';
      if (params.isNotEmpty) {
        endpoint += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await _apiClient.get(endpoint);
      final tasks = (response['tasks'] as List<dynamic>?)
          ?.map((t) => TaskApiResponse.fromJson(t as Map<String, dynamic>).toDzTask())
          .toList() ?? [];

      // Cache the tasks
      for (final task in tasks) {
        _taskCache[task.id] = task;
      }

      return tasks;
    } on ApiException {
      // Return cached tasks if available
      if (_taskCache.isNotEmpty) {
        return _taskCache.values.toList();
      }
      rethrow;
    }
  }

  /// Create a new task.
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
      return localTask;
    } on ApiException {
      rethrow;
    }
  }

  /// Update an existing task.
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
      return localTask;
    } on ApiException {
      rethrow;
    }
  }

  /// Delete a task (soft delete on server).
  Future<void> deleteTask(String taskId) async {
    try {
      await _apiClient.delete('/tasks/$taskId');
      _taskCache.remove(taskId);
    } on ApiException {
      rethrow;
    }
  }

  /// Sync tasks with server (last-write-wins conflict resolution).
  Future<Map<String, dynamic>> syncTasks({
    DateTime? lastSyncAt,
    required List<DzTask> localTasks,
  }) async {
    try {
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

      // Cache server tasks
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

      _lastSyncTime = DateTime.now();

      return {
        'server_tasks': serverTasks,
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
    _taskCache.clear();
    _lastSyncTime = null;
  }

  /// Get error message.
  static String getErrorMessage(ApiException exception) {
    return ApiClient.getUserErrorMessage(exception);
  }
}
