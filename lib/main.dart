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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _runApp();
}

Future<void> _runApp() async {
  // Initialize JWT auth service (restores previous session if available)
  final authService = JwtAuthService();
  await authService.initialize();

  // Initialize Crashlytics for error reporting
  await Firebase.initializeApp();
  _initCrashReporting();

  final taskCtrl = TaskController();
  final journalCtrl = JournalController();
  final settingsCtrl = SettingsController();
  final insightsCtrl = InsightsController();
  final aiOptCtrl = AIOptimizationController();
  final notifCtrl = NotificationController();

  // Check device biometric hardware availability
  final auth = LocalAuthentication();
  bool deviceHasBiometrics;
  try {
    final canCheck = await auth.canCheckBiometrics;
    final isSupported = await auth.isDeviceSupported();
    deviceHasBiometrics = canCheck && isSupported;
  } catch (_) {
    deviceHasBiometrics = false;
  }
  settingsCtrl.setDeviceHasBiometrics(deviceHasBiometrics);

  // Must complete before taskCtrl.load()/journalCtrl.load() below — those
  // read from the new SQLite-backed repositories, and an upgrading user's
  // real data still lives in the old SharedPreferences keys until this
  // runs. See lib/core/data/legacy_data_migrator.dart.
  await LegacyDataMigrator.migrateIfNeeded();

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
  final seenOnboarding = results[0] as bool;
  final hasPin = results[1] as bool;
  // Only use biometric unlock if both the preference is on AND device supports it
  final biometricEnabled = (results[2] as bool) && deviceHasBiometrics;

  // ── Initialise notifications ────────────────────────────────────────
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermission();

  // Wire notifications enabled/disabled based on notification settings
  final notificationsOn = settingsCtrl.quietHours || settingsCtrl.focusAlerts;
  taskCtrl.setNotificationsEnabled(notificationsOn);

  // Initialize router with initial route logic
  AppRouter.initialize(
    showOnboarding: !seenOnboarding,
    hasPin: hasPin,
    biometricEnabled: biometricEnabled,
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