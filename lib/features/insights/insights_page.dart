import 'package:flutter/material.dart';
import '../../core/app_prefs.dart';
import '../../core/services/moments_service.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/routing/route_paths.dart';
import '../app_data.dart';
import 'week_story_card.dart';
import 'widgets/lifts_you_card.dart';
import 'widgets/insights_ai_suggestion_card.dart';
import 'widgets/insights_data.dart';
import 'widgets/insights_focus_trend_card.dart';
import 'widgets/insights_greeting.dart';
import 'widgets/insights_mindfulness_card.dart';
import 'widgets/insights_productivity_score_card.dart';
import 'widgets/insights_reflection_image_card.dart';
import 'widgets/insights_top_category_card.dart';
import 'widgets/insights_weekly_completion_card.dart';

/// InsightsPage — composes the individual card widgets under
/// features/insights/widgets/.
class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  /// Read once per visit: whether Insights is still locked (before day 7).
  late final Future<int> _unlocksIn = AppPrefs.firstUseDate().then(
    (first) =>
        MomentsService.insightsUnlocksIn(firstUse: first, now: DateTime.now()),
  );

  // The centre button floats over the bottom of the list; without this the last
  // card would sit underneath it.
  static const _bottomClearance = DzSpacing.xxl + DzSpacing.lg;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unlocksIn,
      builder: (context, snap) => _content(context, snap.data ?? 0),
    );
  }

  Widget _content(BuildContext context, int unlocksIn) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        TaskScope.of(context),
        JournalScope.of(context),
      ]),
      builder: (context, _) {
        final d = InsightsData.from(context);
        final hasData =
            TaskScope.of(context).all.isNotEmpty ||
            JournalScope.of(context).all.isNotEmpty;
        final suggestion = d.suggestion;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            DzSpacing.lg,
            DzSpacing.md,
            DzSpacing.lg,
            _bottomClearance,
          ),
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
            else if (unlocksIn > 0)
              _UnlockCard(daysLeft: unlocksIn)
            else ...[
              const WeekStoryCard(),
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
              const LiftsYouCard(),
              InsightsMindfulnessCard(data: d),
              const SizedBox(height: DzSpacing.md),
              const InsightsReflectionImageCard(),
              const SizedBox(height: DzSpacing.md),
              DzCard(
                onTap: () => context.push(RoutePaths.achievements),
                child: const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text('🌿', style: TextStyle(fontSize: 24)),
                  title: Text('Milestones'),
                  subtitle: Text('Small markers that only ever go up.'),
                  trailing: Icon(Icons.chevron_right_rounded),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Before day 7 (plan M-3.4): what Insights will show, instead of thin
/// charts, plus the Milestones that are already there.
class _UnlockCard extends StatelessWidget {
  const _UnlockCard({required this.daysLeft});
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Each card is its own semantics node: without the containers the
    // info card's text merged into the tappable Milestones card, making one
    // big "button" for TalkBack whose centre wasn't tappable.
    return Column(
      children: [
        Semantics(
          container: true,
          child: DzCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.hourglass_bottom_rounded, color: scheme.primary),
                const SizedBox(height: DzSpacing.sm),
                Semantics(
                  header: true,
                  child: Text(
                    daysLeft == 1
                        ? 'Insights unlock tomorrow'
                        : 'Insights unlock in $daysLeft days',
                    style: DzTextStyles.heading3,
                  ),
                ),
                const SizedBox(height: DzSpacing.xs),
                Text(
                  'A week of use gives DayZen enough to show you real patterns: '
                  'your week in one card, your sharpest hours, and what lifts you.',
                  style: DzTextStyles.body.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DzSpacing.md),
        Semantics(
          container: true,
          button: true,
          child: DzCard(
            onTap: () => context.push(RoutePaths.achievements),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text('🌿', style: TextStyle(fontSize: 24)),
              title: Text('Milestones'),
              subtitle: Text('Small markers that only ever go up.'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
