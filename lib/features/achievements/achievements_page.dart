import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/achievement_service.dart';
import '../app_data.dart';

/// Achievements page displaying gamification progress.
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  late Future<List<Achievement>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  void _loadAchievements() {
    final controller = AIOptimizationScope.of(context);
    _achievementsFuture = controller
        .loadAchievements(forceRefresh: false)
        .then((_) => controller.achievements ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Achievement>>(
        future: _achievementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return DzEmptyState(
              icon: Icons.error_outline_rounded,
              iconColor: DzColors.error,
              title: AppConfig.achievementsErrorTitle,
              subtitle: '${snapshot.error}',
              actionLabel: 'Retry',
              onAction: () => setState(() => _loadAchievements()),
            );
          }

          final achievements = snapshot.data ?? [];
          if (achievements.isEmpty) {
            return DzEmptyState(
              icon: Icons.emoji_events_outlined,
              iconColor: DzColors.primary.withValues(alpha: 0.3),
              title: AppConfig.achievementsEmptyTitle,
              subtitle: AppConfig.achievementsEmptyBody,
            );
          }

          final unlocked = achievements.where((a) => a.isUnlocked).toList();
          final locked = achievements.where((a) => !a.isUnlocked).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall progress
                _buildOverallProgress(context, unlocked.length, achievements.length),
                const SizedBox(height: DzSpacing.lg),

                // Unlocked section
                if (unlocked.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
                    child: Text(
                      'Unlocked (${unlocked.length})',
                      style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  _buildAchievementGrid(unlocked, isUnlocked: true),
                  const SizedBox(height: DzSpacing.lg),
                ],

                // Locked section
                if (locked.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
                    child: Text(
                      'Locked (${locked.length})',
                      style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                  _buildAchievementGrid(locked, isUnlocked: false),
                  const SizedBox(height: DzSpacing.lg),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(BuildContext context, int unlocked, int total) {
    final percentage = total > 0 ? (unlocked / total * 100).toStringAsFixed(0) : '0';

    return Container(
      margin: const EdgeInsets.all(DzSpacing.md),
      padding: const EdgeInsets.all(DzSpacing.lg),
      decoration: BoxDecoration(
        color: DzColors.primaryTint.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DzRadius.card),
        border: Border.all(color: DzColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConfig.achievementsProgressHeader,
                    style: DzTextStyles.heading3.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlocked of $total achievements unlocked',
                    style: DzTextStyles.caption,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DzColors.primary,
                  borderRadius: BorderRadius.circular(DzRadius.small),
                ),
                child: Text(
                  '$percentage%',
                  style: DzTextStyles.button.copyWith(color: DzColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(DzRadius.small),
            child: LinearProgressIndicator(
              value: total > 0 ? unlocked / total : 0,
              minHeight: 8,
              backgroundColor: DzColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(DzColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(List<Achievement> achievements, {required bool isUnlocked}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DzSpacing.md),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: DzSpacing.md,
          mainAxisSpacing: DzSpacing.md,
          childAspectRatio: 0.85,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) => _buildAchievementCard(
          context,
          achievements[index],
          isUnlocked: isUnlocked,
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement, {required bool isUnlocked}) {
    return DzCard(
      color: isUnlocked ? DzColors.cardBackground : DzColors.neutralTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? DzColors.primary.withValues(alpha: 0.1) : DzColors.borderLight,
              borderRadius: BorderRadius.circular(DzRadius.button),
            ),
            child: Text(
              achievement.icon,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: DzSpacing.sm),

          // Title
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Progress
          Text(
            '${achievement.progress.current}/${achievement.progress.target}',
            style: DzTextStyles.caption,
          ),
          const SizedBox(height: DzSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: achievement.progress.percentageComplete / 100,
              minHeight: 4,
              backgroundColor: DzColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? DzColors.primary : DzColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),

          // Unlock date (if unlocked)
          if (isUnlocked && achievement.unlockedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: DzSpacing.xs),
              child: Text(
                'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                style: DzTextStyles.small.copyWith(color: DzColors.primary),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inHours < 24) {
      return 'today';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return date.toString().split(' ').first;
    }
  }
}
