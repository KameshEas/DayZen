import '../../features/home/models/task_model.dart';

/// One task guessed from a brain dump: what onboarding shows as an editable
/// chip before anything is saved.
class TaskDraft {
  const TaskDraft({
    required this.title,
    this.startMinute,
    this.durationMinutes = BrainDumpParser.defaultMinutes,
    this.category = TaskCategory.personal,
    this.timeIsApproximate = false,
    this.dayOffset = 0,
    this.isSuggestion = false,
  });

  final String title;

  /// Minutes after midnight, or null when no time was given (the planner
  /// picks one).
  final int? startMinute;

  final int durationMinutes;
  final TaskCategory category;

  /// The time came from a word like "morning" or "after lunch", not a clock
  /// time, so the UI can present it as a suggestion.
  final bool timeIsApproximate;

  /// 0 for today, 1 for "tomorrow".
  final int dayOffset;

  /// True for the stand-in task returned when nothing usable was typed.
  final bool isSuggestion;

  /// "17:30", or null.
  String? get timeLabel => startMinute == null
      ? null
      : '${(startMinute! ~/ 60).toString().padLeft(2, '0')}:'
          '${(startMinute! % 60).toString().padLeft(2, '0')}';

  @override
  String toString() =>
      'TaskDraft($title, ${timeLabel ?? '-'}, ${durationMinutes}m, ${category.name})';
}

/// Turns free text ("gym at 6, email Sam and review the deck 1h, call mom
/// after lunch") into [TaskDraft]s.
///
/// - Splits on new lines, commas, semicolons, "then", and "and" (but keeps
///   "buy milk and eggs" whole: an "and" followed by a single word after a
///   multi-word phrase joins a list, it doesn't start a task).
/// - Times: "at 5", "5pm", "5:30 pm", "17:30", ranges like "2-4pm", "noon",
///   spoken times ("half 2", "quarter past 4"), and words ("morning",
///   "after lunch", "tonight"). A bare hour from 1 to 6
///   is read as afternoon, 7 to 11 as morning, unless a word says otherwise.
///   "by 5" means finish by 5.
/// - Durations: "1h", "1.5 hours", "1h30", "45 min", "an hour", "half an
///   hour". Default [defaultMinutes].
/// - Category from a keyword map; [TaskCategory.personal] when nothing
///   matches.
///
/// Pure and offline. Never throws: if nothing usable is found, or something
/// unexpected goes wrong, the result is one suggested task.
abstract final class BrainDumpParser {
  static const defaultMinutes = 30;
  static const maxTasks = 20;
  static const maxTitleLength = 80;
  static const _maxInput = 2000;

  /// What an empty or unreadable dump gives back.
  static const suggestion = TaskDraft(
    title: 'Plan my day',
    durationMinutes: 15,
    category: TaskCategory.mindful,
    isSuggestion: true,
  );

  static List<TaskDraft> parse(String input) {
    try {
      final text =
          input.length > _maxInput ? input.substring(0, _maxInput) : input;
      final drafts = <TaskDraft>[];
      for (final piece in _split(text)) {
        final d = _parsePiece(piece);
        if (d != null) drafts.add(d);
        if (drafts.length == maxTasks) break;
      }
      return drafts.isEmpty ? const [suggestion] : drafts;
    } catch (_) {
      return const [suggestion];
    }
  }

  // ── Splitting ──────────────────────────────────────────────────────────

  static final _hardBreak = RegExp(
    r'[\n\r;•]+|,|\.\s+(?=[A-Za-z])|\s+\d{1,2}[.)]\s+(?=[A-Za-z])'
    r'|\s+(?:and\s+)?then\s+|\s+also\s+',
    caseSensitive: false,
  );
  static final _and = RegExp(r'\s+(?:and|&|\+)\s+', caseSensitive: false);

  static Iterable<String> _split(String text) sync* {
    for (final chunk in text.split(_hardBreak)) {
      final parts = chunk.split(_and);
      var current = parts.first;
      for (final next in parts.skip(1)) {
        if (_joinsList(current, next)) {
          current = '$current and $next';
        } else {
          yield current;
          current = next;
        }
      }
      yield current;
    }
  }

  /// "buy milk and eggs", "call mom and dad": a one-word right side after a
  /// multi-word left side is part of the same task.
  static bool _joinsList(String left, String right) {
    final r = _words(right);
    final l = _words(left);
    return r.length == 1 && l.length > 1 && !_hasTime(right);
  }

  static List<String> _words(String s) =>
      s.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

  static bool _hasTime(String s) =>
      RegExp(r'\d|noon|morning|evening|afternoon|tonight|lunch',
              caseSensitive: false)
          .hasMatch(s);

  // ── One task ───────────────────────────────────────────────────────────

