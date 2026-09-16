import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../app_data.dart';

/// Computed insights data, derived from TaskController/JournalController at
/// build time. Not a widget — a plain data-holder consumed by the various
/// insights cards.
class InsightsData {
  InsightsData.from(BuildContext context) {
    final now = DateTime.now();
    final taskCtrl = TaskScope.of(context);
    final journalCtrl = JournalScope.of(context);
    productivityScore = taskCtrl.todayScore;
    focusBars = taskCtrl.weekBarFractions(now);
    totalFocusLabel = taskCtrl.todayFocusLabel;
    weeklyTasksDone = taskCtrl.weekCompletedCount(now);
    completionBars = focusBars; // same fractions
    journalCount = journalCtrl.thisWeekCount;
  }

  late int productivityScore;
  late List<double> focusBars;
  late String totalFocusLabel;
  late int weeklyTasksDone;
  late List<double> completionBars;
  late int journalCount;

  static const focusDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const completionDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  String get productivityDelta {
    if (productivityScore >= AppConfig.excellentScoreThreshold) {
      return AppConfig.productivityDeltaMessages[AppConfig.excellentScoreThreshold] ?? AppConfig.productivityDeltaDefault;
    }
    if (productivityScore >= AppConfig.goodScoreThreshold) {
      return AppConfig.productivityDeltaMessages[AppConfig.goodScoreThreshold] ?? AppConfig.productivityDeltaDefault;
    }
    return AppConfig.productivityDeltaDefault;
  }

  String get aiQuote {
    if (productivityScore >= AppConfig.excellentScoreThreshold) {
      return AppConfig.aiQuotesByScore[AppConfig.excellentScoreThreshold] ?? AppConfig.aiQuoteDefault;
    }
    return AppConfig.aiQuoteDefault;
  }
}
