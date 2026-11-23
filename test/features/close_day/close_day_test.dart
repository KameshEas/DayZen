import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/day_close_repository.dart';
import 'package:dayzen/core/data/journal_repository.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/core/services/sync_coordinator.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/close_day/close_day_page.dart';
import 'package:dayzen/features/close_day/day_close_controller.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Plan M-1.10 acceptance: tasks → close → statuses, journal entry and the
/// `day_closes` row are right; works offline (signed out, no network); a
/// second close the same day edits instead of duplicating.

// Far in the future so load()'s Gentle Rollover never moves these tasks.
final _evening = DateTime(2099, 3, 4, 20, 30);
final _day = DateTime(2099, 3, 4);

DzTask _task(String id, int hour, {int rollovers = 0}) => DzTask(
      id: id,
      title: 'Task $id',
      startTime: TimeOfDay(hour: hour, minute: 0),
      endTime: TimeOfDay(hour: hour + 1, minute: 0),
      rolloverCount: rollovers,
      date: _day,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TaskController tasks;
  late JournalController journal;
  const store = DayCloseRepository();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SyncCoordinator.isSignedIn = () => false; // offline: sync is a no-op
    DatabaseProvider.instanceForTesting =
        AppDatabase.forTesting(NativeDatabase.memory());
    tasks = TaskController()..setNotificationsEnabled(false);
    journal = JournalController();
    for (final t in [_task('a', 9), _task('b', 11, rollovers: 2), _task('c', 14), _task('d', 16)]) {
      await tasks.addTask(t);
    }
  });

  tearDown(() async {
    await DatabaseProvider.instance.close();
    DatabaseProvider.resetForTesting();
  });

  DayCloseController controller({int? closes}) => DayCloseController(
        tasks: tasks,
        journal: journal,
        store: store,
        clock: () => _evening,
      );

  DzTask stored(String id) => tasks.taskById(id)!;

  group('DayCloseController', () {
    test('review lists the open tasks of the day in time order', () async {
      await tasks.setStatus('d', TaskStatus.done);
      final c = controller();
      await c.load();
      expect(c.remaining.map((t) => t.id), ['a', 'b', 'c']);
      expect(c.step, CloseStep.review);
    });

    test('done, carry and let go update the tasks; the record adds up', () async {
      var firstCloses = 0;
      final c = DayCloseController(
        tasks: tasks,
        journal: journal,
        store: store,
        clock: () => _evening,
        onFirstClose: () async => firstCloses++,
      );
      await c.load();
      await c.markDone(stored('a'));
      await c.carry(stored('b'));
      await c.letGo(stored('c'));
      await c.markDone(stored('d'));
      expect(c.remaining, isEmpty);

      expect(stored('a').status, TaskStatus.done);
      final b = stored('b');
      expect(b.status, TaskStatus.active);
      expect(b.date, _day.add(const Duration(days: 1)));
      expect(b.rolloverCount, 3);
      expect(b.originalDate, _day);
      expect(stored('c').status, TaskStatus.released);

      c
        ..continueFromReview()
        ..chooseMood(JournalMood.peaceful)
        ..continueFromMood()
        ..note = 'Good focus after lunch';
      await c.finish();

      expect(c.step, CloseStep.summary);
      final r = (await store.forDay(_day))!;
      expect((r.done, r.carried, r.released), (2, 1, 1));
      expect(DayCloseController.summaryLine(r), '✓ 2 done · 1 carried · 1 released');
      expect(firstCloses, 1);

      // Changes are stored dirty, ready to sync when back online.
      expect(await TaskRepository.hasPendingChanges('b'), isTrue);

      final entry = journal.entryById(r.journalEntryId!)!;
      expect(entry.title, DayCloseController.reflectionTitle);
      expect(entry.body, 'Good focus after lunch');
      expect(entry.mood, JournalMood.peaceful);
      expect((await JournalRepository.loadAll()), hasLength(1));
    });

    test('undo puts a task back exactly as it was', () async {
      final c = controller();
      await c.load();
      final before = stored('b');
      await c.carry(before);
      await c.letGo(stored('a'));
      expect(c.remaining.map((t) => t.id), ['c', 'd']);

      await c.undo();
      expect(stored('a').status, TaskStatus.active);
      await c.undo();
      final b = stored('b');
      expect(b.date, before.date);
      expect(b.rolloverCount, 2);
      expect(c.remaining.map((t) => t.id), ['a', 'b', 'c', 'd']);
      expect(c.canUndo, isFalse);
    });

    test('a second close the same day edits the record and journal entry', () async {
      var firstCloses = 0;
      DayCloseController make() => DayCloseController(
            tasks: tasks,
            journal: journal,
            store: store,
            clock: () => _evening,
            onFirstClose: () async => firstCloses++,
          );

      final first = make();
      await first.load();
      await first.carry(stored('a'));
      first
        ..chooseMood(JournalMood.happy)
        ..note = 'First pass';
      await first.finish();
      final firstRecord = (await store.forDay(_day))!;

      final second = make();
      await second.load();
      expect(second.isEdit, isTrue);
      expect(second.note, 'First pass', reason: 'earlier note pre-filled');
      expect(second.mood, JournalMood.happy);
      await second.markDone(stored('b'));
      second
        ..chooseMood(JournalMood.inspired)
        ..note = 'Second pass';
      await second.finish();

      expect(second.lastFinishWasEdit, isTrue);
      final r = (await store.forDay(_day))!;
      expect(r.journalEntryId, firstRecord.journalEntryId);
      expect((r.done, r.carried), (1, 1), reason: 'carried total kept');
      expect(await store.between(_day, _day), hasLength(1));
      final entries = await JournalRepository.loadAll();
      expect(entries, hasLength(1));
      expect(entries.single.body, 'Second pass');
      expect(entries.single.mood, JournalMood.inspired);
      expect(firstCloses, 1, reason: 'days_closed counts a day once');
    });

    test('no mood and no note: no journal entry, the day still closes', () async {
      final c = controller();
      await c.load();
      await c.finish();
      final r = (await store.forDay(_day))!;
      expect(r.journalEntryId, isNull);
      expect(await JournalRepository.loadAll(), isEmpty);
    });

    test('the note step opens with a draft built from the day (M-3.1)', () async {
      final c = controller();
      await c.load();
      await c.markDone(stored('a'));
      await c.carry(stored('b'));
      await c.letGo(stored('c'));
      c
        ..continueFromReview()
        ..continueFromMood();
      expect(c.noteIsDraft, isTrue);
      expect(c.note, contains('Task a'));
      expect(c.note, contains('Task b'));
      expect(c.note, contains('Task c'));
      expect(c.note, isNot(contains('Task d')), reason: 'still open, not mentioned');

      c.editNote('My own words');
      expect(c.noteIsDraft, isFalse);
      await c.finish();
      final entry = journal.entryById((await store.forDay(_day))!.journalEntryId!)!;
      expect(entry.body, 'My own words');
    });

    test('a day with nothing open starts at the mood step', () async {
      for (final id in ['a', 'b', 'c', 'd']) {
        await tasks.setStatus(id, TaskStatus.done);
      }
      final c = controller();
      await c.load();
      expect(c.step, CloseStep.mood);
    });
  });

  group('CloseDayPage', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(AppScopes(
        tasks: tasks,
        journal: journal,
        settings: SettingsController(),
        notifications: NotificationController(),
        child: MaterialApp(
          home: CloseDayPage(clock: () => _evening, onDone: () {}),
        ),
      ));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    testWidgets('swipe right carries, swipe left lets go, tap completes',
        (tester) async {
      await pump(tester);
      expect(find.text("What's still open?"), findsOneWidget);
      expect(find.text('Carried 2×'), findsOneWidget);

      await tester.drag(find.text('Task a'), const Offset(500, 0));
      await settle(tester);
      await tester.drag(find.text('Task b'), const Offset(-500, 0));
      await settle(tester);
      await tester.tap(find.text('Task c'));
      await settle(tester);

      expect(stored('a').date, _day.add(const Duration(days: 1)));
      expect(stored('b').status, TaskStatus.released);
      expect(stored('c').status, TaskStatus.done);
      expect(find.text('Undo'), findsOneWidget);
    });

    testWidgets('full flow ends on the summary line', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
      await tester.tap(find.text('Peaceful'));
      await settle(tester);
      await tester.tap(find.text('Next'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Quiet day');
      await tester.tap(find.text('Close the day'));
      await settle(tester);
      expect(find.text('Day closed.'), findsOneWidget);
      expect(find.text('✓ 0 done · 0 carried · 0 released'), findsOneWidget);
    });

    testWidgets('every card offers its actions to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      final node = tester.getSemantics(find.text('Task b'));
      final labels = node.getSemanticsData().customSemanticsActionIds;
      expect(labels, isNotNull);
      expect(labels, hasLength(3));
      handle.dispose();
    });
  });
}
