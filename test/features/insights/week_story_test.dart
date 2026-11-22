import 'package:dayzen/core/data/day_close_repository.dart';
import 'package:dayzen/core/design_system/design_system.dart' hide TaskPriority;
import 'package:dayzen/core/domain/rhythm/energy_profile.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights/week_story_card.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/golden_fonts.dart';

class _Store implements DayCloseStore {
  _Store(this.count);
  final int count;
  @override
  Future<List<DayCloseRecord>> between(DateTime from, DateTime to) async => [
        for (var i = 0; i < count; i++)
          DayCloseRecord(
              date: to.subtract(Duration(days: i)), closedAt: to, done: 1, carried: 0, released: 0),
      ];
  @override
  Future<DayCloseRecord?> forDay(DateTime midnight) async => null;
  @override
  Future<void> save(DayCloseRecord record) async {}
}

class _Tasks extends TaskController {
  _Tasks(this._t);
  final List<DzTask> _t;
  @override
  List<DzTask> get all => _t;
}

void main() {
  final now = DateTime(2027, 6, 14, 18);

  DzTask done(int daysAgo) => DzTask(
        id: 'd$daysAgo',
        title: 'T',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        status: TaskStatus.done,
        date: now.subtract(Duration(days: daysAgo)),
      );

  test('counts only the last 7 days', () {
    final s = WeekStory.compute(
      now: now,
      tasks: [done(0), done(3), done(6), done(7), done(20)],
      journal: const [],
      daysClosed: 4,
      profile: EnergyProfile.prior(RhythmPrior.morning),
    );
    expect(s.tasksDone, 3);
    expect(s.daysClosed, 4);
    expect(s.from, DateTime(2027, 6, 8));
    expect(s.windowSentence, contains('8 am–10 am'));
    expect(s.lift, isNull, reason: 'no journal, no lift claim');
  });

  Widget app(Widget child) => AppScopes(
        tasks: _Tasks([done(0), done(1)]),
        journal: JournalController(),
        settings: SettingsController(),
        notifications: NotificationController(),
        child: MaterialApp(theme: DzTheme.light(), home: Scaffold(body: child)),
      );

  testWidgets('hidden before day 7 of use', (tester) async {
    SharedPreferences.setMockInitialValues({
      'first_use_date': DateTime(2027, 6, 10).toIso8601String(),
    });
    await tester.pumpWidget(app(WeekStoryCard(clock: () => now, store: _Store(2))));
    await tester.pumpAndSettle();
    expect(find.text('Your week'), findsNothing);
  });

  testWidgets('shown from day 7, and renders to a PNG offline', (tester) async {
    SharedPreferences.setMockInitialValues({
      'first_use_date': DateTime(2027, 6, 8).toIso8601String(),
    });
    await tester.pumpWidget(app(WeekStoryCard(clock: () => now, store: _Store(3))));
    await tester.pumpAndSettle();
    expect(find.text('Your week'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.ancestor(of: find.byType(WeekStoryView), matching: find.byType(RepaintBoundary)).first);
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
    expect(image!.width, greaterThan(0));
  });

  testWidgets('golden: week story', tags: ['golden'], (tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: DzTheme.light(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: WeekStoryView(
            story: WeekStory(
              from: DateTime(2027, 6, 8),
              to: DateTime(2027, 6, 14),
              tasksDone: 12,
              daysClosed: 5,
              windowSentence: 'Your sharpest window: ~9 am–11 am',
              lift: 'Study days tend to feel inspired.',
            ),
          ),
        ),
      ),
    ));
    await expectLater(find.byType(WeekStoryView), matchesGoldenFile('goldens/week_story.png'));
  });
}
