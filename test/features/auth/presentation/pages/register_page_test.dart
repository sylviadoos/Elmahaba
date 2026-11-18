import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/widgets/app_checkbox.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_eligibility_model.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/register_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  Future<void> fillIn(
    WidgetTester tester, {
    String pass = password,
    String confirmation = password,
  }) async {
    await tester.enterText(textFieldLabeled(l10n.mobileNumber), phone);
    await tester.enterText(textFieldLabeled(l10n.password), pass);
    await tester.enterText(
      textFieldLabeled(l10n.confirmPassword),
      confirmation,
    );
  }

  Future<void> agree(WidgetTester tester) async {
    await tester.tapShown(find.byType(AppCheckbox));
    await tester.pump();
  }

  Future<void> createAccount(WidgetTester tester) async {
    await tester.tapShown(buttonLabeled(l10n.createAccount));
    await tester.settle();
  }

  testWidgets('Create account waits for the terms', (tester) async {
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await fillIn(tester);
    expect(tester.isEnabled(l10n.createAccount), isFalse);

    await agree(tester);
    expect(tester.isEnabled(l10n.createAccount), isTrue);
  });

  group('the rules the password has to meet', () {
    testWidgets('are listed under the fields', (tester) async {
      await harness.pump(tester, AppRoutes.register, const RegisterPage());

      expect(find.text(l10n.ruleEightCharacters), findsOneWidget);
      expect(find.text(l10n.ruleHasLetter), findsOneWidget);
      expect(find.text(l10n.ruleHasNumber), findsOneWidget);
      expect(find.text(l10n.rulePasswordsMatch), findsOneWidget);
    });

    testWidgets('a short password: Create account stays off', (tester) async {
      await harness.pump(tester, AppRoutes.register, const RegisterPage());
      await fillIn(tester, pass: 'short', confirmation: 'short');
      await agree(tester);

      expect(tester.isEnabled(l10n.createAccount), isFalse);
      verifyZeroInteractions(harness.checkPhone);
    });

    testWidgets('a password with no number in it', (tester) async {
      await harness.pump(tester, AppRoutes.register, const RegisterPage());
      await fillIn(tester, pass: 'secretive', confirmation: 'secretive');
      await agree(tester);

      expect(tester.isEnabled(l10n.createAccount), isFalse);
      verifyZeroInteractions(harness.checkPhone);
    });

    testWidgets("passwords that don't match", (tester) async {
      await harness.pump(tester, AppRoutes.register, const RegisterPage());
      await fillIn(tester, confirmation: 'secret124');
      await agree(tester);

      expect(tester.isEnabled(l10n.createAccount), isFalse);
      verifyZeroInteractions(harness.checkPhone);
    });
  });

  testWidgets('can sign up: opens the OTP page with what was filled in', (
    tester,
  ) async {
    when(
      harness.checkPhone(any),
    ).thenAnswer((_) async => const Success(data: eligibility));
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await fillIn(tester);
    await agree(tester);
    await createAccount(tester);

    verify(harness.checkPhone(registerRequest)).called(1);
    expect(find.text(AppRoutes.otp), findsOneWidget);
    expect(
      harness.extras[AppRoutes.otp],
      isA<PhoneEligible>()
          .having((e) => e.request, 'request', registerRequest)
          .having((e) => e.eligibility, 'eligibility', eligibility),
    );
  });

  testWidgets('the number has an account: says so, stays', (tester) async {
    when(harness.checkPhone(any)).thenAnswer(
      (_) async => const Success(
        data: RegisterEligibilityModel(
          phoneMasked: '0101****678',
          eligible: false,
          alreadyRegistered: true,
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await fillIn(tester);
    await agree(tester);
    await createAccount(tester);

    expect(find.text(l10n.accountAlreadyExists), findsOneWidget);
    expect(find.byType(RegisterPage), findsOneWidget);
  });

  testWidgets('not in the school records: the server message', (tester) async {
    when(harness.checkPhone(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          code: AuthErrorCodes.registrationNotEligible,
          message: 'This number is not in the school records.',
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await fillIn(tester);
    await agree(tester);
    await createAccount(tester);

    expect(
      find.text('This number is not in the school records.'),
      findsOneWidget,
    );
  });

  testWidgets("the server's field errors show under the fields", (
    tester,
  ) async {
    when(harness.checkPhone(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          statusCode: 422,
          code: 'validation_failed',
          fieldErrors: {'password': 'The password is too common.'},
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await fillIn(tester);
    await agree(tester);
    await createAccount(tester);

    expect(find.text('The password is too common.'), findsOneWidget);
    expect(find.text(l10n.checkHighlightedFields), findsOneWidget);
  });

  testWidgets('Log in goes back to Log in', (tester) async {
    await harness.pump(tester, AppRoutes.register, const RegisterPage());
    await tester.tapShown(buttonLabeled(l10n.login));
    await tester.settle();

    expect(find.text(AppRoutes.login), findsOneWidget);
  });
}
