import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around Firebase Analytics for in-app behavior tracking
/// (screen views, feature usage). Does not collect the advertising ID —
/// see the `google_analytics_adid_collection_enabled` manifest flag.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  Future<void> init() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }
}
