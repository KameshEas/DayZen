import 'package:dayzen/features/auth/sign_up_page.dart';
import 'package:dayzen/features/auth/widgets/auth_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _page({bool canGoBack = false}) => MaterialApp(
      home: SignUpPage(
        onSignedUp: (_) {},
        onContinueOffline: () {},
        canGoBack: canGoBack,
      ),
    );

/// A realistic phone-sized surface (411 x 914), so nothing is below the fold.
Future<void> _phone(WidgetTester tester, {Size size = const Size(1080, 2400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows the form, the hint and the alternatives', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page());

    expect(find.text('Start Your Streak'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    // The rule is visible up front, not only after a failed attempt.
    expect(find.text('At least 6 characters'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Use offline instead'), findsOneWidget);
    expect(find.textContaining('Already have an account?', findRichText: true), findsOneWidget);
  });

  testWidgets('hides the offline option when the user is already offline',
      (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page(canGoBack: true));
    expect(find.text('Use offline instead'), findsNothing);
  });

  testWidgets('an empty form shows the reason in an error banner', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page());
    expect(find.byType(AuthErrorBanner), findsNothing);

    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });

  testWidgets('typing clears the error', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page());
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.byType(AuthErrorBanner), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'A');
    await tester.pump();
    expect(find.byType(AuthErrorBanner), findsNothing);
  });

  testWidgets('a short password is explained', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page());
    await tester.enterText(find.byType(TextField).at(0), 'Alex');
    await tester.enterText(find.byType(TextField).at(1), 'alex@example.com');
    await tester.enterText(find.byType(TextField).at(2), '123');
    await tester.tap(find.text('Create account'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters.'), findsOneWidget);
  });

  testWidgets('the password can be shown and hidden', (tester) async {
    await _phone(tester);
    await tester.pumpWidget(_page());
    TextField field() => tester.widget<TextField>(find.byType(TextField).at(2));
    expect(field().obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });
}
