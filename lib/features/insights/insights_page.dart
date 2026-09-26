import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/routing/route_paths.dart';
import '../app_data.dart';
import 'widgets/insights_ai_suggestion_card.dart';
import 'widgets/insights_data.dart';
import 'widgets/insights_focus_trend_card.dart';
import 'widgets/insights_greeting.dart';
import 'widgets/insights_mindfulness_card.dart';
import 'widgets/insights_productivity_score_card.dart';
import 'widgets/insights_reflection_image_card.dart';
import 'widgets/insights_sync_indicator.dart';
import 'widgets/insights_top_category_card.dart';
import 'widgets/insights_weekly_completion_card.dart';

/// InsightsPage — composes the individual card widgets under
/// features/insights/widgets/. Split from a single 688-line file in
/// Phase 5.1 of docs/DEVELOPMENT_PLAN.md.
class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  // The centre button floats over the bottom of the list; without this the last
  // card would sit underneath it.
  static const _bottomClearance = DzSpacing.xxl + DzSpacing.lg;

  @override
  Widget build(BuildContext context) {
    final insightsCtrl = InsightsScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge(
          [TaskScope.of(context), JournalScope.of(context), insightsCtrl]),
      builder: (context, _) {
        final d = InsightsData.from(context);
        final hasData = TaskScope.of(context).all.isNotEmpty ||
            JournalScope.of(context).all.isNotEmpty;
        final suggestion = d.suggestion;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
              DzSpacing.lg, DzSpacing.md, DzSpacing.lg, _bottomClearance),
          children: [
            InsightsGreeting(
              subtitle: hasData
                  ? d.greetingSubtitle
                  : 'Log tasks and journal entries to see your patterns.',
            ),
            const SizedBox(height: DzSpacing.lg),
            if (!hasData)
              DzEmptyState(
                icon: Icons.analytics_outlined,
                title: AppConfig.insightsEmptyTitle,
                subtitle: AppConfig.insightsEmptyBody,
                actionLabel: AppConfig.insightsEmptyAction,
                onAction: () => context.push(RoutePaths.newTask),
              )
            else ...[
              InsightsSyncIndicator(
                insightsController: insightsCtrl,
                showFullStatus: true,
              ),
              InsightsProductivityScoreCard(data: d),
              const SizedBox(height: DzSpacing.md),
              InsightsFocusTrendCard(data: d),
              const SizedBox(height: DzSpacing.md),
              InsightsWeeklyCompletionCard(data: d),
              if (suggestion != null) ...[
                const SizedBox(height: DzSpacing.md),
                InsightsAiSuggestionCard(suggestion: suggestion),
              ],
              if (d.topCategory != null) ...[
                const SizedBox(height: DzSpacing.md),
                InsightsTopCategoryCard(data: d),
              ],
              const SizedBox(height: DzSpacing.md),
              InsightsMindfulnessCard(data: d),
              const SizedBox(height: DzSpacing.md),
              const InsightsReflectionImageCard(),
            ],
          ],
        );
      },
    );
  }
}
