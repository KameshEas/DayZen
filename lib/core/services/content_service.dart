/// Service to fetch dynamic content (quotes, messages, etc.) from API with fallbacks.
library;

import '../api/api_client.dart';
import '../config/app_config.dart';

class ContentService {
  ContentService._();

  static final instance = ContentService._();

  static final ApiClient _apiClient = ApiClient();

  String? _cachedDailyQuote;
  DateTime? _lastQuoteFetch;
  String? _cachedRandomQuote;
  DateTime? _lastRandomQuoteFetch;

  /// Fetch today's daily reflection quote from API.
  /// Caches result for 24 hours. Falls back to default on error.
  Future<String> getDailyReflectionQuote() async {
    try {
      // Check cache validity (24 hours)
      if (_cachedDailyQuote != null && _lastQuoteFetch != null) {
        final hoursSinceFetch = DateTime.now().difference(_lastQuoteFetch!).inHours;
        if (hoursSinceFetch < AppConfig.cacheValidityHours) {
          return _cachedDailyQuote!;
        }
      }

      // Fetch fresh quote from public API endpoint
      final response = await _apiClient.publicGet('/quotes/daily');

      if (response.containsKey('quote') && response['quote'] is String) {
        _cachedDailyQuote = response['quote'] as String;
        _lastQuoteFetch = DateTime.now();
        return _cachedDailyQuote!;
      }

      // Fallback to default if response invalid
      return AppConfig.defaultDailyReflectionQuote;
    } on ApiException {
      // Return cached quote if available, else default
      if (_cachedDailyQuote != null) {
        return _cachedDailyQuote!;
      }
      return AppConfig.defaultDailyReflectionQuote;
    } catch (_) {
      // Unexpected error, use default
      return AppConfig.defaultDailyReflectionQuote;
    }
  }

  /// Fetch a random quote (with optional category filter).
  /// Caches result for 24 hours. Falls back to default on error.
  Future<String> getRandomQuote({String? category}) async {
    try {
      // Check cache validity
      if (_cachedRandomQuote != null && _lastRandomQuoteFetch != null) {
        final hoursSinceFetch = DateTime.now().difference(_lastRandomQuoteFetch!).inHours;
        if (hoursSinceFetch < AppConfig.cacheValidityHours) {
          return _cachedRandomQuote!;
        }
      }

      // Build endpoint with optional category
      final endpoint = category != null ? '/quotes/random?category=$category' : '/quotes/random';

      // Fetch fresh quote from public API endpoint
      final response = await _apiClient.publicGet(endpoint);

      if (response.containsKey('quote') && response['quote'] is String) {
        _cachedRandomQuote = response['quote'] as String;
        _lastRandomQuoteFetch = DateTime.now();
        return _cachedRandomQuote!;
      }

      // Fallback to default
      return AppConfig.defaultDailyReflectionQuote;
    } on ApiException {
      // Return cached quote if available, else default
      if (_cachedRandomQuote != null) {
        return _cachedRandomQuote!;
      }
      return AppConfig.defaultDailyReflectionQuote;
    } catch (_) {
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
