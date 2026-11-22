import 'package:dayzen/core/data/checkin_repository.dart';
import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/domain/quiet_window.dart';
import 'package:dayzen/core/domain/rhythm/checkin_planner.dart';
import 'package:dayzen/core/services/counters_service.dart';
import 'package:dayzen/core/services/gentle_prompts.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/rhythm/checkin_page.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final day = DateTime(2027, 4, 12);

  group('CheckinPlanner.timesFor', () {
    test('at most two prompts, three hours apart, inside 09:00–21:00', () {
      for (var d = 0; d < 60; d++) {
        final t = CheckinPlanner.timesFor(day: day.add(Duration(days: d)));
        expect(t.length, lessThanOrEqualTo(CheckinPlanner.maxPerDay));
        for (final x in t) {
          final m = x.hour * 60 + x.minute;
          expect(m, inInclusiveRange(9 * 60, 21 * 60));
        }
        if (t.length == 2) {
          expect(t[1].difference(t[0]).inMinutes,
              greaterThanOrEqualTo(CheckinPlanner.minGapMinutes));
        }
      }
    });

    test('never inside the quiet window', () {
      const quiet = QuietWindow(startMinutes: 12 * 60, endMinutes: 20 * 60);
      for (var d = 0; d < 60; d++) {
        for (final x in CheckinPlanner.timesFor(
            day: day.add(Duration(days: d)), quietWindow: quiet)) {
          expect(quiet.contains(x.hour, x.minute), isFalse);
        }
      }
    });

    test('same day, same times (stable rescheduling); varied across days', () {
      expect(CheckinPlanner.timesFor(day: day), CheckinPlanner.timesFor(day: day));
      final hours = {
        for (var d = 0; d < 30; d++)
          for (final x in CheckinPlanner.timesFor(day: day.add(Duration(days: d))))
            x.hour,
      };
      expect(hours.length, greaterThan(6), reason: 'the model should see many hours');
    });

    test('pauses after three ignored days', () {
      expect(CheckinPlanner.timesFor(day: day, ignoredStreak: 2), isNotEmpty);
      expect(CheckinPlanner.timesFor(day: day, ignoredStreak: 3), isEmpty);
    });
  });

  group('CheckinPlanner.ignoredStreak', () {
    DateTime ago(int n) => day.subtract(Duration(days: n));

    test('counts prompted, unanswered days back from yesterday', () {
      expect(
        CheckinPlanner.ignoredStreak(
          today: day,
          promptedDays: {ago(1), ago(2), ago(3), ago(4)},
          answeredDays: {ago(4)},
        ),
        3,
      );
    });

    test('an answer resets it; a day without prompts ends it', () {
      expect(
        CheckinPlanner.ignoredStreak(
            today: day, promptedDays: {ago(1), ago(2)}, answeredDays: {ago(1)}),
        0,
      );
      expect(
        CheckinPlanner.ignoredStreak(
            today: day, promptedDays: {ago(1), ago(3)}, answeredDays: {}),
        1,
      );
    });
  });

  group('CheckinPage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      DatabaseProvider.instanceForTesting =
          AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await DatabaseProvider.instance.close();
      DatabaseProvider.resetForTesting();
    });

    testWidgets('one tap saves the check-in and counts the answer', (tester) async {
      var done = false;
      await tester.pumpWidget(MaterialApp(
        home: CheckinPage(clock: () => DateTime(2027, 4, 12, 15), onDone: () => done = true),
      ));
      await tester.tap(find.bySemanticsLabel('Good, 4 of 5'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(done, isTrue);
      final saved = await tester.runAsync(
          () => const CheckinRepository().since(DateTime(2027)));
      expect(saved!.single.energy, 4);
      expect(saved.single.at, DateTime(2027, 4, 12, 15));
      expect(
          await tester.runAsync(
              () => CountersService.instance.value(CountersService.checkinAnswers)),
          1);
    });
  });
  group('GentlePrompts check-ins', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      DatabaseProvider.instanceForTesting =
          AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await DatabaseProvider.instance.close();
      DatabaseProvider.resetForTesting();
    });

    test('records the day as prompted and counts prompts once a day', () async {
      final g = GentlePrompts(settings: SettingsController());
      final morning = DateTime(2027, 4, 12, 7);
      final first = await g.checkinTimesFor(morning);
      final again = await g.checkinTimesFor(morning);
      expect(first, isNotEmpty);
      expect(again, first);
      expect(await CountersService.instance.value(CountersService.checkinPrompts),
          first.length);
    });

    test('three ignored days pause prompts; one answer resumes them', () async {
      final g = GentlePrompts(settings: SettingsController());
      for (var d = 0; d < 3; d++) {
        await g.checkinTimesFor(DateTime(2027, 4, 9 + d, 7));
      }
      final fourth = DateTime(2027, 4, 12, 7);
      expect(await g.isPaused(now: fourth), isTrue);
      expect(await g.checkinTimesFor(fourth), isEmpty);

      await const CheckinRepository().add(3, at: DateTime(2027, 4, 11, 19));
      expect(await g.isPaused(now: fourth), isFalse);
      expect(await g.checkinTimesFor(fourth), isNotEmpty);
    });

    test('off in Settings means no prompts', () async {
      final settings = SettingsController()..setCheckinsEnabled(false);
      final g = GentlePrompts(settings: settings);
      expect(await g.checkinTimesFor(DateTime(2027, 4, 12, 7)), isEmpty);
    });
  });
}
