import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'core/app_prefs.dart';
import 'l10n/app_localizations.dart';
import 'core/data/legacy_data_migrator.dart';
import 'core/design_system/design_system.dart';
import 'core/notification_service.dart';
import 'core/routing/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'core/services/jwt_auth_service.dart';
import 'features/app_data.dart';
import 'features/journal_controller.dart';
import 'features/insights_controller.dart';
import 'features/ai_optimization_controller.dart';
import 'features/notification_controller.dart';
import 'features/settings/settings_controller.dart';
import 'features/task_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _runApp();
}

/// Shows the splash immediately; all slow startup work (auth restore,
/// Firebase, DB migration/loading, notifications) runs behind it in
/// [_bootstrap], and the splash navigates once its animation and the
/// bootstrap have both finished.
void _runApp() {
  final taskCtrl = TaskController();
  final journalCtrl = JournalController();
  final settingsCtrl = SettingsController();
  final insightsCtrl = InsightsController();
  final aiOptCtrl = AIOptimizationController();
  final notifCtrl = NotificationController();

  AppRouter.initialize(
    startRoute: _bootstrap(
      taskCtrl: taskCtrl,
      journalCtrl: journalCtrl,
      settingsCtrl: settingsCtrl,
      insightsCtrl: insightsCtrl,
      aiOptCtrl: aiOptCtrl,
      notifCtrl: notifCtrl,
    ),
  );

  runApp(AppScopes(
    tasks: taskCtrl,
    journal: journalCtrl,
    settings: settingsCtrl,
    insights: insightsCtrl,
    aiOptimization: aiOptCtrl,
    notifications: notifCtrl,
    child: const DayZenApp(),
  ));
}

Future<String> _bootstrap({
  required TaskController taskCtrl,
  required JournalController journalCtrl,
  required SettingsController settingsCtrl,
  required InsightsController insightsCtrl,
  required AIOptimizationController aiOptCtrl,
  required NotificationController notifCtrl,
}) async {
  final authService = JwtAuthService.instance;

  Future<bool> deviceHasBiometrics() async {
    final auth = LocalAuthentication();
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  // These are independent of each other, so run them in parallel. The legacy
  // migration must finish before the controllers load (see below).
  final hasBiometrics = deviceHasBiometrics();
  await Future.wait([
    authService.initialize(),
    Firebase.initializeApp().then((_) => _initCrashReporting()),
    LegacyDataMigrator.migrateIfNeeded(),
  ]);
  settingsCtrl.setDeviceHasBiometrics(await hasBiometrics);

  final results = await Future.wait([
    AppPrefs.hasSeenOnboarding(),
    AppPrefs.hasPin(),
    AppPrefs.isBiometricEnabled(),
    taskCtrl.load(),
    journalCtrl.load(),
    settingsCtrl.load(),
    insightsCtrl.load(),
    aiOptCtrl.load(),
    notifCtrl.load(),
  ]);
  // Only ever written once; the Planner lets you browse back to this day.
  await AppPrefs.recordFirstUse();
  final seenOnboarding = results[0] as bool;
  final hasPin = results[1] as bool;
  final biometricEnabled = (results[2] as bool) && await hasBiometrics;

  await NotificationService.instance.init();
  // The permission prompt waits on the user, so never block startup on it.
  unawaited(NotificationService.instance.requestPermission());

  final notificationsOn = settingsCtrl.quietHours || settingsCtrl.focusAlerts;
  taskCtrl.setNotificationsEnabled(notificationsOn);

  return AppRouter.resolveInitialRoute(
    showOnboarding: !seenOnboarding,
    hasPin: hasPin,
    biometricEnabled: biometricEnabled,
  );
}

void _initCrashReporting() {
  // Pass all uncaught errors from the Flutter framework to Crashlytics.
  FlutterError.onError = (error) => FirebaseCrashlytics.instance.recordFlutterError(error);

  // Pass all uncaught asynchronous errors that aren't handled by Flutter to Crashlytics
  foundation.PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class DayZenApp extends StatelessWidget {
  const DayZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp.router(
        title: 'DayZen',
        debugShowCheckedModeBanner: false,
        theme: DzTheme.light(accent: settings.accentColor),
        darkTheme: DzTheme.dark(accent: settings.accentColor),
        themeMode: settings.themeMode,
        routerConfig: AppRouter.router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}