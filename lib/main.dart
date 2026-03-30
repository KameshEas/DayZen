import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'core/app_prefs.dart';
import 'core/design_system/design_system.dart';
import 'features/app_data.dart';
import 'features/auth/login_page.dart';
import 'features/biometric/biometric_auth_page.dart';
import 'features/journal_controller.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/pin/pin_setup_page.dart';
import 'features/pin/pin_unlock_page.dart';
import 'features/settings/settings_controller.dart';
import 'features/shell/main_shell.dart';
import 'features/task_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskCtrl = TaskController();
  final journalCtrl = JournalController();
  final settingsCtrl = SettingsController();

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

  final results = await Future.wait([
    AppPrefs.hasSeenOnboarding(),
    AppPrefs.hasPin(),
    AppPrefs.isBiometricEnabled(),
    taskCtrl.load(),
    journalCtrl.load(),
    settingsCtrl.load(),
  ]);
  final seenOnboarding = results[0] as bool;
  final hasPin = results[1] as bool;
  // Only use biometric unlock if both the preference is on AND device supports it
  final biometricEnabled = (results[2] as bool) && deviceHasBiometrics;

  runApp(AppData(
    tasks: taskCtrl,
    journal: journalCtrl,
    settings: settingsCtrl,
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
    final settings = AppData.of(context).settings;
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: 'DayZen',
        debugShowCheckedModeBanner: false,
        theme: DzTheme.light,
        darkTheme: DzTheme.dark,
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
      onSignedIn: () => _goToPinSetup(context),
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




