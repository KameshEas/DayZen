import 'package:flutter/material.dart';
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load achievements: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadAchievements()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final achievements = snapshot.data ?? [];
          if (achievements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: DzColors.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No achievements yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start completing tasks to unlock achievements',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
        color: DzColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DzColors.primary.withOpacity(0.1)),
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
                    'Overall Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$unlocked of $total achievements unlocked',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: DzColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? unlocked / total : 0,
              minHeight: 8,
              backgroundColor: DzColors.primary.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(DzColors.primary),
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
    return Card(
      elevation: isUnlocked ? 2 : 0,
      color: isUnlocked ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked ? DzColors.primary.withOpacity(0.1) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Progress
            Text(
              '${achievement.progress.current}/${achievement.progress.target}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: DzSpacing.sm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress.percentageComplete / 100,
                minHeight: 4,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isUnlocked ? DzColors.primary : DzColors.primary.withOpacity(0.3),
                ),
              ),
            ),

            // Unlock date (if unlocked)
            if (isUnlocked && achievement.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: DzSpacing.xs),
                child: Text(
                  'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DzColors.primary,
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
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
