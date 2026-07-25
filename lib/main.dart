import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'core/app_prefs.dart';
import 'core/data/legacy_data_migrator.dart';
import 'core/design_system/design_system.dart';
import 'core/notification_service.dart';
import 'features/app_data.dart';
import 'features/auth/login_page.dart';
import 'features/biometric/biometric_auth_page.dart';
import 'features/journal_controller.dart';
import 'features/insights_controller.dart';
import 'features/ai_optimization_controller.dart';
import 'features/notification_controller.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/pin/pin_setup_page.dart';
import 'features/pin/pin_unlock_page.dart';
import 'features/settings/settings_controller.dart';
import 'features/shell/main_shell.dart';
import 'features/task_controller.dart';

void main() {
  // Wrapped in runZonedGuarded so crashes during bootstrap — before
  // Crashlytics' own error hooks are wired below — are still caught and
  // reported rather than silently killing the app with no record.
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await _initCrashReporting();
    await _runApp();
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Wires Flutter framework errors and uncaught platform errors to
/// Crashlytics. Collection is left enabled in debug builds too (not just
/// release) so the Phase 1 "trigger a test crash, confirm it in console"
/// verification step actually works during development; revisit once the
/// team wants a quieter debug Crashlytics console.
Future<void> _initCrashReporting() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> _runApp() async {
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

  runApp(AppScopes(
    tasks: taskCtrl,
    journal: journalCtrl,
    settings: settingsCtrl,
    insights: insightsCtrl,
    aiOptimization: aiOptCtrl,
    notifications: notifCtrl,
    child: DayZenApp(
      showOnboarding: !seenOnboarding,
      hasPin: hasPin,
      biometricEnabled: biometricEnabled,
    ),
  ));
}

class DayZenApp extends StatelessWidget {
  final bool showOnboarding;
  final bool hasPin;
  final bool biometricEnabled;
  const DayZenApp({
    super.key,
    required this.showOnboarding,
    required this.hasPin,
    required this.biometricEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context);
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'DayZen',
        debugShowCheckedModeBanner: false,
        theme: DzTheme.light(accent: settings.accentColor),
        darkTheme: DzTheme.dark(accent: settings.accentColor),
        themeMode: settings.themeMode,
        home: _resolveHome(),
      ),
    );
  }

  Widget _resolveHome() {
    if (showOnboarding) return const _OnboardingRoot();
    // Biometric takes priority over PIN
    if (biometricEnabled) return const _BiometricUnlockRoot();
    if (hasPin) return const _PinUnlockRoot();
    return const _AuthRoot();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Onboarding → Auth flow (first-time users)
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingRoot extends StatelessWidget {
  const _OnboardingRoot();

  void _finishOnboarding(BuildContext context) {
    AppPrefs.markOnboardingSeen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _AuthRoot()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      onDone: () => _finishOnboarding(context),
      onEnableSync: () => _finishOnboarding(context),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth root — shown when no PIN exists yet
// After sign-in, push PIN setup; skip goes straight to home.
// ─────────────────────────────────────────────────────────────────────────────

class _AuthRoot extends StatelessWidget {
  const _AuthRoot();

  void _goToPinSetup(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PinSetupPage(
          onPinSet: (ctx) => _goToHome(ctx),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      onSignedIn: (email) {
        SettingsScope.of(context).setSignedIn(true, email);
        _goToPinSetup(context);
      },
      onContinueOffline: () {
        // Offline users also prompted to set a PIN
        _goToPinSetup(context);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Biometric unlock root — shown when biometric is enabled
// ─────────────────────────────────────────────────────────────────────────────

class _BiometricUnlockRoot extends StatelessWidget {
  const _BiometricUnlockRoot();

  @override
  Widget build(BuildContext context) {
    return BiometricAuthPage(
      onAuthenticated: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      },
      onFallbackToPin: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const _PinUnlockRoot(),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PIN unlock root — shown on every subsequent cold start
// ─────────────────────────────────────────────────────────────────────────────

class _PinUnlockRoot extends StatelessWidget {
  const _PinUnlockRoot();

  @override
  Widget build(BuildContext context) {
    return PinUnlockPage(
      onUnlocked: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      },
    );
  }
}




