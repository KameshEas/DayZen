import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_prefs.dart';
import '../../../core/config/copy/close_day_copy.dart';
import '../../../core/data/day_close_repository.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/services/counters_service.dart';
import '../../../core/services/moments_service.dart';
import '../../close_day/day_close_controller.dart';

/// Home entry points for Close the Day (plan M-1.10 / M-1.8):
/// - the one-time "New: Close your day" card for installs that finished
///   onboarding before the feature existed (any time of day),
/// - from [eveningHour] on, a "Close your day" card, or a quiet "Day
///   closed" line with the day's summary once it's done.
class CloseDayHomeCard extends StatefulWidget {
  const CloseDayHomeCard({super.key, this.store, this.clock});

  final DayCloseStore? store;
  final DateTime Function()? clock;

  static const eveningHour = 18;

  @override
  State<CloseDayHomeCard> createState() => _CloseDayHomeCardState();
}

class _CloseDayHomeCardState extends State<CloseDayHomeCard> {
  static const _promptCountedKey = 'close_prompt_counted_day';

  late Future<({DayCloseRecord? closed, bool whatsNew, bool firstEvening})> _state =
      _load();

  DayCloseStore get _store => widget.store ?? const DayCloseRepository();
  DateTime _now() => (widget.clock ?? DateTime.now)();

  Future<({DayCloseRecord? closed, bool whatsNew, bool firstEvening})> _load() async {
    final first = await AppPrefs.firstUseDate();
    final firstEvening = first != null &&
        MomentsService.dueOnHome(
          firstUse: first,
          now: _now(),
          fired: await MomentsService.fired(),
          signedIn: true,
        ).contains(Moment.firstCloseInvite);
    // Day 0 evening invite (M-3.4): fires once.
    if (firstEvening) await MomentsService.markFired(Moment.firstCloseInvite);
    return (
      closed: await _store.forDay(_now()),
      whatsNew: await AppPrefs.shouldShowWhatsNewCloseDay(),
      firstEvening: firstEvening,
    );
  }

  Future<void> _open({bool fromWhatsNew = false}) async {
    if (fromWhatsNew) await AppPrefs.markWhatsNewCloseDaySeen();
    if (!mounted) return;
    await context.push(RoutePaths.closeDay);
    if (mounted) setState(() => _state = _load());
  }

  Future<void> _dismissWhatsNew() async {
    await AppPrefs.markWhatsNewCloseDaySeen();
    if (mounted) setState(() => _state = _load());
  }

  /// Counts the evening card as one prompt per day.
  Future<void> _countPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DayCloseRepository.midnight(_now()).toIso8601String();
    if (prefs.getString(_promptCountedKey) == today) return;
    await prefs.setString(_promptCountedKey, today);
    await CountersService.instance.increment(CountersService.closePrompts);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _state,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        final evening = _now().hour >= CloseDayHomeCard.eveningHour;
        final children = <Widget>[
          if (data.whatsNew) _whatsNew(context),
          if (data.closed != null)
            _closed(context, data.closed!)
          else if (evening)
            _prompt(context, firstEvening: data.firstEvening),
        ];
        if (children.isEmpty) return const SizedBox.shrink();
        if (data.closed == null && evening) _countPrompt();
        return Padding(
          padding: const EdgeInsets.only(bottom: DzSpacing.md),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: DzSpacing.md),
                children[i],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _prompt(BuildContext context, {bool firstEvening = false}) {
    final scheme = Theme.of(context).colorScheme;
    return DzCard(
      onTap: _open,
      child: Row(
        children: [
          ExcludeSemantics(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.nights_stay_outlined, color: scheme.primary),
            ),
          ),
          const SizedBox(width: DzSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    firstEvening
                        ? CloseDayCopy.firstEveningTitle
                        : CloseDayCopy.homeCardTitle,
                    style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                Text(firstEvening ? CloseDayCopy.firstEveningBody : CloseDayCopy.homeCardBody,
                    style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          TextButton(onPressed: _open, child: const Text(CloseDayCopy.homeCardAction)),
        ],
      ),
    );
  }

  Widget _closed(BuildContext context, DayCloseRecord r) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${CloseDayCopy.homeCardClosed}. ${DayCloseController.summaryLine(r)}. '
          'Double tap to edit.',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(DzRadius.card),
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DzSpacing.xs),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: DzSpacing.sm),
              Text(CloseDayCopy.homeCardClosed,
                  style: DzTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: DzSpacing.sm),
              Expanded(
                child: Text(DayCloseController.summaryLine(r),
                    overflow: TextOverflow.ellipsis,
                    style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _whatsNew(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DzCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: DzSpacing.sm),
              Semantics(
                header: true,
                child: Text(CloseDayCopy.whatsNewTitle,
                    style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: DzSpacing.xs),
          Text(CloseDayCopy.whatsNewBody,
              style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: DzSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _dismissWhatsNew,
                child: const Text(CloseDayCopy.whatsNewDismiss),
              ),
              const SizedBox(width: DzSpacing.xs),
              FilledButton.tonal(
                onPressed: () => _open(fromWhatsNew: true),
                child: const Text(CloseDayCopy.whatsNewTry),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
