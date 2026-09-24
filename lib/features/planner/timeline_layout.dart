import '../home/models/task_model.dart';

/// Where one card goes on the day timeline.
class TimelineSlot {
  const TimelineSlot({
    required this.event,
    required this.count,
    required this.column,
    required this.columns,
  });

  /// The event to draw. When [count] is more than one it stands for that many
  /// identical events.
  final PlannerEvent event;

  /// How many identical events this card stands for (1 for an ordinary one).
  final int count;

  /// Which column this card is in (0 is leftmost), of [columns] in its group of
  /// overlapping cards.
  final int column;
  final int columns;
}

int _start(PlannerEvent e) => e.hour * 60 + e.minute;

/// Lays a day's events out for the timeline.
///
/// Two things went wrong when every card was placed at its start time and
/// nothing else: events that overlap were drawn on top of each other, and
/// identical events (the same task saved twice) stacked into one thick shadow.
///
/// So identical events (same title, start and length) are shown as one card that
/// says how many there are, and events that overlap are placed side by side in
/// columns, the way a calendar does.
///
/// [minEventMinutes] is the shortest a card can be drawn (a 15-minute event still
/// needs room for its text), so two events closer together than that count as
/// overlapping even though their times do not.
List<TimelineSlot> layoutTimeline(
  List<PlannerEvent> events, {
  int minEventMinutes = 43,
}) {
  // 1. Collapse identical events into one, remembering how many.
  final merged = <String, ({PlannerEvent event, int count, int done})>{};
  final order = <String>[];
  for (final e in events) {
    final key = '${e.title}|${_start(e)}|${e.durationMinutes}';
    final prev = merged[key];
    if (prev == null) {
      order.add(key);
      merged[key] = (event: e, count: 1, done: e.isCompleted ? 1 : 0);
    } else {
      merged[key] = (
        event: prev.event,
        count: prev.count + 1,
        done: prev.done + (e.isCompleted ? 1 : 0),
      );
    }
  }
  final items = <({PlannerEvent event, int count})>[
    for (final key in order)
      (
        // A card is "done" only when every event it stands for is.
        event: merged[key]!.done == merged[key]!.count
            ? merged[key]!.event
            : _notCompleted(merged[key]!.event),
        count: merged[key]!.count,
      ),
  ]..sort((a, b) {
      final byStart = _start(a.event).compareTo(_start(b.event));
      return byStart != 0
          ? byStart
          : b.event.durationMinutes.compareTo(a.event.durationMinutes);
    });

  // 2. Group into clusters of events that overlap one another, and give each
  //    event in a cluster the first column that is free at its start.
  final slots = <TimelineSlot>[];
  var i = 0;
  while (i < items.length) {
    final cluster = <({PlannerEvent event, int count})>[];
    final columnEnds = <int>[]; // when each column becomes free
    final columnOf = <int>[];
    var clusterEnd = -1;

    while (i < items.length) {
      final item = items[i];
      final start = _start(item.event);
      if (cluster.isNotEmpty && start >= clusterEnd) break; // a new cluster begins
      final end = start +
          (item.event.durationMinutes < minEventMinutes
              ? minEventMinutes
              : item.event.durationMinutes);

      var col = columnEnds.indexWhere((freeAt) => freeAt <= start);
      if (col == -1) {
        col = columnEnds.length;
        columnEnds.add(end);
      } else {
        columnEnds[col] = end;
      }
      columnOf.add(col);
      cluster.add(item);
      if (end > clusterEnd) clusterEnd = end;
      i++;
    }

    for (var k = 0; k < cluster.length; k++) {
      slots.add(TimelineSlot(
        event: cluster[k].event,
        count: cluster[k].count,
        column: columnOf[k],
        columns: columnEnds.length,
      ));
    }
  }
  return slots;
}

PlannerEvent _notCompleted(PlannerEvent e) => PlannerEvent(
      title: e.title,
      subtitle: e.subtitle,
      hour: e.hour,
      minute: e.minute,
      durationMinutes: e.durationMinutes,
      accentColor: e.accentColor,
      icon: e.icon,
    );
