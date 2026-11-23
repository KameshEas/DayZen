import 'package:dayzen/core/design_system/design_system.dart';
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

import '../../helpers/golden_fonts.dart';

/// Plan M-1.9: every onboarding step in light and dark, all four accents,
/// and 200 % text. The overflow checks run in CI; the images are goldens
/// (tagged, skipped by default, see dart_test.yaml).

OnboardingEffects _noEffects() => OnboardingEffects(
      saveTasks: (_) async {},
      requestNotificationPermission: () async => false,
      setRemindersEnabled: (_) async {},
      savePrior: (_) async {},
      markDone: () async {},
      countStarted: () async {},
      countCompleted: () async {},
      recordTimeToFirstPlan: (_) async {},
    );

const _steps = ['welcome', 'plate', 'sharpest', 'preview', 'nudge'];

Future<void> _pumpAt(
  WidgetTester tester,
  String step, {
  required ThemeData theme,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(AppScopes(
    tasks: TaskController(),
    journal: JournalController(),
    settings: SettingsController(),
    notifications: NotificationController(),
    child: MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      // A fresh key per pump: otherwise the page keeps its state between
      // pumps in one test and starts mid-flow.
      home: OnboardingV2Page(
          key: UniqueKey(),
          effects: _noEffects(),
          // 08:00, so the preview is the same whatever time the test runs.
          clock: () => DateTime(2027, 1, 12, 8),
          onFinished: () {},
          onRestore: () {}),
    ),
  ));
  await tester.pumpAndSettle();

  Future<void> tap(String text) async {
    final f = find.text(text).first;
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  final target = _steps.indexOf(step);
  if (target >= 1) {
    await tap("Let's begin");
    await tester.enterText(find.byType(TextField), 'write report 1h, gym at 6pm, call mom');
    await tap('Turn into tasks');
  }
  if (target >= 2) {
    await tap('Next');
    await tap('Morning');
  }
  if (target >= 3) await tap('Next');
  if (target >= 4) await tap('Looks good');
}

void main() {
  group('200 % text: no overflow on any step', () {
    for (final step in _steps) {
      testWidgets(step, (tester) async {
        await _pumpAt(tester, step, theme: DzTheme.light(), textScale: 2);
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('dark theme: no overflow on any step', (tester) async {
    for (final step in _steps) {
      await _pumpAt(tester, step, theme: DzTheme.dark());
      expect(tester.takeException(), isNull, reason: step);
    }
  });

  testWidgets('every interactive control has a label for TalkBack', (tester) async {
    final handle = tester.ensureSemantics();
    for (final step in _steps) {
      await _pumpAt(tester, step, theme: DzTheme.light());
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline), reason: step);
    }
    handle.dispose();
  });

  testWidgets('touch targets are at least 48 dp on every step', (tester) async {
    final handle = tester.ensureSemantics();
    for (final step in _steps) {
      await _pumpAt(tester, step, theme: DzTheme.light());
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline), reason: step);
    }
    handle.dispose();
  });

  group('goldens', () {
    setUpAll(loadAppFonts);

    for (final step in _steps) {
      for (final (name, theme) in [('light', DzTheme.light()), ('dark', DzTheme.dark())]) {
        testWidgets('$step $name', tags: ['golden'], (tester) async {
          await _pumpAt(tester, step, theme: theme);
          await expectLater(find.byType(OnboardingV2Page),
              matchesGoldenFile('goldens/onboarding_${step}_$name.png'));
        });
      }
      testWidgets('$step 200% text', tags: ['golden'], (tester) async {
        await _pumpAt(tester, step, theme: DzTheme.light(), textScale: 2);
        await expectLater(find.byType(OnboardingV2Page),
            matchesGoldenFile('goldens/onboarding_${step}_text200.png'));
      });
    }

    for (final (name, accent) in [
      ('navy', DzColors.navy),
      ('sunrise', DzColors.sunrise),
      ('sage', DzColors.zenGreen),
      ('lavender', DzColors.lavender),
    ]) {
      testWidgets('sharpest accent $name', tags: ['golden'], (tester) async {
        await _pumpAt(tester, 'sharpest', theme: DzTheme.light(accent: accent));
        await expectLater(find.byType(OnboardingV2Page),
            matchesGoldenFile('goldens/onboarding_sharpest_accent_$name.png'));
      });
    }
  });

  // Keep imports used when goldens are skipped.
  test('prior enum is reachable', () => expect(RhythmPrior.values, hasLength(4)));
  test('task model is reachable', () => expect(TaskStatus.values, isNotEmpty));
}