  static TaskDraft? _parsePiece(String raw) {
    var s = ' ${raw.trim()} ';
    if (!RegExp(r'[A-Za-z]').hasMatch(s)) return null;

    int? start;
    int? duration;
    var approximate = false;
    var dayOffset = 0;
    bool? pm; // from context words: true = afternoon/evening, false = morning
    var finishBy = false;

    String cut(Match m, [String with_ = ' ']) =>
        s = s.replaceRange(m.start, m.end, with_);

    // Day words.
    final day = RegExp(r'\b(today|tomorrow|tmrw|tmr)\b', caseSensitive: false)
        .firstMatch(s);
    if (day != null) {
      if (!day.group(1)!.toLowerCase().startsWith('today')) dayOffset = 1;
      cut(day);
    }

    // Part-of-day phrases that are only there to give a time
    // ("in the morning", "this evening", "tonight", "after lunch").
    final phrase = RegExp(
      r'\b(?:(?:in the|this|tomorrow|every)\s+)?(morning|afternoon|evening|night)\b(?=\s*$)'
      r'|\b(?:in the|this)\s+(morning|afternoon|evening)\b'
      r'|\b(tonight)\b'
      r'|\b(after|before|at|around)\s+(lunch|dinner|breakfast|work)\b'
      r'|\b(lunchtime|midday|noon)\b',
      caseSensitive: false,
    ).firstMatch(s);
    String? fuzzyWord;
    if (phrase != null) {
      final word = phrase.group(1) ??
          phrase.group(2) ??
          phrase.group(3) ??
          phrase.group(6) ??
          '${phrase.group(4)} ${phrase.group(5)}';
      fuzzyWord = word.toLowerCase();
      cut(phrase);
    } else {
      // A part-of-day word inside the title ("morning run") stays in the
      // title but still suggests a time.
      final inTitle = RegExp(r'\b(morning|afternoon|evening|night)\b',
              caseSensitive: false)
          .firstMatch(s);
      if (inTitle != null) fuzzyWord = inTitle.group(1)!.toLowerCase();
    }
    if (fuzzyWord != null) {
      pm = !(fuzzyWord == 'morning' || fuzzyWord.endsWith('breakfast'));
    }

    // Durations first, so "1.5h" isn't read as a clock time.
    duration = _takeDuration(s, (m) => cut(m));

    // Ranges: "2-4pm", "from 9 to 11", "10:30–12".
    final range = RegExp(
      r'\b(?:from\s+)?(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)?\s*(?:-|–|to|till|until)\s*(\d{1,2})(?:[:.](\d{2}))?\s*(am|pm)?\b',
      caseSensitive: false,
    ).firstMatch(s);
    if (range != null && _validHour(range.group(1)) && _validHour(range.group(4))) {
      final endMer = range.group(6)?.toLowerCase();
      final startMer = range.group(3)?.toLowerCase();
      final h1 = int.parse(range.group(1)!);
      final h2 = int.parse(range.group(4)!);
      final a = _clock(h1, _min(range.group(2)), startMer ?? (endMer != null && h1 <= h2 ? endMer : null), pm);
      var b = _clock(h2, _min(range.group(5)), endMer, pm ?? (a != null && a >= 12 * 60));
      if (a != null && b != null) {
        if (b <= a && b + 12 * 60 < 24 * 60) b += 12 * 60;
        if (b > a) {
          start = a;
          duration = b - a;
          cut(range);
        }
      }
    }

    // Clock times: "5:30pm", "17:30", "5pm".
    if (start == null) {
      final clock = RegExp(
        r'(?:\b(at|@|around|by|from)\s*)?\b(\d{1,2})(?:[:.](\d{2}))\s*(am|pm|a\.m\.|p\.m\.)?(?!\d)'
        r'|(?:\b(at|@|around|by|from)\s*)?\b(\d{1,2})\s*(am|pm|a\.m\.|p\.m\.)(?![a-z])',
        caseSensitive: false,
      ).firstMatch(s);
      if (clock != null) {
        final h = clock.group(2) ?? clock.group(6);
        final mer = (clock.group(4) ?? clock.group(7))?.toLowerCase().replaceAll('.', '');
        final value = _clock(int.parse(h!), _min(clock.group(3)), mer, pm,
            twentyFour: clock.group(3) != null && mer == null);
        if (value != null) {
          start = value;
          finishBy = (clock.group(1) ?? clock.group(5))?.toLowerCase() == 'by';
          cut(clock);
        }
      }
    }

    // Spoken: "half 2", "half past 2", "quarter past 4", "quarter to 6".
    if (start == null) {
      final spoken = RegExp(
        r'(?:\b(at|around|by)\s+)?\b(half past|half|quarter past|quarter to)\s+(\d{1,2})\b(?![:.]\d)',
        caseSensitive: false,
      ).firstMatch(s);
      if (spoken != null) {
        final hour = _clock(int.parse(spoken.group(3)!), 0, null, pm);
        if (hour != null) {
          final kind = spoken.group(2)!.toLowerCase();
          final offset = kind.startsWith('half')
              ? 30
              : kind == 'quarter past'
                  ? 15
                  : -15;
          start = (hour + offset).clamp(0, 24 * 60 - 5);
          finishBy = spoken.group(1)?.toLowerCase() == 'by';
          cut(spoken);
        }
      }
    }

    // "at 5", "around 7", "by 3".
    if (start == null) {
      // Not when a clock time follows that failed to parse ("at 9:75").
      final at = RegExp(r'(?:\b(at|around|by)|@)\s*(\d{1,2})\b(?![:.]\d)(?!\s*(?:%|st|nd|rd|th))',
              caseSensitive: false)
          .firstMatch(s);
      if (at != null) {
        final value = _clock(int.parse(at.group(2)!), 0, null, pm);
        if (value != null) {
          start = value;
          finishBy = at.group(1)?.toLowerCase() == 'by';
          cut(at);
        }
      }
    }

    // Word times, only when no clock time was given.
    if (start == null && fuzzyWord != null) {
      start = _fuzzyTimes[fuzzyWord];
      approximate = start != null;
    }

    duration ??= defaultMinutes;
    duration = duration.clamp(5, 8 * 60);
    if (start != null && finishBy) {
      start = (start - duration).clamp(0, 24 * 60 - 5);
    }
    if (start != null && start + duration > 24 * 60 - 1) {
      duration = (24 * 60 - 1 - start).clamp(5, 8 * 60);
    }

    final title = _cleanTitle(s);
    if (title.isEmpty) return null;
    return TaskDraft(
      title: title,
      startMinute: start,
      durationMinutes: duration,
      category: categoryFor(title),
      timeIsApproximate: approximate,
      dayOffset: dayOffset,
    );
  }

