import 'package:flutter/material.dart';

import '../../core/data/checkin_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/counters_service.dart';
import '../../core/services/gentle_prompts.dart';
import '../app_data.dart';

/// Energy check-in (plan M-2.5): five faces, one tap, done. Opened from the
/// check-in prompt or from the Rhythm details sheet. Stored locally only.
class CheckinPage extends StatelessWidget {
  const CheckinPage({super.key, this.repository, this.onDone, this.clock});

  final CheckinRepository? repository;
  final VoidCallback? onDone;
  final DateTime Function()? clock;

  static const faces = <(int, IconData, String)>[
    (1, Icons.sentiment_very_dissatisfied_rounded, 'Drained'),
    (2, Icons.sentiment_dissatisfied_rounded, 'Low'),
    (3, Icons.sentiment_neutral_rounded, 'Okay'),
    (4, Icons.sentiment_satisfied_rounded, 'Good'),
    (5, Icons.sentiment_very_satisfied_rounded, 'Sharp'),
  ];

  Future<void> _answer(BuildContext context, int energy) async {
    final at = (clock ?? DateTime.now)();
    final rhythm = RhythmScope.maybeOf(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await (repository ?? const CheckinRepository()).add(energy, at: at);
    rhythm?.addCheckin(at, energy);
    await CountersService.instance.increment(CountersService.checkinAnswers);
    // An answer resumes check-ins if they had paused themselves.
    await GentlePrompts.instance?.apply();
    messenger?.showSnackBar(const SnackBar(content: Text('Thanks. Noted.')));
    if (onDone != null) {
      onDone!();
    } else if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const DzAppBar(title: 'Check-in'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DzSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text("How's your energy right now?",
                    textAlign: TextAlign.center,
                    style: DzTextStyles.heading2.copyWith(color: scheme.onSurface)),
              ),
              const SizedBox(height: DzSpacing.sm),
              Text('One tap. It helps DayZen learn your rhythm.',
                  textAlign: TextAlign.center,
                  style: DzTextStyles.body.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: DzSpacing.xl),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: DzSpacing.sm,
                runSpacing: DzSpacing.sm,
                children: [
                  for (final (energy, icon, label) in faces)
                    Semantics(
                      button: true,
                      label: '$label, $energy of 5',
                      excludeSemantics: true,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(DzRadius.card),
                        onTap: () => _answer(context, energy),
                        child: SizedBox(
                          width: 64,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: DzSpacing.sm),
                            child: Column(
                              children: [
                                Icon(icon, size: 40, color: scheme.primary),
                                const SizedBox(height: 4),
                                FittedBox(
                                  child: Text(label,
                                      style: DzTextStyles.small
                                          .copyWith(color: scheme.onSurfaceVariant)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
