import 'dart:async';

import 'package:dayzen/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _launch(
  WidgetTester tester,
  Future<void> Function(BuildContext context) body,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: DzTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => body(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('go'));
  await tester.pump();
}

void main() {
  group('DzProgress.run', () {
    testWidgets('does not flash an overlay for a fast task', (tester) async {
      bool? result;
      await _launch(tester, (ctx) async {
        result = await DzProgress.run<bool>(
          ctx,
          message: 'Working…',
          successMessage: 'Done',
          task: () async => true,
        );
      });
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Working…'), findsNothing);
      expect(find.text('Done'), findsNothing);
      expect(result, isTrue);
    });

    testWidgets('slow task: shows message, then success check, then closes',
        (tester) async {
      final completer = Completer<bool>();
      bool? result;
      await _launch(tester, (ctx) async {
        result = await DzProgress.run<bool>(
          ctx,
          message: 'Signing you in…',
          successMessage: 'Welcome back',
          isSuccess: (ok) => ok,
          task: () => completer.future,
        );
      });

      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Signing you in…'), findsOneWidget);
      expect(find.byType(DzSunLoader), findsOneWidget);
      expect(result, isNull);

      completer.complete(true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.byType(DzCheckMark), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Welcome back'), findsNothing);
      expect(find.byType(DzSunLoader), findsNothing);
      expect(result, isTrue);
    });

    testWidgets('failed result closes without showing the success state',
        (tester) async {
      final completer = Completer<bool>();
      bool? result;
      await _launch(tester, (ctx) async {
        result = await DzProgress.run<bool>(
          ctx,
          message: 'Signing you in…',
          successMessage: 'Welcome back',
          isSuccess: (ok) => ok,
          task: () => completer.future,
        );
      });
      await tester.pump(const Duration(milliseconds: 500));

      completer.complete(false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Welcome back'), findsNothing);
      expect(find.text('Signing you in…'), findsNothing);
      expect(result, isFalse);
    });

    testWidgets('rethrows task errors after the overlay closes',
        (tester) async {
      final completer = Completer<bool>();
      Object? caught;
      await _launch(tester, (ctx) async {
        try {
          await DzProgress.run<bool>(
            ctx,
            message: 'Working…',
            task: () => completer.future,
          );
        } catch (e) {
          caught = e;
        }
      });
      await tester.pump(const Duration(milliseconds: 500));

      completer.completeError(StateError('boom'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));

      expect(caught, isA<StateError>());
      expect(find.text('Working…'), findsNothing);
    });

    testWidgets('shows a hint when the task is slow', (tester) async {
      final completer = Completer<bool>();
      await _launch(tester, (ctx) async {
        await DzProgress.run<bool>(
          ctx,
          message: 'Working…',
          task: () => completer.future,
        );
      });
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('This is taking longer than usual…'), findsNothing);

      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('This is taking longer than usual…'), findsOneWidget);

      completer.complete(true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('alwaysShow displays the overlay even for an instant task',
        (tester) async {
      bool? finished;
      await _launch(tester, (ctx) async {
        await DzProgress.run<void>(
          ctx,
          message: 'Clearing…',
          successMessage: 'Cleared',
          alwaysShow: true,
          task: () async {},
        );
        finished = true;
      });
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Clearing…'), findsOneWidget);
      expect(finished, isNull);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cleared'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Cleared'), findsNothing);
      expect(finished, isTrue);
    });
  });

  group('loaders', () {
    testWidgets('DzSunLoader animates and disposes cleanly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DzTheme.light(),
          home: const Scaffold(body: Center(child: DzSunLoader())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(DzSunLoader), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('DzSunLoader holds still with reduced motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DzTheme.light(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(body: Center(child: DzSunLoader())),
          ),
        ),
      );
      // Would never settle if the loop were running.
      await tester.pumpAndSettle();
    });

    testWidgets('button shows loader and loading label while busy',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DzTheme.light(),
          home: Scaffold(
            body: DzPrimaryButton(
              label: 'Sign In',
              isLoading: true,
              loadingLabel: 'Signing in…',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Signing in…'), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
      expect(find.byType(DzSunLoader), findsOneWidget);
    });

    testWidgets('DzLoadingView shows its message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DzTheme.light(),
          home: const Scaffold(body: DzLoadingView(message: 'Loading…')),
        ),
      );
      await tester.pump();
      expect(find.text('Loading…'), findsOneWidget);
    });
  });
}
