import 'package:flutter/material.dart';
import 'task_controller.dart';
import 'journal_controller.dart';
import 'settings/settings_controller.dart';
import 'insights_controller.dart';
import 'ai_optimization_controller.dart';
import 'notification_controller.dart';

/// Provides all app controllers to the entire widget tree.
///
/// Access via [AppData.of(context)].
class AppData extends InheritedWidget {
  const AppData({
    super.key,
    required this.tasks,
    required this.journal,
    required this.settings,
    required this.insights,
    required this.aiOptimization,
    required this.notifications,
    required super.child,
  });

  final TaskController tasks;
  final JournalController journal;
  final SettingsController settings;
  final InsightsController insights;
  final AIOptimizationController aiOptimization;
  final NotificationController notifications;

  static AppData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppData>()!;

  @override
  bool updateShouldNotify(AppData old) =>
      tasks != old.tasks ||
      journal != old.journal ||
      settings != old.settings ||
      insights != old.insights ||
      aiOptimization != old.aiOptimization ||
      notifications != old.notifications;
}
