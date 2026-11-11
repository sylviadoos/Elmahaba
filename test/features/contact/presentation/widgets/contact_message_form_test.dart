import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations_en.dart';
import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';
import 'package:al_mahhaba_school/features/contact/presentation/widgets/contact_message_form.dart';

import '../../../../helpers/form_helpers.dart';
import '../../../../helpers/test_app.dart';

final l10n = AppLocalizationsEn();

void main() {
  late List<ContactMessageEntity> sent;

  setUp(() => sent = []);

  Future<void> pumpForm(WidgetTester tester, ContactMessageForm form) async {
    tester.usePhoneScreen();
    await tester.pumpWidget(
      TestApp(
        router: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) =>
                  Scaffold(body: SingleChildScrollView(child: form)),
            ),
          ],
        ),
      ),
    );
    await tester.pump();
  }

  String textOf(WidgetTester tester, String label) =>
      tester.widget<TextField>(textFieldLabeled(label)).controller!.text;

  testWidgets('starts with what it is given, and sends it', (tester) async {
    await pumpForm(
      tester,
      ContactMessageForm(
        isSending: false,
        serverErrors: const {},
        onSubmit: sent.add,
        firstName: 'Mina',
        lastName: 'Nagy',
        phone: '1012345678',
      ),
    );

    expect(textOf(tester, l10n.firstName), 'Mina');
    expect(textOf(tester, l10n.lastName), 'Nagy');
    expect(textOf(tester, l10n.mobileNumber), '1012345678');
    expect(textOf(tester, l10n.email), '');

    await tester.enterText(textFieldLabeled(l10n.yourMessage), 'Hello');
    await tester.tapShown(buttonLabeled(l10n.sendMessage));
    await tester.pump();

    expect(sent, [
      const ContactMessageEntity(
        firstName: 'Mina',
        lastName: 'Nagy',
        phone: '01012345678',
        email: '',
        message: 'Hello',
      ),
    ]);
  });

  testWidgets('given nothing: starts empty', (tester) async {
    await pumpForm(
      tester,
      ContactMessageForm(
        isSending: false,
        serverErrors: const {},
        onSubmit: sent.add,
      ),
    );

    for (final label in [l10n.firstName, l10n.lastName, l10n.mobileNumber]) {
      expect(textOf(tester, label), '');
    }
  });
}
