import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_prefs.dart';
import '../../core/config/app_config.dart';
import '../../features/achievements/achievements_page.dart';
import '../../features/ai_assistant/ai_assistant_screen.dart';
import '../../features/app_update/app_version_controller.dart';
import '../../features/app_update/update_showcase_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/sign_up_page.dart';
import '../../features/biometric/biometric_auth_page.dart';
import '../../features/close_day/close_day_page.dart';
import '../../features/debug/counters_page.dart';
import '../../features/debug/test_notification_page.dart';
import '../../features/home/home_page.dart';
import '../../features/home/models/task_model.dart';
import '../../features/insights/insights_page.dart';
import '../../features/journal/journal_page.dart';
import '../../features/maintenance/maintenance_screen.dart';
import '../../features/onboarding/widgets/onboarding_page_animated.dart';
import '../../features/onboarding_v2/onboarding_v2_page.dart';
import '../design_system/design_system.dart';
import '../../features/pin/pin_setup_page.dart';
import '../../features/rhythm/checkin_page.dart';
import '../../features/pin/pin_unlock_page.dart';
import '../../features/planner/planner_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_page.dart';
import '../../features/tasks/new_task_page.dart';
import '../../features/tasks/released_tasks_page.dart';
import '../../features/journal/journal_detail_page.dart';
import 'route_paths.dart';

/// Global router instance, initialized post-app-setup in main.dart
GoRouter? _appRouter;
AppVersionController? _appVersionController;

class AppRouter {
  /// Which onboarding `/onboarding` shows: `v2` (default) or `v1`. Set by
  /// bootstrap from [AppPrefs.onboardingVariant] before the route is shown.
  static String onboardingVariant = AppPrefs.buildOnboardingVariant;

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
          builder: (context, state) => onboardingVariant == 'v1'
              ? _onboardingV1(context)
              : OnboardingV2Page(
                  onFinished: () => context.go(RoutePaths.home),
                  onRestore: () => context.go(RoutePaths.login),
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
          // The Planner passes the day being viewed as `extra`; the task
          // actions sheet passes a DzTask to edit it.
          builder: (context, state) => NewTaskPage(
            initialDate: state.extra is DateTime ? state.extra as DateTime : null,
            task: state.extra is DzTask ? state.extra as DzTask : null,
          ),
        ),
        GoRoute(
          path: RoutePaths.settings,
          name: RouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: RoutePaths.closeDay,
          name: RouteNames.closeDay,
          builder: (context, state) => const CloseDayPage(),
        ),
        GoRoute(
          path: RoutePaths.released,
          name: RouteNames.released,
          builder: (context, state) => const ReleasedTasksPage(),
        ),
        GoRoute(
          path: RoutePaths.checkin,
          builder: (context, state) => const CheckinPage(),
        ),
        GoRoute(
          path: RoutePaths.achievements,
          name: RouteNames.achievements,
          builder: (context, state) => const AchievementsPage(),
        ),
        GoRoute(
          path: RoutePaths.aiAssistant,
          name: RouteNames.aiAssistant,
          builder: (context, state) => const AiAssistantScreen(),
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

        // ── Tester counters: hidden (7 taps on the app version), but in
        // release builds too, since testers run release builds ─────────
        GoRoute(
          path: RoutePaths.counters,
          builder: (context, state) => const CountersPage(),
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

  /// The original slides (onboarding v1), kept for the A/B comparison.
  /// Their art and gradient are light-only, so the light brand theme is
  /// pinned.
  static Widget _onboardingV1(BuildContext context) => Theme(
        data: DzTheme.light(),
        child: AnimatedOnboardingPage(
          // "Start Offline": skip the login wall and go straight to
          // securing the app with a PIN.
          onDone: () {
            AppPrefs.markOnboardingSeen();
            context.go('/pin-setup');
          },
          // "Enable Sync (Optional)": through Login/Sign Up, where an
          // account can be created (Login still offers "Continue Offline").
          onEnableSync: () {
            AppPrefs.markOnboardingSeen();
            context.go(RoutePaths.login);
          },
        ),
      );

  static GoRouter get router {
    if (_appRouter == null) {
      throw StateError(
        'AppRouter not initialized. Call AppRouter.initialize(...) in main() before runApp().',
      );
    }
    return _appRouter!;
  }

  /// Routes to the correct next screen after a successful login/signup/
  /// continue-offline action: PIN setup if this device has no PIN yet,
  /// otherwise straight to home (the user just authenticated). The app-lock
  /// PIN is device-local; after a reinstall the user sets a new one.
  static Future<void> _routeAfterAuth(BuildContext context) async {
    // Onboarding v2 defers the PIN to the first journal entry (M-1.7).
    if (await AppPrefs.isOnboardingV2Done()) {
      if (context.mounted) context.go(RoutePaths.home);
      return;
    }
    final hasPin = await AppPrefs.hasPin();
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

  static String resolveInitialRoute({
    required bool showOnboarding,
    required bool hasPin,
    required bool biometricEnabled,
    required bool isSignedIn,
    bool onboardingV2Done = false,
  }) {
    if (showOnboarding) return RoutePaths.onboarding;
    if (biometricEnabled) return '/biometric-unlock';
    if (hasPin) return '/pin-unlock';
    // Onboarding v2 has no sign-up: an offline user goes straight home.
    if (onboardingV2Done) return RoutePaths.home;
    // No app-lock configured (PIN is optional). A previously-authenticated
    // user should land straight on home, not be forced back through login.
    if (isSignedIn) return RoutePaths.home;
    return RoutePaths.login;
  }
}