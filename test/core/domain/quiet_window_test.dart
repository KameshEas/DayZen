import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/domain/quiet_window.dart';
import 'package:dayzen/core/notification_service.dart';

/// P1-10: quiet hours used to be a flag that *enabled* reminders. Now they
/// are a daily window during which reminders are skipped.
void main() {
  const overnight = QuietWindow(startMinutes: 22 * 60, endMinutes: 7 * 60);
  const daytime = QuietWindow(startMinutes: 13 * 60, endMinutes: 14 * 60);

  test('a window crossing midnight covers late evening and early morning', () {
    expect(overnight.contains(22, 30), isTrue); // the plan's example
    expect(overnight.contains(23, 59), isTrue);
    expect(overnight.contains(0, 0), isTrue);
    expect(overnight.contains(6, 59), isTrue);
    expect(overnight.contains(7, 0), isFalse); // end is exclusive
    expect(overnight.contains(12, 0), isFalse);
    expect(overnight.contains(21, 59), isFalse);
    expect(overnight.contains(22, 0), isTrue); // start is inclusive
  });

  test('a same-day window', () {
    expect(daytime.contains(13, 0), isTrue);
    expect(daytime.contains(13, 59), isTrue);
    expect(daytime.contains(14, 0), isFalse);
    expect(daytime.contains(12, 59), isFalse);
  });

  test('a zero-length window silences nothing', () {
    const empty = QuietWindow(startMinutes: 600, endMinutes: 600);
    expect(empty.contains(10, 0), isFalse);
  });

  test('HH:MM round trip and rejects junk', () {
    expect(QuietWindow.format(22 * 60), '22:00');
    expect(QuietWindow.format(7 * 60 + 5), '07:05');
    expect(QuietWindow.parse('22:00'), 22 * 60);
    expect(QuietWindow.parse(' 07:05 '), 7 * 60 + 5);
    for (final bad in [null, '', '24:00', '7:00', '12:60', 'noon']) {
      expect(QuietWindow.parse(bad), isNull, reason: '$bad');
    }
  });

  group('NotificationService.allowedAt', () {
    test('no quiet hours: every reminder is delivered', () {
      expect(NotificationService.allowedAt(DateTime(2026, 11, 22, 23), null), isTrue);
    });

    test('a 22:30 reminder is skipped with quiet hours 22:00-07:00', () {
      expect(NotificationService.allowedAt(DateTime(2026, 11, 22, 22, 30), overnight),
          isFalse);
    });

    test('the 5-minute pre-reminder is judged on its own time', () {
      // Task at 07:02: the pre-reminder (06:57) is quiet, the start (07:02) isn't.
      expect(NotificationService.allowedAt(DateTime(2026, 11, 23, 6, 57), overnight),
          isFalse);
      expect(NotificationService.allowedAt(DateTime(2026, 11, 23, 7, 2), overnight),
          isTrue);
    });
  });
}
