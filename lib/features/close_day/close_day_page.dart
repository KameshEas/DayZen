import 'package:flutter/material.dart';

import '../../core/config/copy/close_day_copy.dart';
import '../../core/data/day_close_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/counters_service.dart';
import '../app_data.dart';
import '../journal/models/journal_entry.dart';
import 'day_close_controller.dart';
import 'widgets/swipe_task_card.dart';

/// Close the Day (plan M-1.10). Opened from the evening prompt, the Home
/// card after 18:00, or the "What's new" card.
class CloseDayPage extends StatefulWidget {
  const CloseDayPage({super.key, this.store, this.clock, this.onDone});

  /// Test seams.
  final DayCloseStore? store;
  final DateTime Function()? clock;

  /// Leaves the page; defaults to popping it (or going home if it can't).
  final VoidCallback? onDone;

  @override
  State<CloseDayPage> createState() => _CloseDayPageState();
}

class _CloseDayPageState extends State<CloseDayPage> {
  DayCloseController? _c;
  final _note = TextEditingController();

  DayCloseController get c => _c!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    _c = DayCloseController(
      tasks: TaskScope.of(context),
      journal: JournalScope.of(context),
      store: widget.store ?? const DayCloseRepository(),
      clock: widget.clock,
      onFirstClose: () =>
          CountersService.instance.increment(CountersService.daysClosed),
    )..addListener(_onChange);
    c.load().then((_) {
      if (mounted) _note.text = c.note;
    });
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c?.removeListener(_onChange);
    _c?.dispose();
    _note.dispose();
    super.dispose();
  }

  void _leave() {
    if (widget.onDone != null) {
      widget.onDone!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: !c.loaded ||
          c.step == CloseStep.review ||
          c.step == CloseStep.summary,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) c.back();
      },
      child: Scaffold(
        appBar: DzAppBar(
          title: CloseDayCopy.pageTitle,
          leading: c.step == CloseStep.summary
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  onPressed: _leave,
                ),
        ),
        body: !c.loaded
            ? const Center(child: CircularProgressIndicator())
            : AnimatedSwitcher(
                duration: reduceMotion ? Duration.zero : DzDuration.normal,
                child: KeyedSubtree(
                  key: ValueKey(c.step),
                  child: switch (c.step) {
                    CloseStep.review => _review(context),
                    CloseStep.mood => _mood(context),
                    CloseStep.note => _noteStep(context),
                    CloseStep.summary => _summary(context),
                  },
                ),
              ),
      ),
    );
  }

  Widget _frame({
    required String title,
    required String body,
    required Widget child,
    required Widget actions,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(DzSpacing.lg),
              children: [
                Semantics(
                  header: true,
                  child: Text(title,
                      style: DzTextStyles.heading2.copyWith(color: scheme.onSurface)),
                ),
                const SizedBox(height: DzSpacing.xs),
                Text(body,
                    style: DzTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: DzSpacing.lg),
                child,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.md),
            child: actions,
          ),
        ],
      ),
    );
  }

  Widget _review(BuildContext context) {
    final open = c.remaining;
    return _frame(
      title: CloseDayCopy.reviewTitle,
      body: CloseDayCopy.reviewBody,
      actions: Row(
        children: [
          if (c.canUndo) ...[
            TextButton.icon(
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text(CloseDayCopy.undo),
              onPressed: c.undo,
            ),
            const SizedBox(width: DzSpacing.sm),
          ],
          Expanded(
            child: DzPrimaryButton(
              label: 'Next',
              onPressed: c.continueFromReview,
            ),
          ),
        ],
      ),
      child: open.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: DzSpacing.xl),
              child: Text(CloseDayCopy.reviewEmpty,
                  textAlign: TextAlign.center, style: DzTextStyles.body),
            )
          : Column(
              children: [
                for (final t in open) ...[
                  SwipeTaskCard(
                    key: ValueKey(t.id),
                    task: t,
                    onDone: () => c.markDone(t),
                    onCarry: () => c.carry(t),
                    onLetGo: () => c.letGo(t),
                  ),
                  const SizedBox(height: DzSpacing.sm),
                ],
              ],
            ),
    );
  }

  Widget _mood(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _frame(
      title: CloseDayCopy.moodTitle,
      body: CloseDayCopy.moodBody,
      actions: DzPrimaryButton(
        label: 'Next',
        onPressed: c.continueFromMood,
        width: double.infinity,
      ),
      child: Wrap(
        spacing: DzSpacing.sm,
        runSpacing: DzSpacing.sm,
        alignment: WrapAlignment.center,
        children: [
          for (final m in JournalMood.values)
            Semantics(
              inMutuallyExclusiveGroup: true,
              checked: c.mood == m,
              button: true,
              label: _moodLabel(m),
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(DzRadius.card),
                onTap: () => c.chooseMood(m),
                child: AnimatedContainer(
                  duration: DzDuration.fast,
                  width: 140,
                  padding: const EdgeInsets.symmetric(vertical: DzSpacing.md),
                  decoration: BoxDecoration(
                    color: c.mood == m ? m.bg : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(DzRadius.card),
                    border: Border.all(
                      color: c.mood == m ? m.iconColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(m.icon, size: 32, color: m.iconColor),
                      const SizedBox(height: DzSpacing.xs),
                      Text(_moodLabel(m),
                          style: DzTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: c.mood == m ? DzColors.navy : scheme.onSurface,
                          )),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _moodLabel(JournalMood m) => switch (m) {
        JournalMood.happy => 'Happy',
        JournalMood.peaceful => 'Peaceful',
        JournalMood.inspired => 'Inspired',
        JournalMood.overwhelmed => 'Overwhelmed',
      };

  Widget _noteStep(BuildContext context) {
    return _frame(
      title: CloseDayCopy.noteTitle,
      body: CloseDayCopy.noteBody,
      actions: Column(
        children: [
          DzPrimaryButton(
            label: CloseDayCopy.closeButton,
            isLoading: c.saving,
            onPressed: c.saving ? null : c.finish,
            width: double.infinity,
          ),
        ],
      ),
      child: TextField(
        controller: _note,
        onChanged: (v) => c.note = v,
        maxLength: 280,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: CloseDayCopy.noteHint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    final r = c.result!;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(DzSpacing.lg),
        child: Column(
          children: [
            const Spacer(),
            ExcludeSemantics(
              child: Icon(Icons.nights_stay_outlined, size: 72, color: scheme.primary),
            ),
            const SizedBox(height: DzSpacing.lg),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                c.lastFinishWasEdit
                    ? CloseDayCopy.summaryEditedTitle
                    : CloseDayCopy.summaryTitle,
                style: DzTextStyles.heading1.copyWith(color: scheme.onSurface),
              ),
            ),
            const SizedBox(height: DzSpacing.sm),
            Text(DayCloseController.summaryLine(r),
                style: DzTextStyles.heading3.copyWith(color: scheme.onSurface)),
            const SizedBox(height: DzSpacing.md),
            Text(CloseDayCopy.summaryBody,
                textAlign: TextAlign.center,
                style: DzTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
            const Spacer(),
            DzPrimaryButton(
              label: CloseDayCopy.summaryDone,
              onPressed: _leave,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
