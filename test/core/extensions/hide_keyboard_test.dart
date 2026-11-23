import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';

void main() {
  /// A form as the complaint and the excuse have it: a field, "Submit",
  /// and something that opens a sheet over the page (adding a file).
  Future<void> pumpForm(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              const TextField(),
              TextButton(
                onPressed: context.hideKeyboard,
                child: const Text('Submit'),
              ),
              TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const SizedBox(height: 200),
                ),
                child: const Text('Add files'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> typeThenSubmit(WidgetTester tester) async {
    await tester.showKeyboard(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'He fell in the yard');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('sent: the keyboard goes', (tester) async {
    await pumpForm(tester);

    await typeThenSubmit(tester);

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('sent, then a sheet opens and closes over the page: '
      'the keyboard stays away', (tester) async {
    await pumpForm(tester);
    await typeThenSubmit(tester);

    await tester.tap(find.text('Add files'));
    await tester.pumpAndSettle();
    // Closed without picking anything.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(tester.testTextInput.isVisible, isFalse);
    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isNot(isA<EditableText>()),
    );
  });
}
