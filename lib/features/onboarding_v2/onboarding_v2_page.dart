import 'package:flutter/material.dart';

import '../../core/app_prefs.dart';
import '../../core/notification_service.dart';
import '../../core/services/counters_service.dart';
import '../app_data.dart';
import 'onboarding_controller.dart';
import 'widgets/nudge_step.dart';
import 'widgets/plate_step.dart';
import 'widgets/preview_step.dart';
import 'widgets/sharpest_step.dart';
import 'widgets/welcome_step.dart';

/// Onboarding v2 (plan M-1.6): Welcome → What's on your plate? → When are
/// you sharpest? → live preview → Gentle nudge? → Home.
///
/// No sign-up and no PIN here (M-1.7): "I have an account" goes to sign-in,
/// and the PIN is offered later, on the first journal entry.
class OnboardingV2Page extends StatefulWidget {
  const OnboardingV2Page({
    super.key,
    required this.onFinished,
    required this.onRestore,
    this.effects,
  });

  /// After finishing or skipping.
  final VoidCallback onFinished;

  /// "I have an account".
  final VoidCallback onRestore;

  /// Test seam; defaults to the real app wiring.
  final OnboardingEffects? effects;

  @override
  State<OnboardingV2Page> createState() => _OnboardingV2PageState();
}

class _OnboardingV2PageState extends State<OnboardingV2Page> {
  OnboardingController? _controller;

  OnboardingController get c => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= OnboardingController(effects: widget.effects ?? _realEffects())
      ..addListener(_onChange);
  }

  OnboardingEffects _realEffects() {
    final tasks = TaskScope.of(context);
    final settings = SettingsScope.of(context);
    final rhythm = RhythmScope.maybeOf(context);
    final counters = CountersService.instance;
    return OnboardingEffects(
      saveTasks: (list) async {
        for (final t in list) {
          await tasks.addTask(t);
        }
      },
      requestNotificationPermission: NotificationService.instance.requestPermission,
      setRemindersEnabled: (enabled) async {
        settings.setRemindersEnabled(enabled);
        tasks.applyReminderSettings(
          enabled: enabled,
          quietWindow: settings.quietWindow,
        );
      },
      savePrior: (prior) async {
        await AppPrefs.setRhythmPriorName(prior.name);
        await rhythm?.load(tasks.all);
      },
      markDone: AppPrefs.markOnboardingV2Done,
      countStarted: () => counters.increment(CountersService.onboardingStarted),
      countCompleted: () => counters.increment(CountersService.onboardingCompleted),
      recordTimeToFirstPlan: counters.addTtfpSample,
    );
  }

  void _onChange() {
    if (!mounted) return;
    if (c.finished) {
      widget.onFinished();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onChange);
    _controller?.dispose();
    super.dispose();
  }

  Widget _stepView() => switch (c.step) {
        OnboardingStep.welcome => WelcomeStep(
            onBegin: c.begin,
            onRestore: () async {
              await AppPrefs.markOnboardingV2Done();
              widget.onRestore();
            },
            onSkip: c.skip,
          ),
        OnboardingStep.plate => PlateStep(controller: c),
        OnboardingStep.sharpest => SharpestStep(controller: c),
        OnboardingStep.preview => PreviewStep(
            controller: c,
            existingTasks: TaskScope.of(context).all,
          ),
        OnboardingStep.nudge => NudgeStep(controller: c),
      };

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      // System back walks the steps; only the welcome step leaves the page.
      canPop: c.step == OnboardingStep.welcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !c.saving) c.back();
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(c.step), child: _stepView()),
        ),
      ),
    );
  }
}
