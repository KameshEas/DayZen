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
import 'core/services/sync_triggers.dart';
import 'features/app_data.dart';
import 'features/journal_controller.dart';
import 'features/notification_controller.dart';
import 'features/settings/settings_controller.dart';
import 'features/task_controller.dart';

AppLifecycleListener? _lifecycleListener;
SyncTriggers? _syncTriggers;

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
  final notifCtrl = NotificationController();

  AppRouter.initialize(
    startRoute: _bootstrap(
      taskCtrl: taskCtrl,
      journalCtrl: journalCtrl,
      settingsCtrl: settingsCtrl,
      notifCtrl: notifCtrl,
    ),
  );

  runApp(AppScopes(
    tasks: taskCtrl,
    journal: journalCtrl,
    settings: settingsCtrl,
    notifications: notifCtrl,
    child: const DayZenApp(),
  ));
}

Future<String> _bootstrap({
  required TaskController taskCtrl,
  required JournalController journalCtrl,
  required SettingsController settingsCtrl,
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
    // Crash reporting is optional: a missing/invalid Firebase config (e.g. no
    // GoogleService-Info.plist on iOS yet) must not abort startup, which is
    // what happened when this threw inside Future.wait.
    Firebase.initializeApp()
        .then((_) => _initCrashReporting())
        .catchError((Object e) => debugPrint('Crash reporting disabled: $e')),
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

  taskCtrl.applyReminderSettings(
    enabled: settingsCtrl.remindersEnabled,
    quietWindow: settingsCtrl.quietWindow,
  );

  // Travel or a zone change while backgrounded moves every reminder's real
  // time; re-check the zone whenever the app comes back to the foreground.
  // Pull the account's data right after sign-in and whenever the app comes
  // back to the foreground (see SyncTriggers).
  _syncTriggers ??= SyncTriggers(
    auth: authService,
    isSignedIn: () => authService.isAuthenticated,
    syncAll: () => Future.wait([
      taskCtrl.syncWithServer(),
      journalCtrl.syncWithServer(),
      notifCtrl.load(),
    ]),
  )..attach();

  _lifecycleListener ??= AppLifecycleListener(
    onResume: () async {
      _syncTriggers?.onResume();
      if (await NotificationService.instance.refreshTimeZone()) {
        await taskCtrl.rescheduleNotifications();
      }
    },
  );

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