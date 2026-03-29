import 'package:flutter/material.dart';
import 'core/app_prefs.dart';
import 'core/design_system/design_system.dart';
import 'features/auth/login_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/pin/pin_setup_page.dart';
import 'features/pin/pin_unlock_page.dart';
import 'features/shell/main_shell.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final results = await Future.wait([
    AppPrefs.hasSeenOnboarding(),
    AppPrefs.hasPin(),
  ]);
  final seenOnboarding = results[0];
  final hasPin = results[1];

  runApp(DayZenApp(
    showOnboarding: !seenOnboarding,
    hasPin: hasPin,
  ));
}

class DayZenApp extends StatelessWidget {
  final bool showOnboarding;
  final bool hasPin;
  const DayZenApp({
    super.key,
    required this.showOnboarding,
    required this.hasPin,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayZen',
      debugShowCheckedModeBanner: false,
      theme: DzTheme.light,
      darkTheme: DzTheme.dark,
      themeMode: ThemeMode.system,
      home: _resolveHome(),
    );
  }

  Widget _resolveHome() {
    if (showOnboarding) return const _OnboardingRoot();
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




