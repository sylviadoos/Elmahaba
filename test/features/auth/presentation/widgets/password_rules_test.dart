import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/features/auth/presentation/widgets/password_rules.dart';

import '../../../../helpers/test_app.dart';
import '../pages/auth_page_harness.dart';

void main() {
  group('PasswordRule', () {
    test('eight characters', () {
      expect(PasswordRule.eightCharacters.isMet('abc1234', ''), isFalse);
      expect(PasswordRule.eightCharacters.isMet('abc12345', ''), isTrue);
    });

    test('a letter, English or Arabic', () {
      expect(PasswordRule.letter.isMet('12345678', ''), isFalse);
      expect(PasswordRule.letter.isMet('1234567a', ''), isTrue);
      expect(PasswordRule.letter.isMet('1234567ب', ''), isTrue);
    });

    test('a number', () {
      expect(PasswordRule.number.isMet('abcdefgh', ''), isFalse);
      expect(PasswordRule.number.isMet('abcdefg1', ''), isTrue);
    });

    test('typed the same twice', () {
      expect(PasswordRule.match.isMet('', ''), isFalse);
      expect(PasswordRule.match.isMet('secret123', 'secret124'), isFalse);
      expect(PasswordRule.match.isMet('secret123', 'secret123'), isTrue);
    });

    test('unlike the current one, only when changing it', () {
      expect(
        PasswordRule.forPassword(),
        isNot(contains(PasswordRule.differentFromCurrent)),
      );
      expect(
        PasswordRule.forPassword(current: 'old-pass1'),
        contains(PasswordRule.differentFromCurrent),
      );
      expect(
        PasswordRule.differentFromCurrent.isMet(
          'old-pass1',
          '',
          current: 'old-pass1',
        ),
        isFalse,
      );
    });

    test('allMet', () {
      expect(PasswordRule.allMet('secret123', 'secret123'), isTrue);
      expect(PasswordRule.allMet('secret123', 'secret124'), isFalse);
      expect(
        PasswordRule.allMet('secret123', 'secret123', current: 'secret123'),
        isFalse,
      );
    });
  });

  group('PasswordRules', () {
    Future<void> pumpRules(
      WidgetTester tester, {
      required String password,
      String? current,
    }) async {
      tester.usePhoneScreen();
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => PasswordRules(
              password: password,
              confirmation: password,
              currentPassword: current,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(TestApp(router: router));
    }

    testWidgets('signing up: four rules', (tester) async {
      await pumpRules(tester, password: 'secret123');

      expect(find.text(l10n.ruleEightCharacters), findsOneWidget);
      expect(find.text(l10n.ruleHasLetter), findsOneWidget);
      expect(find.text(l10n.ruleHasNumber), findsOneWidget);
      expect(find.text(l10n.rulePasswordsMatch), findsOneWidget);
      expect(find.text(l10n.ruleDifferentFromCurrent), findsNothing);
    });

    testWidgets('changing it: "both new" must match, and differ', (
      tester,
    ) async {
      await pumpRules(tester, password: 'secret123', current: 'old-pass1');

      expect(find.text(l10n.ruleNewPasswordsMatch), findsOneWidget);
      expect(find.text(l10n.ruleDifferentFromCurrent), findsOneWidget);
    });
  });
}
