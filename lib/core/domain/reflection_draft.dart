/// Evening auto-draft (plan M-3.1): a first line for the Close the Day note,
/// written only from the day's facts. The user edits it before saving.
///
/// Pure Dart. It never invents anything: every name in the draft is one of
/// the titles passed in, every number is a count of them.
library;

class DayFacts {
  const DayFacts({
    this.done = const [],
    this.carried = const [],
    this.letGo = const [],
  });

  /// Titles of tasks finished today, most important first.
  final List<String> done;

  /// Titles carried to tomorrow.
  final List<String> carried;

  /// Titles let go.
  final List<String> letGo;

  bool get isEmpty => done.isEmpty && carried.isEmpty && letGo.isEmpty;
}

class ReflectionDraft {
  ReflectionDraft._();

  /// Titles longer than this are shortened with "…".
  static const maxTitle = 40;

  /// A draft for [facts]. [seed] (e.g. the date) picks among the templates,
  /// so the same day always drafts the same text and different days vary.
  static String draft(DayFacts facts, {int seed = 0}) {
    if (facts.isEmpty) return _pick(_quiet, seed);
    final parts = <String>[];

    if (facts.done.isNotEmpty) {
      final n = facts.done.length;
      final first = _q(facts.done.first);
      final t = n == 1
          ? _pick(_doneOne, seed).replaceAll('{t}', first)
          : _pick(_doneMany, seed)
              .replaceAll('{n}', _count(n))
              .replaceAll('{t}', first);
      parts.add(t);
    }

    if (facts.letGo.isNotEmpty) {
      final t = facts.letGo.length == 1
          ? _pick(_letGoOne, seed).replaceAll('{t}', _q(facts.letGo.first))
          : _pick(_letGoMany, seed).replaceAll('{n}', '${facts.letGo.length}');
      parts.add(t);
    }

    if (facts.carried.isNotEmpty) {
      final t = facts.carried.length == 1
          ? _pick(_carriedOne, seed).replaceAll('{t}', _q(facts.carried.first))
          : _pick(_carriedMany, seed).replaceAll('{n}', '${facts.carried.length}');
      parts.add(t);
    }

    return parts.join(' ');
  }

  static String _pick(List<String> options, int seed) =>
      options[seed.abs() % options.length];

  static String _q(String title) {
    final t = title.trim();
    return t.length <= maxTitle ? t : '${t.substring(0, maxTitle - 1).trimRight()}…';
  }

  static String _count(int n) => switch (n) {
        2 => 'two things',
        3 => 'three things',
        4 => 'four things',
        5 => 'five things',
        _ => '$n things',
      };

  // Ten-odd variants across the slots. Calm, specific, never judging.
  static const _doneOne = [
    'You finished {t}.',
    'Got {t} done today.',
    '{t} is done.',
  ];
  static const _doneMany = [
    'You finished {n}, including {t}.',
    '{n} done today, {t} among them.',
    'Got through {n}. {t} was one of them.',
  ];
  static const _letGoOne = [
    'You let go of {t}, and that\'s okay.',
    '{t} could wait. Letting it go was a choice.',
  ];
  static const _letGoMany = [
    'You let {n} things go, and that\'s okay.',
    '{n} things could wait. That was a choice, not a slip.',
  ];
  static const _carriedOne = [
    '{t} moves to tomorrow.',
    '{t} carries over to tomorrow.',
  ];
  static const _carriedMany = [
    '{n} things move to tomorrow.',
    '{n} things carry over to tomorrow.',
  ];
  static const _quiet = [
    'A quiet day.',
    'Nothing planned today, and that\'s fine.',
  ];

  /// Every template, for tests.
  static List<String> get allTemplates => [
        ..._doneOne, ..._doneMany, ..._letGoOne, ..._letGoMany,
        ..._carriedOne, ..._carriedMany, ..._quiet,
      ];
}
