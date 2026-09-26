import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../core/services/user_service.dart';
import '../../features/app_update/app_version_controller.dart';
import '../../features/app_update/update_showcase_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/sign_up_page.dart';
import '../../features/biometric/biometric_auth_page.dart';
import '../../features/debug/test_notification_page.dart';
import '../../features/home/home_page.dart';
import '../../features/insights/insights_page.dart';
import '../../features/journal/journal_page.dart';
import '../../features/maintenance/maintenance_screen.dart';
import '../../features/onboarding/widgets/onboarding_page_animated.dart';
import '../design_system/design_system.dart';
import '../../features/pin/pin_setup_page.dart';
import '../../features/pin/pin_unlock_page.dart';
import '../../features/planner/planner_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_page.dart';
import '../../features/tasks/new_task_page.dart';
import '../../features/tasks/task_detail_page.dart';
import '../../features/journal/journal_detail_page.dart';
import 'route_paths.dart';

/// Global router instance, initialized post-app-setup in main.dart
GoRouter? _appRouter;
AppVersionController? _appVersionController;

class AppRouter {
  /// [startRoute] resolves once app bootstrap (storage, controllers, etc.)
  /// finishes; the splash waits for both its animation and this future.
  static void initialize({
    required Future<String> startRoute,
    required AppVersionController appVersionController,
  }) {
    _appVersionController = appVersionController;
    _appRouter = GoRouter(
      initialLocation: RoutePaths.splash,
      refreshListenable: appVersionController,
      redirect: (context, state) {
        // Checked first: if the backend itself is down for maintenance,
        // that's the more urgent condition — showing "update required" when
        // the backend can't even serve the update check would be confusing.
        if (appVersionController.maintenanceActive &&
            state.matchedLocation != RoutePaths.maintenance) {
          return RoutePaths.maintenance;
        }
        if (appVersionController.forceUpdateRequired &&
            state.matchedLocation != RoutePaths.forceUpdate) {
          return RoutePaths.forceUpdate;
        }
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Route not found: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text(AppConfig.routerGoHome),
              ),
            ],
          ),
        ),
      ),
      routes: [
        // ── Animated splash → resolved start route ──────────────────────
        GoRoute(
          path: RoutePaths.splash,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SplashPage(
              onFinished: () {
                final router = GoRouter.of(context);
                startRoute.then(router.go, onError: (Object e) {
                  debugPrint('Bootstrap failed: $e');
                  router.go(RoutePaths.login);
                });
              },
            ),
          ),
        ),
        // ── Auth / Onboarding flow ──────────────────────────────────────
        GoRoute(
          path: RoutePaths.onboarding,
          name: RouteNames.onboarding,
          // Onboarding art and gradient are light-only, so pin the light brand theme.
          builder: (context, state) => Theme(
            data: DzTheme.light(),
            child: AnimatedOnboardingPage(
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
        ),
        GoRoute(
          path: RoutePaths.login,
          name: RouteNames.login,
          builder: (context, state) => LoginPage(
            onSignedIn: (email) => _routeAfterAuth(context),
            onContinueOffline: () => _routeAfterAuth(context),
          ),
        ),
        GoRoute(
          path: RoutePaths.signup,
          name: RouteNames.signup,
          builder: (context, state) => SignUpPage(
            onSignedUp: (email) => _routeAfterAuth(context),
            onContinueOffline: () => _routeAfterAuth(context),
          ),
        ),
        // ── Forced update showcase ───────────────────────────────────────
        GoRoute(
          path: RoutePaths.forceUpdate,
          name: RouteNames.forceUpdate,
          builder: (context, state) => UpdateShowcasePage(
            versionConfig: _appVersionController!.config!,
            versionService: _appVersionController!.versionService,
          ),
        ),

        // ── Maintenance block ────────────────────────────────────────────
        GoRoute(
          path: RoutePaths.maintenance,
          name: RouteNames.maintenance,
          builder: (context, state) => MaintenanceScreen(
            info: _appVersionController!.config!.maintenance,
            onRetry: _appVersionController!.refresh,
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
            // PIN is optional — remember the choice so we don't re-prompt
            // on every subsequent sign-in.
            onSkip: (ctx) {
              AppPrefs.setPinOptedOut(true);
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
          // The Planner passes the day being viewed as `extra`.
          builder: (context, state) => NewTaskPage(
            initialDate: state.extra is DateTime ? state.extra as DateTime : null,
          ),
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

        // ── Debug routes (test page): not reachable in release builds ───
        if (kDebugMode)
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

  /// Routes to the correct next screen after a successful login/signup/
  /// continue-offline action: PIN setup only if no PIN exists yet (locally
  /// or restorable from the backend — e.g. after an uninstall/reinstall),
  /// otherwise straight to home (the user just authenticated).
  static Future<void> _routeAfterAuth(BuildContext context) async {
    var hasPin = await AppPrefs.hasPin();
    if (!hasPin) {
      hasPin = await _tryRestorePinFromServer();
    }
    if (!context.mounted) return;
    if (hasPin) {
      context.go(RoutePaths.home);
      return;
    }
    // PIN is optional — don't re-prompt if the user already declined it once.
    final optedOut = await AppPrefs.isPinOptedOut();
    if (!context.mounted) return;
    context.go(optedOut ? RoutePaths.home : '/pin-setup');
  }

  /// Best-effort: an offline-only user or a network failure should just
  /// fall through to normal PIN setup, not block or error out.
  static Future<bool> _tryRestorePinFromServer() async {
    try {
      final stored = await UserService.instance.fetchPinFromServer();
      if (stored == null) return false;
      await AppPrefs.restoreHashedPin(stored.hash, stored.salt);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String resolveInitialRoute({
    required bool showOnboarding,
    required bool hasPin,
    required bool biometricEnabled,
    required bool isSignedIn,
  }) {
    if (showOnboarding) return RoutePaths.onboarding;
    if (biometricEnabled) return '/biometric-unlock';
    if (hasPin) return '/pin-unlock';
    // No app-lock configured (PIN is optional). A previously-authenticated
    // user should land straight on home, not be forced back through login.
    if (isSignedIn) return RoutePaths.home;
    return RoutePaths.login;
  }
}