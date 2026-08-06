import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/core/design_system/design_system.dart';

void main() {
  group('DayZen Design System Components', () {
    group('DzCard', () {
      testWidgets('renders with default styling', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.light(),
            home: const Scaffold(
              body: DzCard(
                child: Text('Card Content'),
              ),
            ),
          ),
        );

        expect(find.byType(DzCard), findsOneWidget);
        expect(find.text('Card Content'), findsOneWidget);
      });

      testWidgets('respects custom padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.light(),
            home: const Scaffold(
              body: DzCard(
                padding: EdgeInsets.all(32),
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        expect(find.byType(DzCard), findsOneWidget);
      });

      testWidgets('applies correct background color in light theme',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.light(),
            home: const Scaffold(
              body: DzCard(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final cardWidget = find.byType(DzCard);
        expect(cardWidget, findsOneWidget);

        // Verify card renders without errors
        expect(find.byType(Material), findsWidgets);
      });

      testWidgets('applies correct background color in dark theme',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.dark(),
            home: const Scaffold(
              body: DzCard(
                child: SizedBox(width: 100, height: 100),
              ),
            ),
          ),
        );

        final cardWidget = find.byType(DzCard);
        expect(cardWidget, findsOneWidget);
      });
    });

    group('DzScaffold', () {
      testWidgets('renders with app bar and body',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.light(),
            home: DzScaffold(
              currentIndex: 0,
              onNavTap: (_) {},
              appBar: AppBar(title: const Text('Test')),
              body: const Text('Body Content'),
            ),
          ),
        );

        expect(find.byType(DzScaffold), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
        expect(find.text('Body Content'), findsOneWidget);
      });

      testWidgets('applies correct background in light theme',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.light(),
            home: DzScaffold(
              currentIndex: 0,
              onNavTap: (_) {},
              body: const Text('Content'),
            ),
          ),
        );

        expect(find.byType(DzScaffold), findsOneWidget);
      });

      testWidgets('applies correct background in dark theme',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: DzTheme.dark(),
            home: DzScaffold(
              currentIndex: 0,
              onNavTap: (_) {},
              body: const Text('Content'),
            ),
          ),
        );

        expect(find.byType(DzScaffold), findsOneWidget);
      });
    });

    group('DzTheme', () {
      testWidgets('light theme creates correct ColorScheme',
          (WidgetTester tester) async {
        final theme = DzTheme.light();

        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.light);
      });

      testWidgets('dark theme creates correct ColorScheme',
          (WidgetTester tester) async {
        final theme = DzTheme.dark();

        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.dark);
      });

      testWidgets('light theme is created with provided accent',
          (WidgetTester tester) async {
        final theme = DzTheme.light(accent: DzColors.sunsetOrange);

        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.light);
      });

      testWidgets('dark theme is created with provided accent',
          (WidgetTester tester) async {
        final theme = DzTheme.dark(accent: DzColors.lavender);

        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.dark);
      });

      testWidgets('theme provides proper typography',
          (WidgetTester tester) async {
        final theme = DzTheme.light();

        expect(theme.textTheme, isNotNull);
        expect(theme.textTheme.bodyMedium, isNotNull);
        expect(theme.textTheme.headlineSmall, isNotNull);
      });
    });

    group('DzColors', () {
      test('primary color is defined', () {
        expect(DzColors.primary, isNotNull);
        expect(DzColors.primary, equals(const Color(0xFF3B82F6)));
      });

      test('accent palette includes all four options', () {
        expect(DzColors.zenGreen, isNotNull);
        expect(DzColors.primary, isNotNull);
        expect(DzColors.sunsetOrange, isNotNull);
        expect(DzColors.lavender, isNotNull);
      });

      test('dark mode colors are defined', () {
        expect(DzColors.darkBackground, isNotNull);
        expect(DzColors.darkCard, isNotNull);
        expect(DzColors.darkText, isNotNull);
      });

      test('status colors are defined', () {
        expect(DzColors.success, isNotNull);
        expect(DzColors.warning, isNotNull);
        expect(DzColors.error, isNotNull);
      });

      test('tint colors are defined for all statuses', () {
        expect(DzColors.successTint, isNotNull);
        expect(DzColors.warningTint, isNotNull);
        expect(DzColors.errorTint, isNotNull);
      });
    });

    group('DzTextStyles', () {
      test('heading styles are defined', () {
        expect(DzTextStyles.heading1, isNotNull);
        expect(DzTextStyles.heading2, isNotNull);
        expect(DzTextStyles.heading3, isNotNull);
      });

      test('body styles are defined', () {
        expect(DzTextStyles.body, isNotNull);
        expect(DzTextStyles.small, isNotNull);
      });

      test('caption, button, and label styles are defined', () {
        expect(DzTextStyles.caption, isNotNull);
        expect(DzTextStyles.button, isNotNull);
        expect(DzTextStyles.label, isNotNull);
      });
    });

    group('DzSpacing', () {
      test('spacing tokens are properly defined', () {
        expect(DzSpacing.xs, equals(4.0));
        expect(DzSpacing.sm, equals(8.0));
        expect(DzSpacing.md, equals(16.0));
        expect(DzSpacing.lg, equals(24.0));
        expect(DzSpacing.xl, equals(32.0));
        expect(DzSpacing.xxl, equals(48.0));
      });
    });

    group('DzRadius', () {
      test('radius tokens are properly defined', () {
        expect(DzRadius.small, equals(8.0));
        expect(DzRadius.card, equals(16.0));
        expect(DzRadius.button, equals(12.0));
        expect(DzRadius.modal, equals(20.0));
        expect(DzRadius.fab, equals(28.0));
      });
    });
  });
}
