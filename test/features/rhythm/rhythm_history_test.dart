import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/design_system/design_system.dart';
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/features/insights/rhythm_history_page.dart';
import 'package:dayzen/features/rhythm/rhythm_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('weekly snapshots', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({'rhythm_prior': 'morning'});
      DatabaseProvider.instanceForTesting =
          AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await DatabaseProvider.instance.close();
      DatabaseProvider.resetForTesting();
    });

    test('one row per week, updated during the week, kept after it', () async {
      var now = DateTime(2027, 3, 3, 10); // a Wednesday
      final c = RhythmController(clock: () => now);
      await c.load(const []);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      c.addCheckin(DateTime(2027, 3, 2, 14), 5); // same week
      await Future<void>.delayed(const Duration(milliseconds: 50));

      var weeks = await RhythmController.history();
      expect(weeks, hasLength(1));
      expect(weeks.single.weekStart, DateTime(2027, 3, 1));

      now = DateTime(2027, 3, 9, 10); // next week
      c.addCheckin(DateTime(2027, 3, 9, 9), 4);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      weeks = await RhythmController.history();
      expect(weeks.map((w) => w.weekStart), [DateTime(2027, 3, 1), DateTime(2027, 3, 8)]);
      expect(weeks.first.values, hasLength(24));
    });

    test('weekStartOf is the Monday, including on Sunday and Monday', () {
      expect(RhythmController.weekStartOf(DateTime(2027, 3, 7, 23)), DateTime(2027, 3, 1));
      expect(RhythmController.weekStartOf(DateTime(2027, 3, 8, 0, 5)), DateTime(2027, 3, 8));
    });
  });

  List<RhythmWeek> sample() => [
        for (final (i, prior) in [RhythmPrior.notSure, RhythmPrior.midday, RhythmPrior.morning].indexed)
          RhythmWeek(
            weekStart: DateTime(2027, 3, 1).add(Duration(days: 7 * i)),
            values: EnergyProfile.priorCurve(prior),
            confidence: i * 6.0,
          ),
      ];

  testWidgets('shows the weeks newest first, readable by TalkBack', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      home: RhythmHistoryPage(loader: () async => sample()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Week of Mar 15'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Week of Mar 1\. .*still forming')), findsOneWidget);
    final first = tester.getTopLeft(find.text('Week of Mar 15'));
    final last = tester.getTopLeft(find.text('Week of Mar 1'));
    expect(first.dy <= last.dy, isTrue, reason: 'newest first');
    handle.dispose();
  });

  testWidgets('empty state before the first week', (tester) async {
    await tester.pumpWidget(MaterialApp(home: RhythmHistoryPage(loader: () async => [])));
    await tester.pumpAndSettle();
    expect(find.text('No weeks yet'), findsOneWidget);
  });

  testWidgets('golden: rhythm history', tags: ['golden'], (tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: DzTheme.light(),
      home: RhythmHistoryPage(loader: () async => sample()),
    ));
    await tester.pumpAndSettle();
    await expectLater(find.byType(RhythmHistoryPage), matchesGoldenFile('goldens/rhythm_history.png'));
  });
}
