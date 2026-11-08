import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  Future<void> fillIn(
    WidgetTester tester, {
    String mobile = phone,
    String pass = password,
  }) async {
    await tester.enterText(textFieldLabeled(l10n.mobileNumber), mobile);
    await tester.enterText(textFieldLabeled(l10n.password), pass);
  }

  Future<void> logIn(WidgetTester tester) async {
    await tester.tapShown(buttonLabeled(l10n.login));
    await tester.settle();
  }

  group('checks the fields first', () {
    testWidgets('empty: both required, nothing sent', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await logIn(tester);

      expect(find.text(l10n.thisFieldIsRequired), findsNWidgets(2));
      verifyZeroInteractions(harness.login);
    });

    testWidgets('not an Egyptian mobile: says so', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await fillIn(tester, mobile: '0191234567');
      await logIn(tester);

      expect(find.text(l10n.phoneNumberIsNotValid), findsOneWidget);
      verifyZeroInteractions(harness.login);
    });

    testWidgets('editing a field clears its error', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await logIn(tester);
      await tester.enterText(textFieldLabeled(l10n.password), 'x');
      await tester.pump();

      expect(find.text(l10n.thisFieldIsRequired), findsOneWidget);
    });
  });

  testWidgets('logs in: shows the saved parent and children, opens Home', (
    tester,
  ) async {
    when(harness.login(any)).thenAnswer((_) async => Success(data: session));
    await harness.pump(tester, AppRoutes.login, const LoginPage());
    await fillIn(tester);
    await logIn(tester);

    verify(harness.login(loginRequest)).called(1);
    verify(
      harness.parentViewModel.doAction(argThat(isA<ShowSavedParentEvent>())),
    ).called(1);
    verify(
      harness.childrenViewModel.doAction(
        argThat(isA<ShowSavedChildrenEvent>()),
      ),
    ).called(1);
    expect(find.text(AppRoutes.home), findsOneWidget);
  });

  testWidgets('wrong password: the server message, stays', (tester) async {
    when(harness.login(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          statusCode: 401,
          code: 'invalid_credentials',
          message: 'Wrong mobile number or password.',
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.login, const LoginPage());
    await fillIn(tester);
    await logIn(tester);

    expect(find.text('Wrong mobile number or password.'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
    verifyNever(harness.parentViewModel.doAction(any));
  });

  testWidgets('invalid_phone: its message under the mobile', (tester) async {
    when(harness.login(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          statusCode: 422,
          code: AuthErrorCodes.invalidPhone,
          message: 'Enter an Egyptian mobile number.',
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.login, const LoginPage());
    await fillIn(tester);
    await logIn(tester);

    expect(find.text('Enter an Egyptian mobile number.'), findsOneWidget);
    expect(find.text(l10n.checkHighlightedFields), findsOneWidget);
  });

  testWidgets('offline: says so', (tester) async {
    when(
      harness.login(any),
    ).thenAnswer((_) async => const Failure(exception: NetworkException()));
    await harness.pump(tester, AppRoutes.login, const LoginPage());
    await fillIn(tester);
    await logIn(tester);

    expect(find.text(l10n.noInternet), findsOneWidget);
  });

  group('links', () {
    testWidgets('Forgot password? opens it', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await tester.tapShown(buttonLabeled(l10n.forgotPasswordQuestion));
      await tester.settle();

      expect(find.text(AppRoutes.forgotPassword), findsOneWidget);
    });

    testWidgets('Continue as guest opens Explore', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await tester.tapShown(buttonLabeled(l10n.continueAsGuest));
      await tester.settle();

      expect(find.text(AppRoutes.explore), findsOneWidget);
    });

    testWidgets('Create an account opens Register', (tester) async {
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await tester.tapShown(buttonLabeled(l10n.createAnAccount));
      await tester.settle();

      expect(find.text(AppRoutes.register), findsOneWidget);
    });
  });
}
