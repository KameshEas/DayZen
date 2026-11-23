import 'package:dayzen/core/services/moments_service.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights/insights_page.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final first = DateTime(2027, 7, 1);
  DateTime at(int day, int hour) => DateTime(2027, 7, 1 + day, hour);

  group('dueOnHome', () {
    List<Moment> due(int day, int hour, {Set<Moment> fired = const {}, bool signedIn = false}) =>
        MomentsService.dueOnHome(
            firstUse: first, now: at(day, hour), fired: fired, signedIn: signedIn);

    test('day 0: the close invite only from 18:00', () {
      expect(due(0, 17), isEmpty);
      expect(due(0, 18), [Moment.firstCloseInvite]);
      expect(due(1, 20), isNot(contains(Moment.firstCloseInvite)));
    });

    test('day 3: rhythm forming; day 7: sync offer when signed out', () {
      expect(due(2, 10), isEmpty);
      expect(due(3, 10), [Moment.rhythmForming]);
      expect(due(7, 10), [Moment.rhythmForming, Moment.syncOffer]);
      expect(due(7, 10, signedIn: true), [Moment.rhythmForming]);
    });

    test('each fires at most once', () {
      expect(due(0, 19, fired: {Moment.firstCloseInvite}), isEmpty);
      expect(due(9, 10, fired: {Moment.rhythmForming, Moment.syncOffer}), isEmpty);
    });

    test('day counting is by calendar date, across DST and month ends', () {
      expect(MomentsService.dayOfUse(DateTime(2027, 3, 13, 23), DateTime(2027, 3, 14, 1)), 1);
      expect(MomentsService.dayOfUse(DateTime(2027, 1, 31), DateTime(2027, 2, 3)), 3);
    });
  });

  test('PIN offer: after a first entry, never with a PIN, an opt-out, or twice', () {
    bool offer({int entries = 1, bool pin = false, bool out = false, Set<Moment> fired = const {}}) =>
        MomentsService.shouldOfferPin(
            journalEntries: entries, hasPin: pin, pinOptedOut: out, fired: fired);
    expect(offer(), isTrue);
    expect(offer(entries: 0), isFalse);
    expect(offer(pin: true), isFalse);
    expect(offer(out: true), isFalse);
    expect(offer(fired: {Moment.pinOffer}), isFalse);
  });

  test('insights unlock on day 7; unknown first use means unlocked', () {
    expect(MomentsService.insightsUnlocksIn(firstUse: first, now: at(0, 9)), 6);
    expect(MomentsService.insightsUnlocksIn(firstUse: first, now: at(5, 9)), 1);
    expect(MomentsService.insightsUnlocksIn(firstUse: first, now: at(6, 9)), 0);
    expect(MomentsService.insightsUnlocksIn(firstUse: null, now: at(0, 9)), 0);
  });

  test('fired moments persist', () async {
    SharedPreferences.setMockInitialValues({});
    await MomentsService.markFired(Moment.rhythmForming);
    await MomentsService.markFired(Moment.rhythmForming);
    expect(await MomentsService.fired(), {Moment.rhythmForming});
  });

  group('Insights gate', () {
    Widget app() => AppScopes(
          tasks: _Seeded(),
          journal: JournalController(),
          settings: SettingsController(),
          notifications: NotificationController(),
          child: const MaterialApp(home: Scaffold(body: InsightsPage())),
        );

    testWidgets('before day 7: an unlock card instead of charts', (tester) async {
      final today = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'first_use_date':
            DateTime(today.year, today.month, today.day - 2).toIso8601String(),
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Insights unlock in 4 days'), findsOneWidget);
      expect(find.text('Milestones'), findsOneWidget);
    });

    testWidgets('the unlock card and Milestones are separate TalkBack nodes',
        (tester) async {
      final handle = tester.ensureSemantics();
      final today = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'first_use_date':
            DateTime(today.year, today.month, today.day - 2).toIso8601String(),
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final milestones = tester.getSemantics(find.text('Milestones'));
      final unlock = tester.getSemantics(find.text('Insights unlock in 4 days'));
      expect(identical(milestones, unlock), isFalse);
      expect(milestones.label, isNot(contains('unlock')));
      expect(milestones.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      handle.dispose();
    });

    testWidgets('from day 7: no unlock card', (tester) async {
      final today = DateTime.now();
      SharedPreferences.setMockInitialValues({
        'first_use_date':
            DateTime(today.year, today.month, today.day - 9).toIso8601String(),
      });
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.textContaining('Insights unlock'), findsNothing);
    });
  });
}

class _Seeded extends TaskController {
  @override
  List<DzTask> get all => [
        DzTask(
          id: '1',
          title: 'Done',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
          status: TaskStatus.done,
        ),
      ];
}
