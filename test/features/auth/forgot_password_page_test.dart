import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/features/auth/forgot_password_page.dart';
import 'package:dayzen/features/auth/password_reset_controller.dart';

import 'password_reset_controller_test.dart' show FakeResetService;

void main() {
  testWidgets('walks email -> code -> new password and pops with the email',
      (tester) async {
    final service = FakeResetService();
    final ctrl = PasswordResetController(service: service, initialEmail: 'a@b.co');
    String? popped;
    var closed = false;

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            popped = await Navigator.of(context).push<String>(MaterialPageRoute(
              builder: (_) =>
                  ForgotPasswordPage(initialEmail: 'a@b.co', controller: ctrl),
            ));
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Step 1: email prefilled from the sign-in page.
    expect(find.text('Reset your password'), findsOneWidget);
    await tester.tap(find.byKey(const Key('reset-send-code')));
    await tester.pump();
    await tester.pump();

    // Step 2: code.
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.textContaining('a@b.co'), findsOneWidget);
    expect(find.textContaining('Resend code in'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('reset-code-field')), '123456');
    await tester.tap(find.byKey(const Key('reset-verify-code')));
    await tester.pump();
    await tester.pump();

    // Step 3: new password.
    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('reset-password-field')), 'new-password');
    await tester.enterText(find.byKey(const Key('reset-confirm-field')), 'new-password');
    await tester.tap(find.byKey(const Key('reset-save-password')));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(popped, 'a@b.co');
    expect(service.calls,
        ['request:a@b.co', 'verify:a@b.co:123456', 'reset:reset-token']);
  });

  testWidgets('shows the error message for a mismatch', (tester) async {
    final ctrl = PasswordResetController(service: FakeResetService());
    await tester.pumpWidget(MaterialApp(
      home: ForgotPasswordPage(initialEmail: 'a@b.co', controller: ctrl),
    ));
    await ctrl.sendCode('a@b.co');
    await ctrl.verifyCode('123456');
    await tester.pump();

    await tester.enterText(find.byKey(const Key('reset-password-field')), 'new-password');
    await tester.enterText(find.byKey(const Key('reset-confirm-field')), 'different-pass');
    await tester.tap(find.byKey(const Key('reset-save-password')));
    await tester.pump();

    expect(find.text("The two passwords don't match."), findsOneWidget);
  });

  for (final (width, scale) in [(360.0, 1.0), (320.0, 1.3), (412.0, 2.0)]) {
    testWidgets('code step fits a ${width.toInt()}dp phone at ${scale}x text',
        (tester) async {
      tester.view.physicalSize = Size(width * 3, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final ctrl = PasswordResetController(service: FakeResetService());
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
              size: Size(width, 800), textScaler: TextScaler.linear(scale)),
          child: ForgotPasswordPage(initialEmail: 'a@b.co', controller: ctrl),
        ),
      ));
      await ctrl.sendCode('a@b.co');
      await tester.pump();

      expect(find.textContaining('Resend code in'), findsOneWidget);
      expect(find.text('Different email'), findsOneWidget);
      expect(tester.takeException(), isNull); // no RenderFlex overflow
    });
  }
}
