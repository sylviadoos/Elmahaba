import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/core/widgets/linked_text.dart';

void main() {
  /// The tappable parts of [text], as LinkedText shows them.
  Future<List<String>> linksIn(WidgetTester tester, String text) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: LinkedText(text))),
    );
    final rich = tester.widget<RichText>(find.byType(RichText).first);
    final links = <String>[];
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
        links.add(span.text!);
      }
      return true;
    });
    return links;
  }

  testWidgets('links become tappable, the punctuation after them doesn\'t', (
    tester,
  ) async {
    expect(
      await linksIn(
        tester,
        'Form: https://school.edu/trip?id=3. More at www.almahabbah.com, '
        'تفاصيل http://example.org/أخبار،',
      ),
      [
        'https://school.edu/trip?id=3',
        'www.almahabbah.com',
        'http://example.org/أخبار',
      ],
    );
  });

  testWidgets('no link: plain text, nothing tappable', (tester) async {
    expect(await linksIn(tester, 'Please bring the signed form.'), isEmpty);
    expect(
      find.text('Please bring the signed form.', findRichText: true),
      findsOneWidget,
    );
  });
}