  static const _fuzzyTimes = <String, int>{
    'morning': 9 * 60,
    'afternoon': 14 * 60,
    'evening': 18 * 60,
    'night': 20 * 60,
    'tonight': 20 * 60,
    'noon': 12 * 60,
    'midday': 12 * 60,
    'lunchtime': 12 * 60 + 30,
    'at lunch': 12 * 60 + 30,
    'around lunch': 12 * 60 + 30,
    'before lunch': 11 * 60 + 30,
    'after lunch': 13 * 60 + 30,
    'before breakfast': 7 * 60,
    'after breakfast': 8 * 60 + 30,
    'at breakfast': 8 * 60,
    'around breakfast': 8 * 60,
    'before dinner': 18 * 60,
    'after dinner': 20 * 60,
    'at dinner': 19 * 60,
    'around dinner': 19 * 60,
    'before work': 8 * 60,
    'after work': 18 * 60,
    'at work': 10 * 60,
    'around work': 10 * 60,
  };

  static bool _validHour(String? h) =>
      h != null && int.parse(h) >= 0 && int.parse(h) <= 23;

  static int _min(String? m) => m == null ? 0 : int.parse(m);

  /// Minutes after midnight for an hour as typed, or null if it can't be a
  /// time. Without am/pm, a 24-hour value (13-23, or "08:00" style) is taken
  /// as is; otherwise [pm] from context decides, then the 1-6 → afternoon,
  /// 7-11 → morning rule.
  static int? _clock(int hour, int minute, String? meridiem, bool? pm,
      {bool twentyFour = false}) {
    if (minute > 59 || hour > 23) return null;
    if (meridiem != null) {
      if (hour < 1 || hour > 12) return null;
      final h = (hour % 12) + (meridiem.startsWith('p') ? 12 : 0);
      return h * 60 + minute;
    }
    if (hour >= 13 || hour == 0) return hour * 60 + minute;
    if (twentyFour && hour >= 7 && pm == null) return hour * 60 + minute;
    if (hour == 12) return 12 * 60 + minute;
    final afternoon = pm ?? hour <= 6;
    return (afternoon ? hour + 12 : hour) * 60 + minute;
  }

