import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../app_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Computed data
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsData {
  _InsightsData.from(BuildContext context) {
    final now = DateTime.now();
    final taskCtrl = AppData.of(context).tasks;
    final journalCtrl = AppData.of(context).journal;
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
    if (productivityScore >= 80) return 'Great week!';
    if (productivityScore >= 50) return 'Making progress';
    return 'Keep going!';
  }

  String get aiQuote {
    if (productivityScore >= 80) {
      return '"Your morning focus sessions are driving this peak."';
    }
    return '"Consistency beats perfection. Every small step counts."';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InsightsPage
// ─────────────────────────────────────────────────────────────────────────────

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([appData.tasks, appData.journal]),
      builder: (context, _) {
        final d = _InsightsData.from(context);
        return ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: DzSpacing.lg, vertical: DzSpacing.md),
          children: [
            const _Greeting(),
            const SizedBox(height: DzSpacing.lg),
            _ProductivityScoreCard(data: d),
            const SizedBox(height: DzSpacing.md),
            _FocusTrendCard(data: d),
            const SizedBox(height: DzSpacing.md),
            _WeeklyCompletionCard(data: d),
            const SizedBox(height: DzSpacing.md),
            const _AiSuggestionCard(),
            const SizedBox(height: DzSpacing.md),
            const _TopCategoryCard(),
            const SizedBox(height: DzSpacing.md),
            const _MindfulnessCard(),
            const SizedBox(height: DzSpacing.md),
            const _ReflectionImageCard(),
            const SizedBox(height: DzSpacing.xl),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final rawName = user?.displayName ?? user?.email ?? 'there';
    final name = rawName.contains('@') ? rawName.split('@').first : rawName.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name',
            style: DzTextStyles.heading2
                .copyWith(fontWeight: FontWeight.w700, fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          'You\'ve maintained a calm focus for 4 days straight. Take a deep breath.',
          style: DzTextStyles.body.copyWith(color: DzColors.textSecondary),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Productivity Score Card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductivityScoreCard extends StatelessWidget {
  const _ProductivityScoreCard({required this.data});
  final _InsightsData data;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: DzSpacing.lg, vertical: DzSpacing.lg),
        child: Column(
          children: [
            Text(
              'PRODUCTIVITY SCORE',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: data.productivityScore / 100,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.productivityScore}',
                        style: DzTextStyles.heading1.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        data.productivityDelta,
                        style: DzTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.aiQuote,
              textAlign: TextAlign.center,
              style: DzTextStyles.body.copyWith(
                color: DzColors.textSecondary,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus Time Trend
// ─────────────────────────────────────────────────────────────────────────────

class _FocusTrendCard extends StatelessWidget {
  const _FocusTrendCard({required this.data});
  final _InsightsData data;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FOCUS TIME TREND',
                  style: DzTextStyles.caption.copyWith(
                    color: DzColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.trending_up_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 20),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  data.focusBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _Bar(
                        fraction: data.focusBars[i],
                        label: _InsightsData.focusDays[i],
                        highlight: i == DateTime.now().weekday - 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              data.totalFocusLabel,
              style: DzTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Total focus this week',
              style: DzTextStyles.caption
                  .copyWith(color: DzColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.label,
    this.highlight = false,
  });
  final double fraction;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: FractionallySizedBox(
            heightFactor: fraction,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: highlight ? Theme.of(context).colorScheme.primary : const Color(0xFFBFD7FF),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: DzTextStyles.caption.copyWith(
              fontSize: 9,
              color: DzColors.textSecondary,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly Completion
// ─────────────────────────────────────────────────────────────────────────────

class _WeeklyCompletionCard extends StatelessWidget {
  const _WeeklyCompletionCard({required this.data});
  final _InsightsData data;

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY COMPLETION',
                      style: DzTextStyles.caption.copyWith(
                        color: DzColors.textSecondary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.weeklyTasksDone} Tasks Done',
                      style: DzTextStyles.heading3
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Last 7 Days',
                    style: DzTextStyles.caption.copyWith(
                      color: DzColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  data.completionBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Bar(
                        fraction: data.completionBars[i],
                        label: _InsightsData.completionDays[i],
                        highlight: i == DateTime.now().weekday - 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Zen AI Suggestion
// ─────────────────────────────────────────────────────────────────────────────

class _AiSuggestionCard extends StatelessWidget {
  const _AiSuggestionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(DzRadius.card),
      ),
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: DzSpacing.md),
              Text(
                'Zen AI Suggestion',
                style: DzTextStyles.heading3.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.md),
          Text(
            'Based on your peak performance hours, we suggest moving your '
            '"Deep Work" block to 9:00 AM instead of 2:00 PM for optimal focus.',
            style: DzTextStyles.body
                .copyWith(color: Colors.white.withValues(alpha: 0.88)),
          ),
          const SizedBox(height: DzSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DzRadius.button),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: const Text('Adjust My Planner',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Category
// ─────────────────────────────────────────────────────────────────────────────

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard();

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOP CATEGORY',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center_rounded,
                      color: DzColors.textSecondary, size: 22),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health & Wellness',
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Top focus area this week',
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            _ProgressBar(value: 0.72, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mindfulness
// ─────────────────────────────────────────────────────────────────────────────

class _MindfulnessCard extends StatelessWidget {
  const _MindfulnessCard();

  @override
  Widget build(BuildContext context) {
    return DzCard(
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MINDFULNESS',
              style: DzTextStyles.caption.copyWith(
                color: DzColors.textSecondary,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.self_improvement_rounded,
                      color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: DzSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zen Sessions',
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Daily mindfulness practice',
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            _ProgressBar(value: 0.55, color: const Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: const Color(0xFFE2E8F0),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reflection image card
// ─────────────────────────────────────────────────────────────────────────────

class _ReflectionImageCard extends StatelessWidget {
  const _ReflectionImageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DzRadius.card),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.all(DzSpacing.lg),
      child: Text(
        '"The secret of getting ahead is getting started."',
        style: DzTextStyles.body.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
