import 'dart:math' as math;

import 'package:dayzen/core/domain/reflection_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('names the first (most important) task and counts the rest', () {
    final d = ReflectionDraft.draft(
      const DayFacts(done: ['Deep work', 'Email', 'Groceries', 'Call mom']),
      seed: 0,
    );
    expect(d, 'You finished four things, including Deep work.');
  });

  test('letting go is framed kindly; carried is stated plainly', () {
    final d = ReflectionDraft.draft(
      const DayFacts(done: ['Deep work'], letGo: ['Gym'], carried: ['Taxes']),
      seed: 0,
    );
    expect(d, "You finished Deep work. You let go of Gym, and that's okay. "
        'Taxes moves to tomorrow.');
  });

  test('a day with nothing gets a quiet line, not a judgement', () {
    expect(ReflectionDraft.draft(const DayFacts()), 'A quiet day.');
  });

  test('same day, same draft; different days vary', () {
    const facts = DayFacts(done: ['A', 'B'], letGo: ['C']);
    expect(ReflectionDraft.draft(facts, seed: 7), ReflectionDraft.draft(facts, seed: 7));
    final drafts = {for (var s = 0; s < 10; s++) ReflectionDraft.draft(facts, seed: s)};
    expect(drafts.length, greaterThan(1));
  });

  test('about ten variants, none of them judging', () {
    expect(ReflectionDraft.allTemplates.length, greaterThanOrEqualTo(10));
    for (final t in ReflectionDraft.allTemplates) {
      for (final word in ['should', 'failed', 'missed', 'lazy', 'behind', 'overdue']) {
        expect(RegExp(r'\b' + word + r'\b').hasMatch(t.toLowerCase()), isFalse,
            reason: '"$t" contains "$word"');
      }
    }
  });

  test('long titles are shortened, never rewritten', () {
    final long = 'x' * 80;
    final d = ReflectionDraft.draft(DayFacts(done: [long]), seed: 0);
    expect(d, contains('${'x' * (ReflectionDraft.maxTitle - 1)}…'));
  });

  test('never invents facts: only given titles and true counts appear', () {
    final rng = math.Random(42);
    const pool = ['Run', 'Read', 'Write', 'Cook', 'Study', 'Plan', 'Call', 'Rest'];
    for (var i = 0; i < 300; i++) {
      List<String> some() => [
            for (final t in pool)
              if (rng.nextDouble() < 0.25) t,
          ];
      final facts = DayFacts(done: some(), carried: some(), letGo: some());
      final d = ReflectionDraft.draft(facts, seed: rng.nextInt(100));
      final given = {...facts.done, ...facts.carried, ...facts.letGo};
      for (final t in pool) {
        if (!given.contains(t)) {
          expect(RegExp(r'\b' + t + r'\b').hasMatch(d), isFalse,
              reason: 'invented "$t" in: $d');
        }
      }
      for (final m in RegExp(r'\b(\d+) things').allMatches(d)) {
        final n = int.parse(m[1]!);
        expect([facts.done.length, facts.carried.length, facts.letGo.length], contains(n),
            reason: 'count $n is not true in: $d');
      }
    }
  });
}
