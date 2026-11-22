import 'package:shared_preferences/shared_preferences.dart';

/// Progressive moments (plan M-3.4): small touches that arrive as the app
/// is used, each at most once.
enum Moment {
  /// Day 0, from 18:00: "Your first evening. Close the day?"
  firstCloseInvite,

  /// The first journal entry: offer a PIN to protect the journal.
  pinOffer,

  /// Day 3: "Your rhythm is forming".
  rhythmForming,

  /// Day 7, signed out: a soft offer to sync.
  syncOffer,
}

class MomentsService {
  MomentsService._();

  static const _firedKey = 'moments_fired';
  static const eveningHour = 18;

  /// Days of use before Insights shows its charts (day 7).
  static const insightsUnlockDay = 6;

  /// Moments due on the Home screen, most relevant first. Pure.
  /// [firstUse] is the local midnight of the first day of use.
  static List<Moment> dueOnHome({
    required DateTime firstUse,
    required DateTime now,
    required Set<Moment> fired,
    required bool signedIn,
  }) {
    final day = dayOfUse(firstUse, now);
    return [
      if (day == 0 && now.hour >= eveningHour && !fired.contains(Moment.firstCloseInvite))
        Moment.firstCloseInvite,
      if (day >= 3 && !fired.contains(Moment.rhythmForming)) Moment.rhythmForming,
      if (day >= 7 && !signedIn && !fired.contains(Moment.syncOffer)) Moment.syncOffer,
    ];
  }

  /// Whether to offer a PIN after a journal entry is saved. Pure.
  static bool shouldOfferPin({
    required int journalEntries,
    required bool hasPin,
    required bool pinOptedOut,
    required Set<Moment> fired,
  }) =>
      journalEntries >= 1 &&
      !hasPin &&
      !pinOptedOut &&
      !fired.contains(Moment.pinOffer);

  /// Days until Insights unlocks (0 = unlocked). Unknown first use: 0.
  static int insightsUnlocksIn({DateTime? firstUse, required DateTime now}) {
    if (firstUse == null) return 0;
    final left = insightsUnlockDay - dayOfUse(firstUse, now);
    return left > 0 ? left : 0;
  }

  /// 0 on the first day, 1 the next, ...
  static int dayOfUse(DateTime firstUse, DateTime now) {
    final a = DateTime(firstUse.year, firstUse.month, firstUse.day);
    final b = DateTime(now.year, now.month, now.day);
    return DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;
  }

  static Future<Set<Moment>> fired() async {
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_firedKey) ?? const <String>[];
    return {
      for (final n in names) ?Moment.values.asNameMap()[n],
    };
  }

  static Future<void> markFired(Moment m) async {
    final prefs = await SharedPreferences.getInstance();
    final names = {...(prefs.getStringList(_firedKey) ?? const <String>[]), m.name};
    await prefs.setStringList(_firedKey, names.toList());
  }
}
