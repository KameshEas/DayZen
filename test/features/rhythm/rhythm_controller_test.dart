import 'package:dayzen/core/data/checkin_repository.dart';
import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/domain/rhythm/energy_model.dart';
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/core/services/counters_service.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/rhythm/rhythm_controller.dart';
import 'package:dayzen/features/rhythm/widgets/rhythm_card.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2027, 3, 1, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({'rhythm_prior': 'evening'});
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  test('loads the onboarding prior; no evidence means the prior curve', () async {
    final c = RhythmController(clock: () => now);
    await c.load(const []);
    expect(c.prior, RhythmPrior.evening);
    expect(c.profile.values, EnergyProfile.priorCurve(RhythmPrior.evening));
    expect(c.profile.isForming, isTrue);
  });

  test('check-ins from the database shape the curve', () async {
    const repo = CheckinRepository();
    for (var d = 1; d <= 6; d++) {
      await repo.add(5, at: now.subtract(Duration(days: d)).copyWith(hour: 9));
    }
    final c = RhythmController(clock: () => now);
    await c.load(const []);
    expect(c.profile.values[9],
        greaterThan(EnergyProfile.priorCurve(RhythmPrior.evening)[9]));
  });

  test('task evidence: heavy done counts for, slipped counts against', () {
    final since = now.subtract(const Duration(days: 90));
    final ev = RhythmController.evidenceFromTasks([
      DzTask(
        id: 'h',
        title: 'Deep work',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
        status: TaskStatus.done,
        completedAt: now.subtract(const Duration(days: 1)),
        effort: 3,
      ),
      DzTask(
        id: 'light',
        title: 'Email',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        status: TaskStatus.done,
        completedAt: now,
        effort: 1,
      ),
      DzTask(
        id: 'carried',
        title: 'Gym',
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 19, minute: 0),
        rolloverCount: 2,
        originalDate: now.subtract(const Duration(days: 3)),
        date: now,
      ),
    ], since: since);
    expect(ev.whereType<HeavyTaskDoneEvidence>(), hasLength(1));
    final slipped = ev.whereType<TaskSlippedEvidence>().single;
    expect(slipped.at.hour, 18);
    expect(slipped.at.day, now.subtract(const Duration(days: 3)).day);
  });

  test('"Not me" resets the hour, is counted, and survives a restart', () async {
    final c = RhythmController(clock: () => now);
    await c.load(const []);
    for (var i = 0; i < 8; i++) {
      c.addCheckin(now.subtract(Duration(hours: 1 + i * 24)).copyWith(hour: 14), 5);
    }
    final before = c.profile.values[14];
    await c.notMe(14);
    expect(c.profile.values[14], lessThan(before));
    expect(c.profile.values[14],
        closeTo(EnergyProfile.priorCurve(RhythmPrior.evening)[14], 1e-9));
    expect(await CountersService.instance.value(CountersService.notMeTaps), 1);

    // A day later: the reset is read back, and a check-in after it counts.
    final later = now.add(const Duration(days: 1));
    final reloaded = RhythmController(clock: () => later);
    await reloaded.load(const []);
    reloaded.addCheckin(now.copyWith(hour: 14), 5);
    // The new check-in is after the reset, so it counts again.
    expect(reloaded.profile.values[14],
        greaterThan(EnergyProfile.priorCurve(RhythmPrior.evening)[14]));
  });

  test('window sentence reads naturally and says when it is forming', () {
    final p = EnergyProfile.prior(RhythmPrior.morning);
    expect(RhythmController.windowSentence(p),
        'Your sharpest window: ~8 am–10 am · forming');
  });

  testWidgets('Home card reads the sentence to TalkBack and opens details',
      (tester) async {
    final handle = tester.ensureSemantics();
    final rhythm = RhythmController(clock: () => now, persist: false);
    await tester.runAsync(() => rhythm.load(const []));
    await tester.pumpWidget(AppScopes(
      tasks: TaskController(),
      journal: JournalController(),
      settings: SettingsController(),
      notifications: NotificationController(),
      rhythm: rhythm,
      child: const MaterialApp(home: Scaffold(body: RhythmCard())),
    ));
    expect(find.bySemanticsLabel(RegExp(r'^Your sharpest window: ~.* forming\.')),
        findsOneWidget);
    await tester.tap(find.byType(RhythmCard));
    await tester.pumpAndSettle();
    expect(find.textContaining('Not me:'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('without a Rhythm the card is absent (tests, early bootstrap)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RhythmCard())));
    expect(find.byType(Card), findsNothing);
    expect(find.textContaining('sharpest'), findsNothing);
  });
}
