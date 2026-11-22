import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/domain/rhythm/energy_profile.dart';
import '../../../core/routing/route_paths.dart';
import '../../app_data.dart';
import '../rhythm_controller.dart';

/// Home card (plan M-2.4): one sentence, "Your sharpest window: ~9–11 am ·
/// forming". Numbers only appear in the details sheet.
class RhythmCard extends StatelessWidget {
  const RhythmCard({super.key});

  @override
  Widget build(BuildContext context) {
    final rhythm = RhythmScope.maybeOf(context);
    if (rhythm == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final sentence = RhythmController.windowSentence(rhythm.profile);
    return Semantics(
      button: true,
      label: '$sentence. Double tap for details.',
      excludeSemantics: true,
      child: DzCard(
        onTap: () => showRhythmDetails(context),
        child: Row(
          children: [
            Icon(Icons.waves_rounded, color: scheme.primary),
            const SizedBox(width: DzSpacing.md),
            Expanded(
              child: Text(sentence,
                  style: DzTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

Future<void> showRhythmDetails(BuildContext context) {
  final rhythm = RhythmScope.maybeOf(context);
  if (rhythm == null) return Future.value();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => RhythmDetailsSheet(controller: rhythm),
  );
}

/// The numbers behind the tide, and "Not me" (plan M-2.4).
class RhythmDetailsSheet extends StatelessWidget {
  const RhythmDetailsSheet({super.key, required this.controller});
  final RhythmController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final w = p.sharpestWindow();
        final scheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                DzSpacing.lg, 0, DzSpacing.lg, DzSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(RhythmController.windowSentence(p),
                      style: DzTextStyles.heading3),
                ),
                const SizedBox(height: DzSpacing.xs),
                Text(
                  p.isForming
                      ? 'Still learning. Started from "${controller.prior.label}"; '
                          'check-ins and finished tasks shape it over the next few weeks.'
                      : 'Learned from your check-ins and the tasks you finish.',
                  style: DzTextStyles.caption.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: DzSpacing.lg),
                _HourBars(profile: p, onNotMe: controller.notMe),
                const SizedBox(height: DzSpacing.xs),
                Text('Tap an hour that doesn\'t feel right to reset it.',
                    style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: DzSpacing.lg),
                DzSecondaryButton(
                  label: 'Not me: '
                      '${RhythmController.hourLabel(w.startHour)}–'
                      '${RhythmController.hourLabel(w.endHour)}',
                  icon: const Icon(Icons.do_not_disturb_on_outlined, size: 18),
                  onPressed: () async {
                    await controller.notMeWindow(w);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Got it. That window will relearn from scratch.'),
                      ));
                    }
                  },
                  width: double.infinity,
                ),
                const SizedBox(height: DzSpacing.sm),
                DzGhostButton(
                  label: 'Check in now',
                  icon: const Icon(Icons.sentiment_satisfied_rounded, size: 18),
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push(RoutePaths.checkin);
                  },
                ),
                const SizedBox(height: DzSpacing.md),
                Text(
                  'Confidence ${p.confidence.toStringAsFixed(1)} '
                  '(${p.isForming ? 'forming' : 'settled'} at ${EnergyProfile.formingBelow.toStringAsFixed(0)})',
                  style: DzTextStyles.small.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HourBars extends StatelessWidget {
  const _HourBars({required this.profile, required this.onNotMe});
  final EnergyProfile profile;
  final Future<void> Function(int hour) onNotMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hours = [for (var h = EnergyProfile.wakeStart; h < EnergyProfile.wakeEnd; h++) h];
    final peak = profile.sharpestWindow();
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in hours)
            Expanded(
              child: Semantics(
                button: true,
                label: '${RhythmController.hourLabel(h)}, energy '
                    '${(profile.at(h) * 100).round()} percent. Double tap if this isn\'t you.',
                excludeSemantics: true,
                child: InkWell(
                  onTap: () => onNotMe(h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: FractionallySizedBox(
                          heightFactor: profile.at(h).clamp(0.05, 1.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: h >= peak.startHour && h < peak.endHour
                                  ? scheme.primary
                                  : scheme.primary.withValues(alpha: 0.30),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 14,
                        child: h % 3 == 0
                            ? FittedBox(
                                child: Text('$h',
                                    style: DzTextStyles.small
                                        .copyWith(color: scheme.onSurfaceVariant)),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
