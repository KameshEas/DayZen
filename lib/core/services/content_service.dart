/// Service to fetch dynamic content (quotes, messages, etc.) from API with fallbacks.
library;

import '../api/api_client.dart';
import '../config/app_config.dart';

class ContentService {
  ContentService._() {
    _apiClient = ApiClient();
  }

  static final instance = ContentService._();

  late final ApiClient _apiClient;
  String? _cachedDailyQuote;
  DateTime? _lastQuoteFetch;

  Future<String> getDailyReflectionQuote() async {
    try {
      // Check cache (valid for 24 hours)
      if (_cachedDailyQuote != null && _lastQuoteFetch != null) {
        if (DateTime.now().difference(_lastQuoteFetch!).inHours < 24) {
          return _cachedDailyQuote!;
        }
      }

      // Fetch from API
      try {
        final response = await _apiClient.get('/quotes/daily');
        if (response.containsKey('quote') && response['quote'] is String) {
          _cachedDailyQuote = response['quote'] as String;
          _lastQuoteFetch = DateTime.now();
          return _cachedDailyQuote!;
        }
      } on ApiException {
        // API call failed, will use fallback below
      }

      // Fallback to default if API fails
      return AppConfig.defaultDailyReflectionQuote;
    } catch (e) {
      // Unexpected error, use default
      return AppConfig.defaultDailyReflectionQuote;
    }
  }

  Future<String> getProductivityMessage(int score) async {
    try {
      // Determine message based on score
      if (score >= AppConfig.excellentScoreThreshold) {
        return AppConfig.messageExcellent;
      } else if (score >= AppConfig.goodScoreThreshold) {
        return AppConfig.messageGood;
      }
      return AppConfig.messageNeedImprovement;
    } catch (e) {
      return AppConfig.messageNeedImprovement;
    }
  }

  Future<String> getAiQuote(int productivityScore) async {
    try {
      // TODO: Implement API call to fetch AI-generated quote based on data
      if (productivityScore >= AppConfig.excellentScoreThreshold) {
        return AppConfig.aiQuotesByScore[AppConfig.excellentScoreThreshold] ?? AppConfig.aiQuoteDefault;
      }
      return AppConfig.aiQuoteDefault;
    } catch (e) {
      return AppConfig.aiQuoteDefault;
    }
  }

  Future<String> getGreeting(int hour) async {
    try {
      if (hour < AppConfig.morningHourThreshold) {
        return AppConfig.greetingMorning;
      } else if (hour < AppConfig.afternoonHourThreshold) {
        return AppConfig.greetingAfternoon;
      }
      return AppConfig.greetingEvening;
    } catch (e) {
      return AppConfig.greetingMorning;
    }
  }

  Future<String> getJournalReflection(int entryCount) async {
    try {
      if (entryCount == 0) {
        return AppConfig.journalReflectionMessages[0] ?? AppConfig.journalReflectionDefault;
      } else if (entryCount <= 2) {
        return AppConfig.journalReflectionMessages[2] ?? AppConfig.journalReflectionDefault;
      } else if (entryCount <= 4) {
        return AppConfig.journalReflectionMessages[4] ?? AppConfig.journalReflectionDefault;
      }
      return AppConfig.journalReflectionDefault;
    } catch (e) {
      return AppConfig.journalReflectionDefault;
    }
  }

  Future<String> getBreakRecommendation(int totalFocusMinutes) async {
    try {
      if (totalFocusMinutes > AppConfig.breakRecommendationHighThreshold) {
        return AppConfig.breakRecommendationHigh;
      } else if (totalFocusMinutes > AppConfig.breakRecommendationMediumThreshold) {
        return AppConfig.breakRecommendationMedium;
      }
      return AppConfig.breakRecommendationLight;
    } catch (e) {
      return AppConfig.breakRecommendationLight;
    }
  }

  void clearCache() {
    _cachedDailyQuote = null;
    _lastQuoteFetch = null;
  }
}
