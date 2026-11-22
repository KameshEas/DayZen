abstract final class RoutePaths {
  static const String home = '/';
  static const String planner = '/planner';
  static const String newTask = '/new-task';
  static const String insights = '/insights';
  static const String journal = '/journal';
  static const String journalDetail = '/journal/:id';
  static const String settings = '/settings';
  static const String aiAssistant = '/ai-assistant';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forceUpdate = '/force-update';
  static const String maintenance = '/maintenance';
  static const String closeDay = '/close-day';
  static const String released = '/released';
  static const String achievements = '/achievements';

  static String journalDetailPath(String id) => '/journal/$id';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String planner = 'planner';
  static const String newTask = 'newTask';
  static const String insights = 'insights';
  static const String journal = 'journal';
  static const String journalDetail = 'journalDetail';
  static const String settings = 'settings';
  static const String aiAssistant = 'aiAssistant';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forceUpdate = 'forceUpdate';
  static const String maintenance = 'maintenance';
  static const String closeDay = 'closeDay';
  static const String released = 'released';
  static const String achievements = 'achievements';
}
