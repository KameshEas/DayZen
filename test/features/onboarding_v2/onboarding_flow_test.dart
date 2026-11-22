import 'package:dayzen/core/domain/brain_dump_parser.dart';
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/onboarding_v2/onboarding_controller.dart';
import 'package:dayzen/features/onboarding_v2/onboarding_v2_page.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records everything onboarding does to the outside world.
class FakeEffects {
  final saved = <DzTask>[];
  var permissionRequests = 0;
  bool? remindersEnabled;
  RhythmPrior? prior;
  var done = false;
  var started = 0;
  var completed = 0;
  Duration? ttfp;

  OnboardingEffects get effects => OnboardingEffects(
        saveTasks: (t) async => saved.addAll(t),
        requestNotificationPermission: () async {
          permissionRequests++;
          return true;
        },
        setRemindersEnabled: (v) async => remindersEnabled = v,
        savePrior: (p) async => prior = p,
        markDone: () async => done = true,
        countStarted: () async => started++,
        countCompleted: () async => completed++,
        recordTimeToFirstPlan: (d) async => ttfp = d,
      );
}

void main() {
  group('OnboardingController', () {
    late FakeEffects fx;
    late DateTime now;
    late OnboardingController c;

    setUp(() {
      fx = FakeEffects();
      now = DateTime(2027, 1, 12, 8, 0);
      c = OnboardingController(effects: fx.effects, clock: () => now);
    });

    test('begin counts a start once and moves to the plate step', () async {
      await c.begin();
      c.back();
      await c.begin();
      expect(fx.started, 1);
      expect(c.step, OnboardingStep.plate);
    });

    test('cannot leave the plate step without a task', () async {
      await c.begin();
      c.continueFromPlate();
      expect(c.step, OnboardingStep.plate);
      c
        ..setDumpText('gym at 6pm, write report 1h')
        ..parseDump();
      expect(c.drafts, hasLength(2));
      c.continueFromPlate();
      expect(c.step, OnboardingStep.sharpest);
    });

    test('garbage input gives one suggested task, so the flow never blocks', () async {
      await c.begin();
      c
        ..setDumpText('   ')
        ..parseDump();
      expect(c.drafts.single.isSuggestion, isTrue);
      expect(c.canContinueFromPlate, isTrue);
    });

    test('adding a task replaces the leftover suggestion', () {
      c
        ..parseDump()
        ..addDraft(const TaskDraft(title: 'Study chemistry', durationMinutes: 60));
      expect(c.drafts.map((d) => d.title), ['Study chemistry']);
      expect(c.drafts.single.durationMinutes, 60);
    });

    test('going back keeps typed text, chips and the chosen prior', () async {
      await c.begin();
      c
        ..setDumpText('call mom, groceries')
        ..parseDump()
        ..continueFromPlate()
        ..choosePrior(RhythmPrior.evening)
        ..continueFromSharpest();
      expect(c.step, OnboardingStep.preview);
      c
        ..back()
        ..back();
      expect(c.step, OnboardingStep.plate);
      expect(c.dumpText, 'call mom, groceries');
      expect(c.drafts, hasLength(2));
      expect(c.prior, RhythmPrior.evening);
      expect(c.back(), isTrue);
      expect(c.back(), isFalse, reason: 'welcome is the first step');
    });

    test('moving a draft in the preview pins it, snapped to 15 minutes', () async {
      c
        ..setDumpText('groceries')
        ..parseDump()
        ..moveDraft(0, startMinute: 14 * 60 + 7, dayOffset: 0);
      expect(c.drafts.single.startMinute, 14 * 60);
      expect(c.todayPlan.single.startMinute, 14 * 60);
    });

    test('"Not now" saves the plan and never asks for permission', () async {
      await c.begin();
      c
        ..setDumpText('write report 1h, gym at 6pm')
        ..parseDump()
        ..choosePrior(RhythmPrior.morning);
      now = now.add(const Duration(seconds: 42));
      await c.finish(wantsNudge: false);

      expect(fx.permissionRequests, 0);
      expect(fx.remindersEnabled, isFalse);
      expect(fx.saved, hasLength(2));
      expect(fx.prior, RhythmPrior.morning);
      expect(fx.done, isTrue);
      expect(fx.completed, 1);
      expect(fx.ttfp, const Duration(seconds: 42));
      expect(c.finished, isTrue);
    });

    test('"Yes" asks for permission exactly once and turns reminders on', () async {
      c
        ..setDumpText('groceries')
        ..parseDump();
      await c.finish(wantsNudge: true);
      await c.finish(wantsNudge: true); // a double tap does nothing more
      expect(fx.permissionRequests, 1);
      expect(fx.remindersEnabled, isTrue);
      expect(fx.saved, hasLength(1));
    });

    test('skip saves nothing and asks nothing', () async {
      await c.skip();
      expect(fx.saved, isEmpty);
      expect(fx.permissionRequests, 0);
      expect(fx.done, isTrue);
      expect(c.finished, isTrue);
    });
  });

  group('OnboardingV2Page', () {
    Future<FakeEffects> pump(
      WidgetTester tester, {
      required VoidCallback onFinished,
      VoidCallback? onRestore,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      final fx = FakeEffects();
      await tester.pumpWidget(AppScopes(
        tasks: TaskController(),
        journal: JournalController(),
        settings: SettingsController(),
        notifications: NotificationController(),
        child: MaterialApp(
          home: OnboardingV2Page(
            effects: fx.effects,
            onFinished: onFinished,
            onRestore: onRestore ?? () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();
      return fx;
    }

    Future<void> tapText(WidgetTester tester, String text) async {
      final f = find.text(text);
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle();
    }

    testWidgets('fresh install → plan saved → Home, with no permission dialog '
        'when the user picks "Not now"', (tester) async {
      var finished = false;
      final fx = await pump(tester, onFinished: () => finished = true);

      await tapText(tester, "Let's begin");
      await tester.enterText(find.byType(TextField), 'write report 1h, gym at 6pm');
      await tapText(tester, 'Turn into tasks');
      expect(find.textContaining('write report'), findsWidgets);
      await tapText(tester, 'Next');

      await tapText(tester, 'Morning');
      await tapText(tester, 'Next');

      expect(find.text('Your day, gently planned'), findsOneWidget);
      expect(find.textContaining('day'), findsWidgets); // Day Load pill
      await tapText(tester, 'Looks good');

      await tapText(tester, 'Not now');
      expect(finished, isTrue);
      expect(fx.permissionRequests, 0);
      expect(fx.saved.map((t) => t.title), containsAll(['Write report', 'Gym']));
    });

    testWidgets('picking "Yes" is the only path to the permission prompt',
        (tester) async {
      final fx = await pump(tester, onFinished: () {});
      await tapText(tester, "Let's begin");
      await tester.enterText(find.byType(TextField), 'groceries');
      await tapText(tester, 'Turn into tasks');
      await tapText(tester, 'Next');
      await tapText(tester, 'Not sure');
      await tapText(tester, 'Next');
      await tapText(tester, 'Looks good');
      expect(fx.permissionRequests, 0, reason: 'nothing asked before step 4');
      await tapText(tester, 'Yes, nudge me');
      expect(fx.permissionRequests, 1);
    });

    testWidgets('system back walks the steps and keeps the text', (tester) async {
      await pump(tester, onFinished: () {});
      await tapText(tester, "Let's begin");
      await tester.enterText(find.byType(TextField), 'call mom');
      await tapText(tester, 'Turn into tasks');
      await tapText(tester, 'Next');
      expect(find.text('When are you sharpest?'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text("What's on your plate?"), findsOneWidget);
      expect(find.text('call mom'), findsOneWidget);
    });

    testWidgets('chips and options carry screen-reader labels', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, onFinished: () {});
      await tapText(tester, "Let's begin");
      await tester.enterText(find.byType(TextField), 'groceries');
      await tapText(tester, 'Turn into tasks');
      expect(find.bySemanticsLabel(RegExp(r'Groceries, .*Double tap to edit')),
          findsOneWidget);
      await tapText(tester, 'Next');
      expect(find.bySemanticsLabel(RegExp(r'^Morning\. ')), findsOneWidget);
      expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('"Skip" finishes without saving anything', (tester) async {
      var finished = false;
      final fx = await pump(tester, onFinished: () => finished = true);
      await tapText(tester, 'Skip');
      expect(finished, isTrue);
      expect(fx.saved, isEmpty);
    });
  });
}
