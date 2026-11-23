import 'dart:async';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'core/app_prefs.dart';
import 'l10n/app_localizations.dart';
import 'core/data/legacy_data_migrator.dart';
import 'core/design_system/design_system.dart';
import 'core/notification_service.dart';
import 'core/routing/app_router.dart';
import 'core/services/analytics_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'core/services/jwt_auth_service.dart';
import 'core/api/api_client.dart';
import 'core/services/app_version_service.dart';
import 'core/services/gentle_prompts.dart';
import 'core/services/sync_triggers.dart';
import 'core/services/widget_service.dart';
import 'features/app_data.dart';
import 'features/app_update/app_version_controller.dart';
import 'features/journal_controller.dart';
import 'features/notification_controller.dart';
import 'features/rhythm/rhythm_controller.dart';
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
  final rhythmCtrl = RhythmController();

  // Constructed synchronously, before Firebase.initializeApp() below —
  // AppVersionService reads AnalyticsService.instance lazily, only once it
  // actually logs an event, so this is safe. AppRouter needs the controller
  // up front so it can redirect the moment a forced update is detected,
  // however long the rest of bootstrap takes.
  final appVersionCtrl = AppVersionController(AppVersionService(ApiClient()))..init();

  AppRouter.initialize(
    startRoute: _bootstrap(
      taskCtrl: taskCtrl,
      journalCtrl: journalCtrl,
      settingsCtrl: settingsCtrl,
      notifCtrl: notifCtrl,
      rhythmCtrl: rhythmCtrl,
      appVersionCtrl: appVersionCtrl,
    ),
    appVersionController: appVersionCtrl,
  );

  runApp(AppScopes(
    tasks: taskCtrl,
    journal: journalCtrl,
    settings: settingsCtrl,
    notifications: notifCtrl,
    rhythm: rhythmCtrl,
    child: const DayZenApp(),
  ));
}

Future<String> _bootstrap({
  required TaskController taskCtrl,
  required JournalController journalCtrl,
  required SettingsController settingsCtrl,
  required NotificationController notifCtrl,
  required RhythmController rhythmCtrl,
  required AppVersionController appVersionCtrl,
}) async {
  // The shared singleton — every JwtAuthService.instance call site across
  // the app (ApiClient's default, AuthController, SettingsController, ...)
  // sees the same session once it's initialized here.
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
    // Crash reporting and analytics are optional: a missing/invalid Firebase
    // config (e.g. no GoogleService-Info.plist on iOS yet) must not abort
    // startup, which is what happened when this threw inside Future.wait.
    Firebase.initializeApp()
        .then((_) {
          _initCrashReporting();
          return AnalyticsService.instance.init();
        })
        .catchError((Object e) => debugPrint('Firebase services disabled: $e')),
    LegacyDataMigrator.migrateIfNeeded(),
  ]);
  settingsCtrl.setDeviceHasBiometrics(await hasBiometrics);

  // Fire-and-forget: a slow or failed remote-config check must never delay
  // first paint. If it later flags a forced update, the router's
  // refreshListenable redirects the user to it from wherever they are.
  unawaited(appVersionCtrl.refresh());

  final results = await Future.wait([
    AppPrefs.hasSeenOnboarding(),
    AppPrefs.hasPin(),
    AppPrefs.isBiometricEnabled(),
    AppPrefs.isOnboardingV2Done(),
    AppPrefs.onboardingVariant(),
    taskCtrl.load(),
    journalCtrl.load(),
    settingsCtrl.load(),
    notifCtrl.load(),
  ]);
  // Only ever written once; the Planner lets you browse back to this day.
  await AppPrefs.recordFirstUse();
  // Rhythm learns from tasks as they change (done, carried, let go).
  await rhythmCtrl.load(taskCtrl.all);
  taskCtrl.addListener(() => rhythmCtrl.updateTasks(taskCtrl.all));
  // Home-screen widget (M-3.2): today's/tomorrow's tasks and the tide.
  WidgetService.instance.update(tasks: taskCtrl.all, profile: rhythmCtrl.profile);
  taskCtrl.addListener(() => WidgetService.instance.update(tasks: taskCtrl.all));
  rhythmCtrl.addListener(
      () => WidgetService.instance.update(profile: rhythmCtrl.profile));
  final seenOnboarding = results[0] as bool;
  final hasPin = results[1] as bool;
  // Only use biometric unlock if both the preference is on AND device supports it
  final biometricEnabled = (results[2] as bool) && await hasBiometrics;
  final onboardingV2Done = results[3] as bool;
  final variant = results[4] as String;
  AppRouter.onboardingVariant = variant;

  await NotificationService.instance.init();
  // Onboarding v2 (and installs that went through it) never get a system
  // dialog at startup: the permission is asked after "Yes" to the gentle
  // nudge, or when reminders are turned on in Settings (M-1.7). The v1
  // flow and older installs keep the old behaviour. The prompt waits on
  // the user, so never block startup on it.
  final v2Flow = onboardingV2Done || (!seenOnboarding && variant == 'v2');
  if (!v2Flow) {
    unawaited(NotificationService.instance.requestPermission());
  }

  taskCtrl.applyReminderSettings(
    enabled: settingsCtrl.remindersEnabled,
    quietWindow: settingsCtrl.quietWindow,
  );

  // Evening Close the Day prompt and energy check-ins (own switches).
  GentlePrompts.instance ??= GentlePrompts(settings: settingsCtrl);
  unawaited(GentlePrompts.instance!.apply());

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
      // First resume after midnight carries unfinished tasks to today; on
      // other resumes it finds nothing to move. It pulls before rolling
      // over, so it also covers the usual resume sync for tasks.
      unawaited(taskCtrl.syncThenRollOver());
      // A new day means new check-in times.
      unawaited(GentlePrompts.instance?.apply());
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
    isSignedIn: authService.isAuthenticated,
    onboardingV2Done: onboardingV2Done,
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
