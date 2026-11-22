/// A daily window during which task reminders stay silent (P1-10).
///
/// Times are minutes since local midnight. A window may cross midnight
/// (22:00–07:00 covers late evening and early morning). Start is inclusive,
/// end exclusive: a reminder at exactly 07:00 is delivered.
class QuietWindow {
  const QuietWindow({required this.startMinutes, required this.endMinutes})
      : assert(startMinutes >= 0 && startMinutes < 1440),
        assert(endMinutes >= 0 && endMinutes < 1440);

  /// Used when the user first turns quiet hours on.
  static const QuietWindow defaultWindow =
      QuietWindow(startMinutes: 22 * 60, endMinutes: 7 * 60);

  final int startMinutes;
  final int endMinutes;

  int get startHour => startMinutes ~/ 60;
  int get startMinute => startMinutes % 60;
  int get endHour => endMinutes ~/ 60;
  int get endMinute => endMinutes % 60;

  /// Whether a reminder at [hour]:[minute] (local) falls inside the window.
  /// A zero-length window (start == end) silences nothing.
  bool contains(int hour, int minute) {
    final m = hour * 60 + minute;
    if (startMinutes == endMinutes) return false;
    if (startMinutes < endMinutes) return m >= startMinutes && m < endMinutes;
    return m >= startMinutes || m < endMinutes; // crosses midnight
  }

  /// "HH:MM" (24 h), the format stored on the server.
  static String format(int minutes) =>
      '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  /// Parses "HH:MM"; null for anything else.
  static int? parse(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(value.trim());
    if (match == null) return null;
    return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  }

  @override
  bool operator ==(Object other) =>
      other is QuietWindow &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode => Object.hash(startMinutes, endMinutes);

  @override
  String toString() => 'QuietWindow(${format(startMinutes)}–${format(endMinutes)})';
}
