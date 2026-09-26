import 'package:dayzen/core/design_system/design_system.dart' hide TaskPriority;
import 'package:dayzen/core/domain/planner_dates.dart';
import 'package:dayzen/features/ai_optimization_controller.dart';
import 'package:dayzen/features/app_data.dart';
import 'package:dayzen/features/home/models/task_model.dart';
import 'package:dayzen/features/insights_controller.dart';
import 'package:dayzen/features/journal_controller.dart';
import 'package:dayzen/features/notification_controller.dart';
import 'package:dayzen/features/planner/planner_page.dart';
import 'package:dayzen/features/planner/planner_selection.dart';
import 'package:dayzen/features/settings/settings_controller.dart';
import 'package:dayzen/features/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Tasks extends TaskController {
  _Tasks(this._tasks);
  final List<DzTask> _tasks;
  @override
  List<DzTask> get all => _tasks;
  @override
  List<DzTask> forDate(DateTime date) => _tasks.where((t) => t.isSameDay(dayOnly(date))).toList();
}

final _today = dayOnly(DateTime.now());
DateTime _in(int days) => addDays(_today, days);

Widget _planner(List<DzTask> tasks, PlannerSelection selection) => MaterialApp.router(
      theme: DzTheme.light(),
      routerConfig: GoRouter(routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => AppScopes(
            tasks: _Tasks(tasks),
            journal: JournalController(),
            settings: SettingsController(),
            insights: InsightsController(),
            aiOptimization: AIOptimizationController(),
            notifications: NotificationController(),
            child: Scaffold(body: PlannerPage(selection: selection)),
          ),
        ),
      ]),
    );

Finder _illustration(DzIllustration which) => find.byWidgetPredicate(
      (w) => w is DzIllustrationWidget && w.illustration == which,
    );

Future<void> _open(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({
        'first_use_date': DateTime(_today.year, _today.month - 2, _today.day).toIso8601String(),
      }));

  group('an empty day has a picture, chosen to suit the day', () {
    testWidgets('today: a sunrise over an open slot', (tester) async {
      await _open(tester, _planner([], PlannerSelection()));
      expect(_illustration(DzIllustration.emptyDayToday), findsOneWidget);
      expect(_illustration(DzIllustration.emptyDayFuture), findsNothing);
      expect(_illustration(DzIllustration.emptyDayPast), findsNothing);
    });

    testWidgets('a day ahead: a calendar and a paper plane', (tester) async {
      await _open(tester, _planner([], PlannerSelection(_in(6))));
      expect(_illustration(DzIllustration.emptyDayFuture), findsOneWidget);
    });

    testWidgets('a day gone by: a notebook and a pencil', (tester) async {
      await _open(tester, _planner([], PlannerSelection(_in(-4))));
      expect(_illustration(DzIllustration.emptyDayPast), findsOneWidget);
    });

    testWidgets('it is a real SVG that loads, not a missing asset', (tester) async {
      await _open(tester, _planner([], PlannerSelection()));
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('each still has the button that adds a task', (tester) async {
      for (final day in [0, 6, -4]) {
        await _open(tester, _planner([], PlannerSelection(_in(day))));
        expect(find.text('Add a Task'), findsOneWidget, reason: 'day offset $day');
      }
    });

    testWidgets('a day with tasks shows the timeline, not a picture', (tester) async {
      final task = DzTask(
        id: 'x',
        title: 'Real task',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        date: _today,
      );
      await _open(tester, _planner([task], PlannerSelection()));

      expect(find.text('Real task'), findsOneWidget);
      expect(find.byType(DzIllustrationWidget), findsNothing);
    });
  });

  group('every illustration is bundled', () {
    // The three legacy PNG illustrations belong to the old OnboardingPage, which the
    // router no longer builds (it uses AnimatedOnboardingPage, with the SVGs), and
    // their image files are not in the app. Nothing shows them, so they are not checked.
    const legacy = {
      DzIllustration.focusPlanning,
      DzIllustration.privacySecurity,
      DzIllustration.habitStreaks,
    };
    for (final which in DzIllustration.values.where((i) => !legacy.contains(i))) {
      testWidgets('${which.name} loads', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: DzIllustrationWidget(illustration: which, height: 100)),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: which.name);
      });
    }
  });

  group('DzEmptyState', () {
    Widget host(DzEmptyState state) => MaterialApp(home: Scaffold(body: state));

    testWidgets('shows the icon when it has no illustration (as before)', (tester) async {
      await tester.pumpWidget(host(const DzEmptyState(icon: Icons.inbox, title: 'Empty')));
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.byType(DzIllustrationWidget), findsNothing);
    });

    testWidgets('shows the illustration instead of the icon when given one', (tester) async {
      await tester.pumpWidget(host(const DzEmptyState(
        icon: Icons.inbox,
        illustration: DzIllustration.emptyDayToday,
        title: 'Empty',
      )));
      expect(find.byIcon(Icons.inbox), findsNothing);
      expect(_illustration(DzIllustration.emptyDayToday), findsOneWidget);
    });

    testWidgets('the picture is decorative: screen readers get the title', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DzEmptyState(
        icon: Icons.inbox,
        illustration: DzIllustration.emptyDayFuture,
        title: 'Nothing planned yet',
      )));
      expect(find.bySemanticsLabel('Nothing planned yet'), findsOneWidget);
      expect(find.bySemanticsLabel('Plan ahead'), findsNothing);
      handle.dispose();
    });

    testWidgets('honours the requested illustration height', (tester) async {
      await tester.pumpWidget(host(const DzEmptyState(
        icon: Icons.inbox,
        illustration: DzIllustration.emptyDayToday,
        illustrationHeight: 90,
        title: 'Empty',
      )));
      final widget = tester.widget<DzIllustrationWidget>(find.byType(DzIllustrationWidget));
      expect(widget.height, 90);
    });
  });
}
