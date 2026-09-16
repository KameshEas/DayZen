abstract final class RoutePaths {
  static const String home = '/';
  static const String planner = '/planner';
  static const String newTask = '/new-task';
  static const String taskDetail = '/task/:id';
  static const String insights = '/insights';
  static const String journal = '/journal';
  static const String journalDetail = '/journal/:id';
  static const String settings = '/settings';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  static String taskDetailPath(String id) => '/task/$id';
  static String journalDetailPath(String id) => '/journal/$id';
}

abstract final class RouteNames {
  static const String home = 'home';
  static const String planner = 'planner';
  static const String newTask = 'newTask';
  static const String taskDetail = 'taskDetail';
  static const String insights = 'insights';
  static const String journal = 'journal';
  static const String journalDetail = 'journalDetail';
  static const String settings = 'settings';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
}
