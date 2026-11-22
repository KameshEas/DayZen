import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dayzen/core/domain/brain_dump_parser.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:flutter_test/flutter_test.dart';

TaskDraft one(String input) {
  final drafts = BrainDumpParser.parse(input);
  expect(drafts, hasLength(1), reason: '$input → $drafts');
  return drafts.single;
}

void main() {
  group('fixture set (M-1.5 acceptance)', () {
    final fixture = jsonDecode(
            File('test/fixtures/brain_dumps.json').readAsStringSync())
        as Map<String, dynamic>;
    final cases = (fixture['cases'] as List).cast<Map<String, dynamic>>();

    test('has 100 cases', () => expect(cases, hasLength(100)));

    test('at least 90% of titles and 80% of times are right', () {
      var total = 0, titles = 0, times = 0, minutes = 0, splits = 0;
      final misses = <String>[];
      for (final c in cases) {
        final input = c['input'] as String;
        final expected = (c['tasks'] as List).cast<Map<String, dynamic>>();
        final got = BrainDumpParser.parse(input);
        if (got.length == expected.length) splits++;
        for (var i = 0; i < expected.length; i++) {
          total++;
          final e = expected[i];
          final g = i < got.length ? got[i] : null;
          final titleOk = g != null &&
              g.title.toLowerCase() == (e['title'] as String).toLowerCase();
          final timeOk = g != null && g.timeLabel == e['time'];
          final minutesOk =
              g != null && g.durationMinutes == (e['minutes'] as int? ?? 30);
          if (titleOk) titles++;
          if (timeOk) times++;
          if (minutesOk) minutes++;
          if (!titleOk || !timeOk) {
            misses.add('  "$input"\n    want ${e['title']} @ ${e['time']}'
                '\n    got  ${g == null ? '(nothing)' : '${g.title} @ ${g.timeLabel}'}');
          }
        }
      }
      String pct(int n) => '${(100 * n / total).toStringAsFixed(1)}%';
      // ignore: avoid_print
      print('Brain dump fixtures: $total tasks in ${cases.length} cases. '
          'Titles ${pct(titles)}, times ${pct(times)}, lengths ${pct(minutes)}, '
          'task count right in $splits/${cases.length} cases.'
          '${misses.isEmpty ? '' : '\nMisses:\n${misses.join('\n')}'}');
      expect(titles / total, greaterThanOrEqualTo(0.90));
      expect(times / total, greaterThanOrEqualTo(0.80));
    });
  });

  group('splitting', () {
    test('new lines, commas, semicolons and "then"', () {
      expect(BrainDumpParser.parse('a task\nb task, c task; d task then e task')
          .map((d) => d.title),
          ['A task', 'B task', 'C task', 'D task', 'E task']);
    });

    test('"and" splits tasks but keeps a short list together', () {
      expect(BrainDumpParser.parse('email Sam and review the deck')
          .map((d) => d.title), ['Email Sam', 'Review the deck']);
      expect(one('buy milk and eggs').title, 'Buy milk and eggs');
    });

    test('at most maxTasks drafts', () {
      final many = List.generate(50, (i) => 'task $i').join(', ');
      expect(BrainDumpParser.parse(many), hasLength(BrainDumpParser.maxTasks));
    });
  });

  group('times', () {
    String? t(String s) => one(s).timeLabel;

    test('clock times', () {
      expect(t('swim 5pm'), '17:00');
      expect(t('swim 5:30 pm'), '17:30');
      expect(t('swim 17:30'), '17:30');
      expect(t('swim 7:45am'), '07:45');
      expect(t('swim 12pm'), '12:00');
      expect(t('swim 12am'), '00:00');
    });

    test('a bare hour: 1-6 afternoon, 7-11 morning, 12 noon', () {
      expect(t('gym at 6'), '18:00');
      expect(t('gym at 1'), '13:00');
      expect(t('gym at 7'), '07:00');
      expect(t('gym at 12'), '12:00');
      expect(t('gym at 19'), '19:00');
    });

    test('a context word decides am or pm', () {
      expect(t('dinner at 8 tonight'), '20:00');
      expect(t('run at 5 in the morning'), '05:00');
      expect(t('call at 10 in the evening'), '22:00');
    });

    test('ranges give a start and a length', () {
      final d = one('workshop 2-4pm');
      expect((d.timeLabel, d.durationMinutes), ('14:00', 120));
      final e = one('class from 9 to 10:30');
      expect((e.timeLabel, e.durationMinutes), ('09:00', 90));
      final f = one('shift 11-2');
      expect((f.timeLabel, f.durationMinutes), ('11:00', 180));
    });

    test('spoken times', () {
      expect(t('physio at half 2'), '14:30');
      expect(t('physio half past 9'), '09:30');
      expect(t('practice at quarter past 4'), '16:15');
      expect(t('leave quarter to 6'), '17:45');
      expect(one('physio at half 2').title, 'Physio');
    });

    test('known limit: a time inside the title is read as the start', () {
      // "before the 2pm meeting" refers to another event; the parser can't
      // tell, so the time moves out of the title. Onboarding shows the chip
      // for editing.
      expect(one('finish slides before the 2pm meeting').timeLabel, '14:00');
    });

    test('"by" means finish by', () {
      expect(t('report by 5pm 1h'), '16:00');
    });

    test('words give approximate times', () {
      final d = one('call the bank after lunch');
      expect((d.timeLabel, d.timeIsApproximate), ('13:30', true));
      expect(t('read this evening'), '18:00');
      expect(one('swim at 5pm').timeIsApproximate, isFalse);
    });

    test('a number that is not a time is left alone', () {
      expect(t('read chapter 4'), isNull);
      expect(t('run 5k'), isNull);
      expect(t('write 500 words'), isNull);
    });

    test('impossible times are ignored', () {
      expect(t('meet at 25:00'), isNull);
      expect(t('meet at 9:75'), isNull);
    });

    test('tomorrow is noted, and removed from the title', () {
      final d = one('dentist tomorrow at 9');
      expect((d.title, d.dayOffset, d.timeLabel), ('Dentist', 1, '09:00'));
    });
  });

  group('durations', () {
    int m(String s) => one(s).durationMinutes;

    test('formats', () {
      expect(m('write 1h'), 60);
      expect(m('write 1.5h'), 90);
      expect(m('write 1h30'), 90);
      expect(m('write 2 hours'), 120);
      expect(m('write 45 min'), 45);
      expect(m('write for 20 minutes'), 20);
      expect(m('write for an hour'), 60);
      expect(m('write for half an hour'), 30);
    });

    test('default 30, clamped to 5 min..8 h, never past midnight', () {
      expect(m('write'), 30);
      expect(m('write 1 min'), 5);
      expect(m('write 20 hours'), 480);
      final late = one('party at 11:30pm 2h');
      expect(late.startMinute! + late.durationMinutes, lessThan(24 * 60));
    });
  });

  group('titles', () {
    test('filler and time words are removed, first letter capitalised', () {
      expect(one('I need to call the plumber at 3').title, 'Call the plumber');
      expect(one('  - remember to pay rent  ').title, 'Pay rent');
      expect(one('TODO: backup laptop').title, 'Backup laptop');
    });

    test('long titles are shortened', () {
      final d = one('a' * 200);
      expect(d.title.length, BrainDumpParser.maxTitleLength);
    });
  });

  group('categories', () {
    TaskCategory c(String s) => one(s).category;

    test('keyword guesses', () {
      expect(c('team meeting'), TaskCategory.work);
      expect(c('study for exam'), TaskCategory.study);
      expect(c('meditate'), TaskCategory.mindful);
      expect(c('buy groceries'), TaskCategory.personal);
      expect(c('read the report'), TaskCategory.work, reason: 'work wins');
    });
  });

  group('never throws', () {
    test('empty or symbol-only input gives the one suggested task', () {
      for (final s in ['', '   ', '\n\n', '!!!', '123', ',,,', 'at 5pm']) {
        expect(BrainDumpParser.parse(s), [BrainDumpParser.suggestion],
            reason: '"$s"');
      }
    });

    test('random input', () {
      final rnd = Random(42);
      const chars = 'abc xyz 0123456789:.,-;&\n\tapmhAPM()@!?é漢🙂 and then at by from';
      for (var i = 0; i < 2000; i++) {
        final s = String.fromCharCodes(List.generate(
            rnd.nextInt(80), (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
        final drafts = BrainDumpParser.parse(s);
        expect(drafts, isNotEmpty, reason: s);
        for (final d in drafts) {
          expect(d.title, isNotEmpty);
          expect(d.durationMinutes, inInclusiveRange(5, 480));
          if (d.startMinute != null) {
            expect(d.startMinute, inInclusiveRange(0, 24 * 60 - 1));
            expect(d.startMinute! + d.durationMinutes, lessThan(24 * 60));
          }
        }
      }
    });

    test('very long input is handled quickly', () {
      final sw = Stopwatch()..start();
      BrainDumpParser.parse('call mom at 5, ' * 5000);
      expect(sw.elapsedMilliseconds, lessThan(500));
    });
  });
}
