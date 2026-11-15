import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/new_password_page.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  const page = NewPasswordPage(phone: phone, firebaseIdToken: firebaseIdToken);

  Future<void> type(
    WidgetTester tester, {
    String pass = password,
    String confirmation = password,
  }) async {
    await tester.enterText(textFieldLabeled(l10n.newPassword), pass);
    await tester.enterText(
      textFieldLabeled(l10n.confirmNewPassword),
      confirmation,
    );
    await tester.pump();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tapShown(buttonLabeled(l10n.saveNewPassword));
    await tester.settle();
  }

  void whenResetFails(ServerException exception) => when(
    harness.resetPassword(any),
  ).thenAnswer((_) async => Failure(exception: exception));

  group('Save waits for the rules', () {
    testWidgets('too short', (tester) async {
      await harness.pump(tester, AppRoutes.newPassword, page);
      await type(tester, pass: 'abc1', confirmation: 'abc1');

      expect(tester.isEnabled(l10n.saveNewPassword), isFalse);
    });

    testWidgets('no number', (tester) async {
      await harness.pump(tester, AppRoutes.newPassword, page);
      await type(tester, pass: 'abcdefgh', confirmation: 'abcdefgh');

      expect(tester.isEnabled(l10n.saveNewPassword), isFalse);
    });

    testWidgets("not the same twice: says so", (tester) async {
      await harness.pump(tester, AppRoutes.newPassword, page);
      await type(tester, confirmation: 'secret124');

      expect(find.text(l10n.passwordsDoNotMatch), findsOneWidget);
      expect(tester.isEnabled(l10n.saveNewPassword), isFalse);
    });

    testWidgets('all met', (tester) async {
      await harness.pump(tester, AppRoutes.newPassword, page);
      await type(tester);

      expect(tester.isEnabled(l10n.saveNewPassword), isTrue);
    });
  });

  testWidgets('saved: Password changed, then back to Log in', (tester) async {
    when(
      harness.resetPassword(any),
    ).thenAnswer((_) async => const Success(data: null));
    await harness.pump(tester, AppRoutes.newPassword, page);
    await type(tester);
    await save(tester);

    verify(harness.resetPassword(resetRequest)).called(1);
    expect(find.text(l10n.passwordChanged), findsOneWidget);

    await tester.tapShown(buttonLabeled(l10n.backToLogin));
    await tester.settle();
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  testWidgets('the proof is too old: back to Forgot password', (tester) async {
    whenResetFails(
      const ServerException(
        code: AuthErrorCodes.resetVerificationExpired,
        message: 'Too long since the code. Ask for a new one.',
      ),
    );
    await harness.pump(tester, AppRoutes.newPassword, page);
    await type(tester);
    await save(tester);

    expect(
      find.text('Too long since the code. Ask for a new one.'),
      findsOneWidget,
    );
    expect(find.text(AppRoutes.forgotPassword), findsOneWidget);
  });

  testWidgets('no account for the number: opens Register', (tester) async {
    whenResetFails(const ServerException(code: AuthErrorCodes.accountNotFound));
    await harness.pump(tester, AppRoutes.newPassword, page);
    await type(tester);
    await save(tester);

    expect(find.text(AppRoutes.register), findsOneWidget);
  });

  testWidgets("the server's field errors show under the fields", (
    tester,
  ) async {
    whenResetFails(
      const ServerException(
        statusCode: 422,
        code: 'validation_failed',
        fieldErrors: {'password': 'The password is too common.'},
      ),
    );
    await harness.pump(tester, AppRoutes.newPassword, page);
    await type(tester);
    await save(tester);

    expect(find.text('The password is too common.'), findsOneWidget);
    expect(find.text(l10n.checkHighlightedFields), findsOneWidget);
    expect(find.byType(NewPasswordPage), findsOneWidget);
  });
}
