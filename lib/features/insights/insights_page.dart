import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock data
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsMockData {
  static const productivityScore = 82;
  static const productivityDelta = '+5% vs last week';
  static const aiQuote =
      '"Your morning focus sessions are driving this peak."';

  // bar heights 0.0–1.0 for Mon–Sun
  static const focusBars = [0.35, 0.45, 0.60, 0.50, 0.90, 0.75, 0.40];
  static const focusDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const totalFocusLabel = '32h 15m';

  static const weeklyTasksDone = 48;
  static const completionBars = [0.55, 0.80, 0.65, 1.0, 0.70, 0.50, 0.45];
  static const completionDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static const aiSuggestion =
      'Based on your peak performance hours, we suggest moving your '
      '"Deep Work" block to 9:00 AM instead of 2:00 PM for optimal focus.';

  static const topCategory = 'Health & Wellness';
  static const topCategoryHours = '12h spent this week';
  static const topCategoryProgress = 0.78;

  static const mindfulnessSessions = '8 Quiet Sessions';
  static const mindfulnessAvg = 'Average 10 min each';
  static const mindfulnessProgress = 0.55;

  static const reflectionQuote = '"The secret of getting ahead is getting started."';
}

// ─────────────────────────────────────────────────────────────────────────────
// InsightsPage
// ─────────────────────────────────────────────────────────────────────────────

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: DzSpacing.lg, vertical: DzSpacing.md),
      children: const [
        _Greeting(),
        SizedBox(height: DzSpacing.lg),
        _ProductivityScoreCard(),
        SizedBox(height: DzSpacing.md),
        _FocusTrendCard(),
        SizedBox(height: DzSpacing.md),
        _WeeklyCompletionCard(),
        SizedBox(height: DzSpacing.md),
        _AiSuggestionCard(),
        SizedBox(height: DzSpacing.md),
        _TopCategoryCard(),
        SizedBox(height: DzSpacing.md),
        _MindfulnessCard(),
        SizedBox(height: DzSpacing.md),
        _ReflectionImageCard(),
        SizedBox(height: DzSpacing.xl),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, Alex',
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
  const _ProductivityScoreCard();

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
                  progress:
                      _InsightsMockData.productivityScore / 100,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_InsightsMockData.productivityScore}',
                        style: DzTextStyles.heading1.copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _InsightsMockData.productivityDelta,
                        style: DzTextStyles.caption.copyWith(
                          color: DzColors.primary,
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
              _InsightsMockData.aiQuote,
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
  const _RingPainter({required this.progress});
  final double progress;

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
      ..color = DzColors.primary
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
  const _FocusTrendCard();

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
                    color: DzColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(
                  _InsightsMockData.focusBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _Bar(
                        fraction: _InsightsMockData.focusBars[i],
                        label: _InsightsMockData.focusDays[i],
                        highlight: i == 4, // Friday = peak
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: DzSpacing.md),
            Text(
              _InsightsMockData.totalFocusLabel,
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
                color: highlight ? DzColors.primary : const Color(0xFFBFD7FF),
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
  const _WeeklyCompletionCard();

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
                Column(
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
                      '${_InsightsMockData.weeklyTasksDone} Tasks Done',
                      style: DzTextStyles.heading3
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
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
                  _InsightsMockData.completionBars.length,
                  (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Bar(
                        fraction: _InsightsMockData.completionBars[i],
                        label: _InsightsMockData.completionDays[i],
                        highlight: i == 3, // Thursday = peak
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
        color: DzColors.primary,
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
            _InsightsMockData.aiSuggestion,
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
                        _InsightsMockData.topCategory,
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _InsightsMockData.topCategoryHours,
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            _ProgressBar(
                value: _InsightsMockData.topCategoryProgress,
                color: DzColors.primary),
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
                        _InsightsMockData.mindfulnessSessions,
                        style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _InsightsMockData.mindfulnessAvg,
                        style: DzTextStyles.caption
                            .copyWith(color: DzColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DzSpacing.md),
            _ProgressBar(
                value: _InsightsMockData.mindfulnessProgress,
                color: const Color(0xFF10B981)),
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
        _InsightsMockData.reflectionQuote,
        style: DzTextStyles.body.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
