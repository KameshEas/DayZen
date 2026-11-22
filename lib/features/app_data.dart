import 'package:flutter/material.dart';
import 'task_controller.dart';
import 'journal_controller.dart';
import 'settings/settings_controller.dart';
import 'notification_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Per-controller scopes
//
// Replaces the single `AppData` InheritedWidget that used to wrap all six
// controllers together. With one shared InheritedWidget, a widget calling
// `AppData.of(context)` — even for just `.tasks` — created a dependency on
// the *whole* AppData object, so any of the six controllers changing would
// be a candidate to rebuild every dependent (in practice this app's
// controllers are only ever mutated in place via ChangeNotifier, not
// replaced, so `AppData.updateShouldNotify`'s reference-equality check
// mostly no-opped — but it was a latent footgun, not a guarantee, and
// exactly the kind of thing that bites later as the app grows).
//
// Each `InheritedNotifier` below wraps exactly one controller. A widget
// depending on `TaskScope` only rebuilds when `TaskController` itself calls
// `notifyListeners()` — a `SettingsController` change is invisible to it.
// test/features/app_data_test.dart verifies this automatically.
// ─────────────────────────────────────────────────────────────────────────────

class TaskScope extends InheritedNotifier<TaskController> {
  const TaskScope({
    super.key,
    required TaskController controller,
    required super.child,
  }) : super(notifier: controller);

  static TaskController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<TaskScope>()!
      .notifier!;
}

class JournalScope extends InheritedNotifier<JournalController> {
  const JournalScope({
    super.key,
    required JournalController controller,
    required super.child,
  }) : super(notifier: controller);

  static JournalController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<JournalScope>()!
      .notifier!;
}

class SettingsScope extends InheritedNotifier<SettingsController> {
  const SettingsScope({
    super.key,
    required SettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static SettingsController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<SettingsScope>()!
      .notifier!;
}

class NotificationScope extends InheritedNotifier<NotificationController> {
  const NotificationScope({
    super.key,
    required NotificationController controller,
    required super.child,
  }) : super(notifier: controller);

  static NotificationController of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NotificationScope>()!
      .notifier!;
}

/// Composes the per-controller scopes into one widget so `main.dart`'s
/// app-root wiring reads the same as it did with the single `AppData`
/// widget, despite nesting separate `InheritedNotifier`s under the hood.
class AppScopes extends StatelessWidget {
  const AppScopes({
    super.key,
    required this.tasks,
    required this.journal,
    required this.settings,
    required this.notifications,
    required this.child,
  });

  final TaskController tasks;
  final JournalController journal;
  final SettingsController settings;
  final NotificationController notifications;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TaskScope(
      controller: tasks,
      child: JournalScope(
        controller: journal,
        child: SettingsScope(
          controller: settings,
          child: NotificationScope(
            controller: notifications,
            child: child,
          ),
        ),
      ),
    );
  }
}
