import 'dart:math';

final Random _random = Random.secure();

/// A new record id: `prefix-{ms since epoch}-{6 random hex chars}`.
///
/// The server keys tasks and journal entries by id alone (no user column in
/// the primary key), so ids must be unique across every user, not just on
/// this phone. A timestamp alone isn't enough: two people saving at the same
/// millisecond would collide, and anything derived from the date (like
/// `close-{midnight}`) would collide for everyone in the same time zone.
String newId(String prefix, {DateTime? now}) {
  final ms = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final suffix = _random.nextInt(0x1000000).toRadixString(16).padLeft(6, '0');
  return '$prefix-$ms-$suffix';
}
