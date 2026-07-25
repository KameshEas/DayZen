import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:dayzen/core/data/database/app_database.dart';
import 'package:dayzen/core/data/database/database_provider.dart';
import 'package:dayzen/core/data/journal_repository.dart';
import 'package:dayzen/core/data/task_repository.dart';
import 'package:dayzen/core/domain/journal_analytics.dart';
import 'package:dayzen/core/domain/task_analytics.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/journal/models/journal_entry.dart';

/// Phase 4.3 of docs/DEVELOPMENT_PLAN.md: verify performance at a
/// realistic multi-year data scale (2,000 tasks / 1,000 journal entries).
///
/// A literal on-device scroll-performance/DevTools-timeline test isn't
/// possible in this environment (no attached device or emulator) — see
/// docs/PERFORMANCE_TESTING.md for that manual procedure. This is the
/// automated substitute: measure the actual code paths that matter (real
/// on-disk SQLite writes/reads via drift, and TaskAnalytics/
/// JournalAnalytics computation) with explicit timing budgets, so a
/// regression back toward the pre-Phase-2 full-blob-rewrite pattern fails
/// the test suite instead of only being caught by a human's vibes during
/// manual QA.
void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('dayzen_perf_test_');
    db = AppDatabase.forTesting(
      NativeDatabase(File(p.join(tempDir.path, 'perf_test.sqlite'))),
    );
    DatabaseProvider.instanceForTesting = db;
  });

  tearDown(() async {
    await db.close();
    DatabaseProvider.resetForTesting();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  DzTask makeTask(int i) => DzTask(
        id: 'perf-task-$i',
        title: 'Seeded Task $i',
        startTime: TimeOfDay(hour: 8 + (i % 12), minute: (i % 4) * 15),
        endTime: TimeOfDay(hour: 9 + (i % 12), minute: (i % 4) * 15),
        priority: TaskPriority.values[i % TaskPriority.values.length],
        category: TaskCategory.values[i % TaskCategory.values.length],
        isCompleted: i % 3 == 0,
        // Spread across ~2 years so date-range queries are realistic
        // rather than everything landing on the same day.
        date: DateTime(2024, 1, 1).add(Duration(days: i % 730)),
      );

  JournalEntry makeEntry(int i) => JournalEntry(
        id: 'perf-entry-$i',
        title: 'Seeded Entry $i',
        body: 'Body text for seeded journal entry number $i. ' * 3,
        mood: JournalMood.values[i % JournalMood.values.length],
        timestamp:
            DateTime(2024, 1, 1).add(Duration(days: i % 730, hours: i % 24)),
      );

  test('inserting 2,000 tasks (single-row ops) completes within budget',
      () async {
    final tasks = List.generate(2000, makeTask);

    final sw = Stopwatch()..start();
    for (final task in tasks) {
      await TaskRepository.insertTask(task);
    }
    sw.stop();

    debugPrint('Inserted 2000 tasks in ${sw.elapsedMilliseconds}ms '
        '(${(sw.elapsedMilliseconds / 2000).toStringAsFixed(2)}ms/task)');
    // Calibrated against observed local timing with headroom for slower
    // CI machines — see docs/PERFORMANCE_TESTING.md for the baseline
    // number this was calibrated from.
    expect(sw.elapsedMilliseconds, lessThan(30000),
        reason:
            '2000 single-row inserts should not take 30+ seconds even on '
            'a slow CI machine; a much larger regression would suggest '
            'the pre-Phase-2 full-blob-rewrite pattern has crept back in');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('loading 2,000 seeded tasks is fast', () async {
    for (final task in List.generate(2000, makeTask)) {
      await TaskRepository.insertTask(task);
    }

    final sw = Stopwatch()..start();
    final loaded = await TaskRepository.loadAll();
    sw.stop();

    expect(loaded, hasLength(2000));
    debugPrint('Loaded 2000 tasks in ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(3000),
        reason: 'A single SELECT over 2000 rows should be fast; multi-'
            'second territory would indicate a real regression');
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('TaskAnalytics stays fast over a 2,000-task in-memory list', () {
    final tasks = List.generate(2000, makeTask);
    final now = DateTime(2024, 6, 15);

    final sw = Stopwatch()..start();
    TaskAnalytics.score(tasks, now);
    TaskAnalytics.focusLabel(tasks, now);
    TaskAnalytics.weekBarFractions(tasks, now);
    TaskAnalytics.weekCompletedCount(tasks, now);
    TaskAnalytics.topPriority(tasks, now);
    TaskAnalytics.zenTasksThisWeek(tasks, now);
    sw.stop();

    debugPrint('Ran all TaskAnalytics functions over 2000 tasks in '
        '${sw.elapsedMilliseconds}ms');
    // These run synchronously on every relevant widget rebuild
    // (home_page.dart, insights_page.dart) — must stay well under a
    // frame budget (~16ms) even with generous headroom for a slow
    // test machine running all 6 functions in sequence.
    expect(sw.elapsedMilliseconds, lessThan(500),
        reason: 'Analytics run synchronously during widget builds; each '
            'function is a single linear scan and should be near-instant '
            'even at 2000 tasks');
  });

  test(
      'inserting 1,000 journal entries (single-row ops) completes within '
      'budget', () async {
    final entries = List.generate(1000, makeEntry);

    final sw = Stopwatch()..start();
    for (final entry in entries) {
      await JournalRepository.insertEntry(entry);
    }
    sw.stop();

    debugPrint(
        'Inserted 1000 journal entries in ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(20000));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('loading 1,000 seeded journal entries is fast', () async {
    for (final entry in List.generate(1000, makeEntry)) {
      await JournalRepository.insertEntry(entry);
    }

    final sw = Stopwatch()..start();
    final loaded = await JournalRepository.loadAll();
    sw.stop();

    expect(loaded, hasLength(1000));
    debugPrint('Loaded 1000 journal entries in ${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(3000));
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('JournalAnalytics stays fast over a 1,000-entry in-memory list', () {
    final entries = List.generate(1000, makeEntry);

    final sw = Stopwatch()..start();
    JournalAnalytics.thisWeekCount(entries);
    sw.stop();

    debugPrint('Ran JournalAnalytics.thisWeekCount over 1000 entries in '
        '${sw.elapsedMilliseconds}ms');
    expect(sw.elapsedMilliseconds, lessThan(200));
  });

  test(
      'adding one task after 2,000 already exist does not rewrite the '
      'other 2,000 rows (Phase 2 regression guard)', () async {
    for (final task in List.generate(2000, makeTask)) {
      await TaskRepository.insertTask(task);
    }

    final sw = Stopwatch()..start();
    await TaskRepository.insertTask(makeTask(2000));
    sw.stop();

    debugPrint('Single insert after 2000 existing rows took '
        '${sw.elapsedMilliseconds}ms');
    // The core Phase 2 claim: a single insert's cost must not scale with
    // existing row count. A generous absolute budget catches a
    // full-table-rewrite regression without being flaky about exact
    // timing on different machines.
    expect(sw.elapsedMilliseconds, lessThan(500),
        reason: 'A single-row insert should be ~O(1) regardless of table '
            'size; regressing toward multi-second territory would '
            'indicate the pre-Phase-2 full-blob-rewrite pattern has crept '
            'back in');
  }, timeout: const Timeout(Duration(minutes: 1)));
}
