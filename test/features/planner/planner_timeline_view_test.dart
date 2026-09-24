import 'package:dayzen/core/design_system/design_system.dart' hide TaskPriority;
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/planner/widgets/planner_timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PlannerEvent _e(String title, int hour, {int minute = 0, int minutes = 60, bool done = false}) =>
    PlannerEvent(
      title: title,
      subtitle: '$hour:${minute.toString().padLeft(2, '0')}',
      hour: hour,
      minute: minute,
      durationMinutes: minutes,
      accentColor: Colors.blue,
      icon: Icons.circle_outlined,
      isCompleted: done,
    );

Widget _timeline(
  List<PlannerEvent> events, {
  int hour = 12,
  int minute = 0,
  bool showNow = true,
}) =>
    MaterialApp(
      theme: DzTheme.light(),
      home: Scaffold(
        body: PlannerTimelineView(
          events: events,
          currentHour: hour,
          currentMinute: minute,
          showNow: showNow,
        ),
      ),
    );

/// About 571 x 1200 logical pixels: shorter than the 17-hour timeline, so it scrolls.
Future<void> _short(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1500, 1500);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

double _scrolled(WidgetTester tester) =>
    tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;

void main() {
  group('identical events', () {
    testWidgets('show as one card with a count, not a pile of shadows', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([for (var i = 0; i < 7; i++) _e('ffft', 18)]));

      expect(find.text('ffft'), findsOneWidget);
      expect(find.text('×7'), findsOneWidget);
    });

    testWidgets('an ordinary event has no count', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Standup', 9)]));

      expect(find.text('Standup'), findsOneWidget);
      expect(find.textContaining('×'), findsNothing);
    });

    testWidgets('the count is announced', (tester) async {
      final handle = tester.ensureSemantics();
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('a', 9), _e('a', 9), _e('a', 9)]));

      expect(find.bySemanticsLabel('3 identical tasks'), findsOneWidget);
      handle.dispose();
    });
  });

  group('overlapping events', () {
    testWidgets('sit side by side at the same height, not on top of each other', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Left', 9), _e('Right', 9, minute: 30)]));

      final left = tester.getTopLeft(find.text('Left'));
      final right = tester.getTopLeft(find.text('Right'));
      expect(right.dx, greaterThan(left.dx + 40), reason: 'in separate columns');
    });

    testWidgets('each is narrower than a lone event', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Lone', 9)]));
      final loneWidth = tester.getSize(find.ancestor(of: find.text('Lone'), matching: find.byType(Container)).first).width;

      await tester.pumpWidget(_timeline([_e('A', 9), _e('B', 9)]));
      final sharedWidth = tester.getSize(find.ancestor(of: find.text('A'), matching: find.byType(Container)).first).width;
      expect(sharedWidth, lessThan(loneWidth * 0.7));
    });

    testWidgets('a lone event later in the day is not squeezed by an earlier pair', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('A', 9), _e('B', 9), _e('Later', 14)]));

      final a = tester.getSize(find.ancestor(of: find.text('A'), matching: find.byType(Container)).first).width;
      final later = tester.getSize(find.ancestor(of: find.text('Later'), matching: find.byType(Container)).first).width;
      expect(later, greaterThan(a * 1.5));
    });

    testWidgets('no overflow even with many at once', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([
        for (var i = 0; i < 6; i++) _e('Task $i', 9, minute: i * 5),
      ]));
      expect(tester.takeException(), isNull);
    });
  });

  group('the "now" marker', () {
    testWidgets('shows the time with a leading zero', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([], hour: 9, minute: 30));
      expect(find.text('09:30'), findsOneWidget);
    });

    testWidgets('does not hide the hour labels when it is between them', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([], hour: 9, minute: 30));
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
    });

    testWidgets('the hour label it sits on steps aside, not printed underneath it', (tester) async {
      await _short(tester);
      // 17:59 is a minute from 18:00: the pill would cover that label.
      await tester.pumpWidget(_timeline([], hour: 17, minute: 59));

      expect(find.text('17:59'), findsOneWidget);
      expect(find.text('18:00'), findsNothing);
      expect(find.text('17:00'), findsOneWidget);
      expect(find.text('19:00'), findsOneWidget);
    });

    testWidgets('right on the hour, the pill replaces that hour label', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([], hour: 12, minute: 0));
      expect(find.text('12:00'), findsOneWidget); // the pill itself
      expect(find.text('11:00'), findsOneWidget);
    });

    testWidgets('is not shown at all on another day', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([], hour: 10, minute: 30, showNow: false));

      expect(find.text('10:30'), findsNothing);
      // ...and the hour label is in its place.
      expect(find.text('10:00'), findsOneWidget);
    });
  });

  group('opening position', () {
    testWidgets('a day that starts late opens at its first task, not at the top', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Evening plan', 18)], showNow: false));
      await tester.pump();

      expect(_scrolled(tester), greaterThan(0));
      final y = tester.getTopLeft(find.text('Evening plan')).dy;
      expect(y, inInclusiveRange(0, 1200), reason: 'the first plan is on screen');
    });

    testWidgets('opens half an hour above the first plan', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Plan', 12)], showNow: false));
      await tester.pump();

      // (12 - 6 - 0.5) hours at 72px an hour.
      expect(_scrolled(tester), closeTo(5.5 * 72, 1));
    });

    testWidgets('uses the earliest plan of the day, whatever order they come in', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Late', 16), _e('Early', 10)], showNow: false));
      await tester.pump();

      expect(_scrolled(tester), closeTo(3.5 * 72, 1));
    });

    testWidgets('a day that starts early needs no scrolling', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Early', 6, minute: 30)], showNow: false));
      await tester.pump();

      expect(_scrolled(tester), 0);
    });

    testWidgets('an empty day starts at the top', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([], showNow: false));
      await tester.pump();

      expect(_scrolled(tester), 0);
    });

    testWidgets('a late plan is never scrolled off the end', (tester) async {
      await _short(tester);
      await tester.pumpWidget(_timeline([_e('Very late', 22)], showNow: false));
      await tester.pump();

      expect(tester.takeException(), isNull);
      final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
      expect(position.pixels, lessThanOrEqualTo(position.maxScrollExtent));
      expect(find.text('Very late'), findsOneWidget);
    });
  });
}
