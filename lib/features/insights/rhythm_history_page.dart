import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../core/domain/rhythm/energy_profile.dart';
import '../rhythm/rhythm_controller.dart';

/// Rhythm history (plan M-4.2): one small curve per week, newest first, so
/// you can see your energy pattern take shape. All local.
class RhythmHistoryPage extends StatefulWidget {
  const RhythmHistoryPage({super.key, this.loader});

  /// Test seam; defaults to [RhythmController.history].
  final Future<List<RhythmWeek>> Function()? loader;

  @override
  State<RhythmHistoryPage> createState() => _RhythmHistoryPageState();
}

class _RhythmHistoryPageState extends State<RhythmHistoryPage> {
  late final Future<List<RhythmWeek>> _weeks =
      (widget.loader ?? RhythmController.history)();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DzAppBar(title: 'Rhythm history'),
      body: FutureBuilder(
        future: _weeks,
        builder: (context, snap) {
          final weeks = snap.data;
          if (weeks == null) return const Center(child: CircularProgressIndicator());
          if (weeks.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(DzSpacing.lg),
                child: DzEmptyState(
                  icon: Icons.waves_rounded,
                  title: 'No weeks yet',
                  subtitle: 'Each week, DayZen keeps a snapshot of your energy curve here.',
                ),
              ),
            );
          }
          final newestFirst = weeks.reversed.toList();
          return GridView.builder(
            padding: const EdgeInsets.all(DzSpacing.md),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisSpacing: DzSpacing.sm,
              crossAxisSpacing: DzSpacing.sm,
              childAspectRatio: 1.25,
            ),
            itemCount: newestFirst.length,
            itemBuilder: (context, i) => _WeekTile(week: newestFirst[i]),
          );
        },
      ),
    );
  }
}

class _WeekTile extends StatelessWidget {
  const _WeekTile({required this.week});
  final RhythmWeek week;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = week.profile;
    final w = p.sharpestWindow();
    final label = 'Week of ${_months[week.weekStart.month - 1]} ${week.weekStart.day}';
    final window = '${RhythmController.hourLabel(w.startHour)}–${RhythmController.hourLabel(w.endHour)}';
    return Semantics(
      label: '$label. Sharpest around $window${p.isForming ? ', still forming' : ''}.',
      excludeSemantics: true,
      child: DzCard(
        padding: const EdgeInsets.all(DzSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: DzTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: DzSpacing.xs),
            Expanded(child: _MiniCurve(profile: p, color: scheme.primary)),
            const SizedBox(height: DzSpacing.xs),
            Text(
              p.isForming ? '~$window · forming' : '~$window',
              style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniCurve extends StatelessWidget {
  const _MiniCurve({required this.profile, required this.color});
  final EnergyProfile profile;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final peak = profile.sharpestWindow();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var h = EnergyProfile.wakeStart; h < EnergyProfile.wakeEnd; h++)
          Expanded(
            child: FractionallySizedBox(
              heightFactor: profile.at(h).clamp(0.05, 1.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0.75),
                decoration: BoxDecoration(
                  color: h >= peak.startHour && h < peak.endHour
                      ? color
                      : color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