  static int? _takeDuration(String s, void Function(Match) cut) {
    final patterns = <(RegExp, int Function(Match))>[
      (
        RegExp(r'\b(?:for\s+)?(\d+(?:\.\d+)?)\s*(?:h|hr|hrs|hour|hours)\s*(?:and\s*)?(\d{1,2})\s*(?:m|min|mins|minute|minutes)?\b',
            caseSensitive: false),
        (m) => (double.parse(m.group(1)!) * 60).round() + int.parse(m.group(2)!),
      ),
      (
        RegExp(r'\b(?:for\s+)?(\d+(?:\.\d+)?)\s*(?:h|hr|hrs|hour|hours)\b', caseSensitive: false),
        (m) => (double.parse(m.group(1)!) * 60).round(),
      ),
      (
        RegExp(r'\b(?:for\s+)?(\d+)\s*(?:m|min|mins|minute|minutes)\b', caseSensitive: false),
        (m) => int.parse(m.group(1)!),
      ),
      (
        RegExp(r'\b(?:for\s+)?(?:half an hour|half hour|30 mins?)\b', caseSensitive: false),
        (_) => 30,
      ),
      (
        RegExp(r'\b(?:for\s+)?(?:an|one|1)\s+hour\b', caseSensitive: false),
        (_) => 60,
      ),
      (
        RegExp(r'\b(?:for\s+)?(?:a\s+)?(?:couple of|couple|two)\s+hours\b', caseSensitive: false),
        (_) => 120,
      ),
      (
        RegExp(r'\b(?:for\s+)?(?:a\s+)?quarter (?:of an )?hour\b', caseSensitive: false),
        (_) => 15,
      ),
    ];
    for (final (re, value) in patterns) {
      final m = re.firstMatch(s);
      if (m != null) {
        final v = value(m);
        cut(m);
        return v;
      }
    }
    return null;
  }

  // ── Titles ─────────────────────────────────────────────────────────────

  static final _leadingFiller = RegExp(
    r"^(?:(?:and|then|also|plus|maybe|probably|oh|ok|okay|so|i|i'll|i will|i need to|i have to|i've got to|i gotta|i must|i should|i want to|i'd like to|need to|have to|got to|gotta|must|should|want to|remember to|don't forget to|dont forget to|try to|todo|to do|to-do)\b[:\s,-]*)+",
    caseSensitive: false,
  );
  static final _bullet = RegExp(r'^\s*(?:[-*–>]+|\d+[.)])\s*');
  static final _danglingEnd = RegExp(
      r'\s+(?:and|at|for|by|from|around|on|in|the|this|to|till|until|@|-|–)\s*$',
      caseSensitive: false);
  static final _danglingStart =
      RegExp(r'^(?:at|for|by|from|around|@|-|–)\s+', caseSensitive: false);

  static String _cleanTitle(String s) {
    var t = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    t = t.replaceFirst(_bullet, '');
    t = t.replaceFirst(_leadingFiller, '');
    for (var i = 0; i < 3; i++) {
      t = t
          .replaceAll(RegExp(r'^[\s.,;:!?()\[\]"]+|[\s.,;:!?()\[\]"]+$'), '')
          .replaceFirst(_danglingEnd, '')
          .replaceFirst(_danglingStart, '');
    }
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (!RegExp(r'[A-Za-z]').hasMatch(t)) return '';
    if (t.length > maxTitleLength) t = '${t.substring(0, maxTitleLength - 1).trimRight()}…';
    return t[0].toUpperCase() + t.substring(1);
  }

  // ── Categories ─────────────────────────────────────────────────────────

  static final _categoryWords = <TaskCategory, RegExp>{
    TaskCategory.work: RegExp(
      r'\b(work|meeting|meet with|standup|stand-up|sync|1:1|one-on-one|email|emails|inbox|slack|report|deck|slides|presentation|proposal|client|boss|manager|team|project|deadline|invoice|budget|review|pr|code|coding|deploy|bug|ticket|jira|spreadsheet|interview|office|call with|zoom|demo|roadmap|okrs?|quarterly|payroll|contract)\b',
      caseSensitive: false,
    ),
    TaskCategory.study: RegExp(
      r'\b(study|studying|revise|revision|homework|assignment|essay|thesis|exam|quiz|test prep|lecture|class|course|chapter|textbook|flashcards|notes|learn|learning|practice|practise|tutorial|duolingo|spanish|french|german|math|maths|physics|chemistry|biology|history|lesson|read)\b',
      caseSensitive: false,
    ),
    TaskCategory.mindful: RegExp(
      r'\b(meditate|meditation|yoga|stretch|stretching|breathe|breathing|breathwork|journal|journaling|gratitude|walk|nap|rest|relax|unwind|therapy|mindful|mindfulness|pray|prayer|sauna|bath|sleep early|screen-free|digital detox)\b',
      caseSensitive: false,
    ),
  };

  /// Keyword guess; [TaskCategory.personal] when nothing matches. Work wins
  /// over study, which wins over mindful ("read the report" is work).
  static TaskCategory categoryFor(String title) {
    for (final entry in _categoryWords.entries) {
      if (entry.value.hasMatch(title)) return entry.key;
    }
    return TaskCategory.personal;
  }
}
