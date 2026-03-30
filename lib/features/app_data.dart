import 'package:flutter/material.dart';
import 'task_controller.dart';
import 'journal_controller.dart';
import 'settings/settings_controller.dart';

/// Provides [TaskController], [JournalController] and [SettingsController]
/// to the entire widget tree.
///
/// Access via [AppData.of(context)].
class AppData extends InheritedWidget {
  const AppData({
    super.key,
    required this.tasks,
    required this.journal,
    required this.settings,
    required super.child,
  });

  final TaskController tasks;
  final JournalController journal;
  final SettingsController settings;

  static AppData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppData>()!;

  @override
  bool updateShouldNotify(AppData old) =>
      tasks != old.tasks || journal != old.journal || settings != old.settings;
}
