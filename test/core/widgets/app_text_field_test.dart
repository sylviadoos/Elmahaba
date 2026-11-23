import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/core/widgets/app_text_field.dart';

import '../../helpers/test_app.dart';

void main() {
  /// A form as the complaint and the excuse have it: a box of several lines
  /// and room around it to tap.
  Future<void> pumpForm(
    WidgetTester tester, {
    int minLines = 5,
    bool isPassword = false,
  }) => tester.pumpWidget(
    TestApp(
      router: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: Column(
                children: [
                  AppTextField(
                    label: 'What happened',
                    minLines: minLines,
                    isPassword: isPassword,
                  ),
                  const Expanded(child: SizedBox.expand(key: Key('room'))),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> startTyping(WidgetTester tester) async {
    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'He fell in the yard');
    expect(tester.testTextInput.isVisible, isTrue);
  }

  bool typing(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus;

  testWidgets('done typing several lines: a tap outside puts the keyboard '
      'away (Enter is only a new line)', (tester) async {
    await pumpForm(tester);
    await startTyping(tester);

    await tester.tapAt(tester.getCenter(find.byKey(const Key('room'))));
    await tester.pump();

    expect(typing(tester), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
    // What was typed stays.
    expect(find.text('He fell in the yard'), findsOneWidget);
  });

  testWidgets('a tap in the box, off the text: still typing', (tester) async {
    await pumpForm(tester);
    await startTyping(tester);

    // The box's corner, in its padding, not on the text itself.
    final box = tester.getRect(
      find
          .ancestor(
            of: find.byType(TextField),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    await tester.tapAt(box.bottomRight - const Offset(4, 4));
    await tester.pump();

    expect(typing(tester), isTrue);
  });

  testWidgets('showing the password: still typing', (tester) async {
    await pumpForm(tester, minLines: 1, isPassword: true);
    await startTyping(tester);

    await tester.tap(find.byType(IconButton));
    await tester.pump();

    expect(typing(tester), isTrue);
  });
}
