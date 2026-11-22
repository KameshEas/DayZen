import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_prefs.dart';
import '../../core/data/day_close_repository.dart';
import '../../core/design_system/design_system.dart' hide TaskPriority;
import '../../core/domain/journal_analytics.dart';
import '../../core/domain/rhythm/energy_profile.dart';
import '../app_data.dart';
import '../home/models/task_model.dart';
import '../journal/models/journal_entry.dart';
import '../rhythm/rhythm_controller.dart';

/// The facts of one week, all counted on the device.
class WeekStory {
  const WeekStory({
    required this.from,
    required this.to,
    required this.tasksDone,
    required this.daysClosed,
    required this.windowSentence,
    this.lift,
  });

  final DateTime from;
  final DateTime to;
  final int tasksDone;
  final int daysClosed;
  final String windowSentence;
  final String? lift;

  /// The 7 days ending [now] (inclusive).
  static WeekStory compute({
    required DateTime now,
    required List<DzTask> tasks,
    required List<JournalEntry> journal,
    required int daysClosed,
    required EnergyProfile profile,
  }) {
    final to = DateTime(now.year, now.month, now.day);
    final from = to.subtract(const Duration(days: 6));
    bool inWeek(DateTime d) => !d.isBefore(from) && !d.isAfter(to);
    final lifts = JournalAnalytics.liftsYou(journal, tasks);
    return WeekStory(
      from: from,
      to: to,
      tasksDone: tasks.where((t) => t.status == TaskStatus.done && inWeek(t.date)).length,
      daysClosed: daysClosed,
      windowSentence: RhythmController.windowSentence(profile),
      lift: lifts.isEmpty ? null : lifts.first.sentence,
    );
  }
}

/// Week Story (plan M-3.3): shown on Insights from day 7 of use, refreshed
/// as the week rolls on. "Share" renders the card to a PNG on the device and
/// opens the share sheet; nothing is uploaded by DayZen.
class WeekStoryCard extends StatefulWidget {
  const WeekStoryCard({super.key, this.clock, this.store, this.forceShow = false});

  final DateTime Function()? clock;
  final DayCloseStore? store;

  /// Tests: skip the day-7 check.
  final bool forceShow;

  /// Days of use before the story appears (day 7 = 6 days after the first).
  static const showFromDay = 6;

  @override
  State<WeekStoryCard> createState() => _WeekStoryCardState();
}

class _WeekStoryCardState extends State<WeekStoryCard> {
  final _boundary = GlobalKey();
  late final Future<({bool show, int closed})> _load = _loadState();

  DateTime get _now => (widget.clock ?? DateTime.now)();

  Future<({bool show, int closed})> _loadState() async {
    final first = await AppPrefs.firstUseDate();
    final today = DateTime(_now.year, _now.month, _now.day);
    final show = widget.forceShow ||
        (first != null &&
            today.difference(first).inDays >= WeekStoryCard.showFromDay);
    if (!show) return (show: false, closed: 0);
    final closes = await (widget.store ?? const DayCloseRepository())
        .between(today.subtract(const Duration(days: 6)), today);
    return (show: true, closed: closes.length);
  }

  Future<void> _share() async {
    final boundary =
        _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}dayzen-week-story.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      subject: 'My week in DayZen',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load,
      builder: (context, snap) {
        final s = snap.data;
        if (s == null || !s.show) return const SizedBox.shrink();
        final rhythm = RhythmScope.maybeOf(context);
        final story = WeekStory.compute(
          now: _now,
          tasks: TaskScope.of(context).all,
          journal: JournalScope.of(context).all,
          daysClosed: s.closed,
          profile: rhythm?.profile ?? EnergyProfile.prior(RhythmPrior.notSure),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: DzSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RepaintBoundary(
                key: _boundary,
                child: WeekStoryView(story: story),
              ),
              TextButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Share'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The story itself; also what gets rendered to the shared PNG.
class WeekStoryView extends StatelessWidget {
  const WeekStoryView({super.key, required this.story});
  final WeekStory story;

  static String _range(WeekStory s) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String d(DateTime x) => '${months[x.month - 1]} ${x.day}';
    return '${d(s.from)} – ${d(s.to)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = scheme.onPrimary;
    return Semantics(
      container: true,
      label: 'Your week, ${_range(story)}. ${story.tasksDone} things done. '
          '${story.daysClosed} days closed. ${story.windowSentence}.'
          '${story.lift == null ? '' : ' ${story.lift}'}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(DzSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DzRadius.card),
          gradient: LinearGradient(
            colors: [scheme.primary, Color.lerp(scheme.primary, DzColors.sunrise, 0.45)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your week', style: DzTextStyles.heading2.copyWith(color: fg)),
            Text(_range(story),
                style: DzTextStyles.caption.copyWith(color: fg.withValues(alpha: 0.8))),
            const SizedBox(height: DzSpacing.lg),
            Wrap(
              spacing: DzSpacing.xl,
              runSpacing: DzSpacing.sm,
              children: [
                _Stat(value: '${story.tasksDone}', label: 'things done', color: fg),
                _Stat(value: '${story.daysClosed}', label: 'days closed', color: fg),
              ],
            ),
            const SizedBox(height: DzSpacing.lg),
            Text(story.windowSentence, style: DzTextStyles.body.copyWith(color: fg)),
            if (story.lift != null) ...[
              const SizedBox(height: DzSpacing.xs),
              Text(story.lift!, style: DzTextStyles.body.copyWith(color: fg)),
            ],
            const SizedBox(height: DzSpacing.md),
            Text('DayZen', style: DzTextStyles.small.copyWith(color: fg.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: DzTextStyles.heading1.copyWith(color: color, fontSize: 34)),
          Text(label, style: DzTextStyles.caption.copyWith(color: color.withValues(alpha: 0.85))),
        ],
      );
}
