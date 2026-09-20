import 'package:dayzen/features/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashPage plays and then calls onFinished once',
      (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(home: SplashPage(onFinished: () => finished++)),
    );
    await tester.runAsync(() => Future<void>.delayed(
          const Duration(milliseconds: 200),
        ));
    await tester.pump();

    expect(finished, 0);
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(finished, 1);
  });

  testWidgets('tapping the splash skips straight to onFinished',
      (tester) async {
    var finished = 0;
    await tester.pumpWidget(
      MaterialApp(home: SplashPage(onFinished: () => finished++)),
    );
    await tester.tap(find.byType(SplashPage));
    expect(finished, 1);
    await tester.pump(const Duration(seconds: 4));
    expect(finished, 1);
  });
}
