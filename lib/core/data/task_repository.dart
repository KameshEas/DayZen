import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../features/home/models/task_model.dart';
import 'database/app_database.dart';
import 'database/daos/task_dao.dart';
import 'database/database_provider.dart';

/// Task persistence, backed by SQLite (via drift) — see
/// docs/DATABASE_SCHEMA.md. Each method here is a single-row operation;
/// there is deliberately no `save(List<DzTask>)` full-list-rewrite method
/// anymore (that was the Phase 2 scalability problem — see
/// docs/BASELINE_METRICS.md).
class TaskRepository {
  static TaskDao get _dao => DatabaseProvider.instance.taskDao;

  /// All active (non soft-deleted) tasks.
  static Future<List<DzTask>> loadAll() async {
    final rows = await _dao.getAllActive();
    return rows.map(_fromRow).toList();
  }

  static Future<void> insertTask(DzTask task) {
    return _dao.insertTask(_toCompanion(task));
  }

  /// Full-row update, keyed by [DzTask.id].
  static Future<void> updateTask(DzTask task) {
    return _dao.updateTaskRow(task.id, _toCompanion(task));
  }

  /// Soft delete — see [TaskDao.softDeleteTask].
  static Future<void> deleteTask(String id) {
    return _dao.softDeleteTask(id);
  }

  /// Hard delete every row. Used only by the Settings "clear all data"
  /// action, via `TaskController.clearAll()`.
  static Future<void> clearAll() {
    return _dao.hardDeleteAll();
  }

  static DzTask _fromRow(TaskRow row) => DzTask(
        id: row.id,
        title: row.title,
        startTime: TimeOfDay(hour: row.startHour, minute: row.startMinute),
        endTime: TimeOfDay(hour: row.endHour, minute: row.endMinute),
        priority: TaskPriority.values.byName(row.priority),
        category: TaskCategory.values.byName(row.category),
        icon: row.iconCodePoint != null
            ? IconData(row.iconCodePoint!, fontFamily: 'MaterialIcons')
            : null,
        subtitle: row.subtitle,
        isCompleted: row.isCompleted,
        date: row.date,
      );

  static TasksCompanion _toCompanion(DzTask task) => TasksCompanion(
        id: Value(task.id),
        title: Value(task.title),
        startHour: Value(task.startTime.hour),
        startMinute: Value(task.startTime.minute),
        endHour: Value(task.endTime.hour),
        endMinute: Value(task.endTime.minute),
        priority: Value(task.priority.name),
        category: Value(task.category.name),
        iconCodePoint: Value(task.icon?.codePoint),
        subtitle: Value(task.subtitle),
        isCompleted: Value(task.isCompleted),
        date: Value(task.date),
        updatedAt: Value(DateTime.now()),
        dirty: const Value(true),
      );
}
