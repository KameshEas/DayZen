import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/sign_up_page.dart';
import '../../features/biometric/biometric_auth_page.dart';
import '../../features/debug/test_notification_page.dart';
import '../../features/home/home_page.dart';
import '../../features/insights/insights_page.dart';
import '../../features/journal/journal_page.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/pin/pin_setup_page.dart';
import '../../features/pin/pin_unlock_page.dart';
import '../../features/planner/planner_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/main_shell.dart';
import '../../features/tasks/new_task_page.dart';
import '../../features/tasks/task_detail_page.dart';
import '../../features/journal/journal_detail_page.dart';
import 'route_paths.dart';

/// Global router instance, initialized post-app-setup in main.dart
GoRouter? _appRouter;

class AppRouter {
  static void initialize({
    required bool showOnboarding,
    required bool hasPin,
    required bool biometricEnabled,
  }) {
    _appRouter = GoRouter(
      initialLocation: _resolveInitialRoute(
        showOnboarding: showOnboarding,
        hasPin: hasPin,
        biometricEnabled: biometricEnabled,
      ),
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Route not found: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: Text(AppConfig.routerGoHome),
              ),
            ],
          ),
        ),
      ),
      routes: [
        // ── Auth / Onboarding flow ──────────────────────────────────────
        GoRoute(
          path: RoutePaths.onboarding,
          name: RouteNames.onboarding,
          builder: (context, state) => OnboardingPage(
            // "Start Offline" — true offline path, skip the login wall
            // entirely and go straight to securing the app with a PIN.
            onDone: () {
              AppPrefs.markOnboardingSeen();
              context.go('/pin-setup');
            },
            // "Enable Sync (Optional)" — routes through Login/Sign Up,
            // where an account can be created to enable cloud sync
            // (Login itself still offers a "Continue Offline" fallback).
            onEnableSync: () {
              AppPrefs.markOnboardingSeen();
              context.go(RoutePaths.login);
            },
          ),
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => LoginPage(
            onSignedIn: (email) {
              // After sign-in, user must set up a PIN
              context.go('/pin-setup');
            },
            onContinueOffline: () {
              // Offline users also must set up a PIN
              context.go('/pin-setup');
            },
          ),
        ),
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (context, state) => SignUpPage(
            onSignedUp: (email) {
              context.go('/pin-setup');
            },
            onContinueOffline: () {
              context.go('/pin-setup');
            },
          ),
        ),
        // ── Biometric unlock flow ───────────────────────────────────────
        GoRoute(
          path: '/biometric-unlock',
          builder: (context, state) => BiometricAuthPage(
            onAuthenticated: () {
              context.go(RoutePaths.home);
            },
            onFallbackToPin: () {
              context.go('/pin-unlock');
            },
          ),
        ),

        // ── PIN setup / unlock flow ─────────────────────────────────────
        GoRoute(
          path: '/pin-setup',
          builder: (context, state) => PinSetupPage(
            onPinSet: (ctx) {
              context.go(RoutePaths.home);
            },
          ),
        ),
        GoRoute(
          path: '/pin-unlock',
          builder: (context, state) => PinUnlockPage(
            onUnlocked: () {
              context.go(RoutePaths.home);
            },
          ),
        ),

        // ── Main app shell with tab navigation ──────────────────────────
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: RoutePaths.planner,
              name: RouteNames.planner,
              builder: (context, state) => const PlannerPage(),
            ),
            GoRoute(
              path: RoutePaths.insights,
              name: RouteNames.insights,
              builder: (context, state) => const InsightsPage(),
            ),
            GoRoute(
              path: RoutePaths.journal,
              name: RouteNames.journal,
              builder: (context, state) => const JournalPage(),
            ),
          ],
        ),

        // ── Modal routes (New Task, Settings, etc.) ─────────────────────
        GoRoute(
          path: RoutePaths.newTask,
          name: RouteNames.newTask,
          builder: (context, state) => const NewTaskPage(),
        ),
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),

        // ── Task detail ────────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.taskDetail,
          name: RouteNames.taskDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return TaskDetailPage(taskId: id);
          },
        ),

        // ── Journal detail ────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.journalDetail,
          name: RouteNames.journalDetail,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return JournalDetailPage(journalId: id);
          },
        ),

        // ── Debug routes (test page) ────────────────────────────────────
        GoRoute(
          path: '/debug/test-notification',
          builder: (context, state) => const TestNotificationPage(),
        ),
      ],
    );
  }

  static GoRouter get router {
    if (_appRouter == null) {
      throw StateError(
        'AppRouter not initialized. Call AppRouter.initialize(...) in main() before runApp().',
      );
    }
    return _appRouter!;
  }

  static String _resolveInitialRoute({
    required bool showOnboarding,
    required bool hasPin,
    required bool biometricEnabled,
  }) {
    if (showOnboarding) return RoutePaths.onboarding;
    if (biometricEnabled) return '/biometric-unlock';
    if (hasPin) return '/pin-unlock';
    return RoutePaths.login;
  }
}