import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_prefs.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/services/moments_service.dart';
import '../../app_data.dart';
import '../../rhythm/rhythm_controller.dart';
import '../../rhythm/widgets/rhythm_card.dart';

/// Day 3 and day 7 moments on Home (plan M-3.4). Each is shown once: it is
/// marked as fired the first time it appears, and stays for that visit.
/// The day-0 evening invite lives in [CloseDayHomeCard] instead.
class MomentCard extends StatefulWidget {
  const MomentCard({super.key, this.clock});

  final DateTime Function()? clock;

  @override
  State<MomentCard> createState() => _MomentCardState();
}

class _MomentCardState extends State<MomentCard> {
  Future<Moment?>? _moment;
  bool _dismissed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _moment ??= _load(SettingsScope.of(context).isSignedIn);
  }

  Future<Moment?> _load(bool signedIn) async {
    final first = await AppPrefs.firstUseDate();
    if (first == null) return null;
    final due = MomentsService.dueOnHome(
      firstUse: first,
      now: (widget.clock ?? DateTime.now)(),
      fired: await MomentsService.fired(),
      signedIn: signedIn,
    ).where((m) => m != Moment.firstCloseInvite);
    if (due.isEmpty) return null;
    final m = due.first;
    await MomentsService.markFired(m);
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _moment,
      builder: (context, snap) {
        final m = snap.data;
        if (m == null || _dismissed) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        final (icon, title, body, action, onAction) = switch (m) {
          Moment.rhythmForming => (
              Icons.waves_rounded,
              'Your rhythm is forming',
              _rhythmBody(context),
              'See it',
              () => showRhythmDetails(context),
            ),
          Moment.syncOffer => (
              Icons.cloud_outlined,
              'Keep your days safe',
              'Sign in to sync your tasks and journal across phones. Optional: '
                  'DayZen keeps working fully offline.',
              'Sign in',
              () => context.push(RoutePaths.login),
            ),
          _ => (Icons.info_outline, '', '', '', () {}),
        };
        return Padding(
          padding: const EdgeInsets.only(bottom: DzSpacing.md),
          child: DzCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: scheme.primary),
                    const SizedBox(width: DzSpacing.sm),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title,
                            style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dismiss',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _dismissed = true),
                    ),
                  ],
                ),
                Text(body, style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: onAction, child: Text(action)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _rhythmBody(BuildContext context) {
    final rhythm = RhythmScope.maybeOf(context);
    if (rhythm == null) {
      return 'Three days in. A few check-ins help DayZen learn your best hours.';
    }
    return 'Three days in. ${RhythmController.windowSentence(rhythm.profile)}. '
        'It sharpens as you go.';
  }
}
