import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dayzen/features/settings/widgets/delete_account_dialog.dart';

void main() {
  TextButton confirmButton(WidgetTester tester) => tester.widget<TextButton>(
      find.byKey(const Key('delete-account-confirm-button')));

  testWidgets('delete stays disabled until DELETE is typed', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DeleteAccountDialog())));
    expect(confirmButton(tester).onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('delete-account-confirm-field')), 'DELET');
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('delete-account-confirm-field')), ' delete ');
    await tester.pump();
    expect(confirmButton(tester).onPressed, isNotNull);
  });

  testWidgets('confirming closes the dialog with true', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<bool>(
              context: context,
              builder: (_) => const DeleteAccountDialog(),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('delete-account-confirm-field')), 'DELETE');
    await tester.pump();
    await tester.tap(find.byKey(const Key('delete-account-confirm-button')));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.byType(DeleteAccountDialog), findsNothing);
  });

  testWidgets('cancel closes the dialog with false', (tester) async {
    bool? result = true;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showDialog<bool>(
              context: context,
              builder: (_) => const DeleteAccountDialog(),
            );
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
