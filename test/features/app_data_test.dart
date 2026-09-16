import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/features/ai_optimization_controller.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/insights_controller.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';

/// Test-only subclasses exposing a way to fire a change notification
/// without going through a real mutator (which would touch SQLite/
/// Firebase/notification plugins — out of scope for what this test is
/// verifying, which is purely the InheritedNotifier scoping mechanism).
class _FireableTaskController extends TaskController {
  void fireChange() => notifyListeners();
}

class _FireableSettingsController extends SettingsController {
  void fireChange() => notifyListeners();
}

void main() {
  // Phase 3.3 of docs/DEVELOPMENT_PLAN.md called for verifying, via the
  // DevTools widget-rebuild profiler, that a settings change no longer
  // triggers task-list widget rebuilds. A live DevTools session isn't
  // available in this environment, so this widget test is the automated
  // substitute — and arguably a stronger, repeatable proof than a one-off
  // manual DevTools inspection, since it runs on every `flutter test`.
  testWidgets(
    'a widget scoped to TaskScope only rebuilds on TaskController changes, '
    'not on SettingsController changes',
    (tester) async {
      final taskCtrl = _FireableTaskController();
      final settingsCtrl = _FireableSettingsController();
      final journalCtrl = JournalController();
      final insightsCtrl = InsightsController();
      final aiCtrl = AIOptimizationController();
      final notifCtrl = NotificationController();

      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AppScopes(
            tasks: taskCtrl,
            journal: journalCtrl,
            settings: settingsCtrl,
            insights: insightsCtrl,
            aiOptimization: aiCtrl,
            notifications: notifCtrl,
            child: Builder(
              builder: (context) {
                TaskScope.of(context); // depends on TaskScope ONLY
                buildCount++;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1, reason: 'initial build');

      // A SettingsController-only change must NOT rebuild a widget scoped
      // to TaskScope — this is the entire point of the Phase 3.3 split.
      settingsCtrl.fireChange();
      await tester.pump();
      expect(buildCount, 1,
          reason: 'SettingsController change should not trigger a rebuild '
              'of a widget depending only on TaskScope');

      // A TaskController change MUST rebuild it.
      taskCtrl.fireChange();
      await tester.pump();
      expect(buildCount, 2,
          reason: 'TaskController change should trigger a rebuild of a '
              'widget depending on TaskScope');
    },
  );

  testWidgets(
    'AppScopes exposes all six controllers via their respective scopes',
    (tester) async {
      final taskCtrl = TaskController();
      final journalCtrl = JournalController();
      final settingsCtrl = SettingsController();
      final insightsCtrl = InsightsController();
      final aiCtrl = AIOptimizationController();
      final notifCtrl = NotificationController();

      late BuildContext capturedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: AppScopes(
            tasks: taskCtrl,
            journal: journalCtrl,
            settings: settingsCtrl,
            insights: insightsCtrl,
            aiOptimization: aiCtrl,
            notifications: notifCtrl,
            child: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(TaskScope.of(capturedContext), same(taskCtrl));
      expect(JournalScope.of(capturedContext), same(journalCtrl));
      expect(SettingsScope.of(capturedContext), same(settingsCtrl));
      expect(InsightsScope.of(capturedContext), same(insightsCtrl));
      expect(AIOptimizationScope.of(capturedContext), same(aiCtrl));
      expect(NotificationScope.of(capturedContext), same(notifCtrl));
    },
  );
}
