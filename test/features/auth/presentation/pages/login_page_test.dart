import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/login_page.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/parent_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/widgets/login_locked_notice.dart';
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

  group('too many wrong passwords', () {
    void locked({Object? retryAfter = 300}) =>
        when(harness.login(any)).thenAnswer(
          (_) async => Failure(
            exception: ServerException(
              statusCode: 429,
              code: AuthErrorCodes.loginLocked,
              message: 'Too many incorrect attempts. Try again in 15 minutes.',
              body: {
                'status': 'error',
                'code': AuthErrorCodes.loginLocked,
                'retry_after': ?retryAfter,
              },
            ),
          ),
        );

    Finder button() => find.ancestor(
      of: find.text(l10n.login),
      matching: find.byType(ElevatedButton),
    );

    bool loginEnabled(WidgetTester tester) =>
        tester.widget<ElevatedButton>(button()).onPressed != null;

    testWidgets('the time left counts down, Log in off until it ends', (
      tester,
    ) async {
      locked();
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await fillIn(tester);
      await logIn(tester);

      // Not the school's fixed "in 15 minutes". (Logging in took a second.)
      expect(find.textContaining('15 minutes'), findsNothing);
      expect(find.textContaining('04:59'), findsOneWidget);
      expect(loginEnabled(tester), isFalse);

      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('04:58'), findsOneWidget);
      await tester.pump(const Duration(minutes: 4, seconds: 57));
      expect(find.textContaining('00:01'), findsOneWidget);
      verify(harness.login(any)).called(1);

      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LoginLockedNotice), findsNothing);
      expect(loginEnabled(tester), isTrue);
    });

    testWidgets('another number: not locked', (tester) async {
      locked();
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await fillIn(tester);
      await logIn(tester);
      await tester.enterText(
        textFieldLabeled(l10n.mobileNumber),
        '01112345678',
      );
      await tester.pump();

      expect(find.byType(LoginLockedNotice), findsNothing);
      expect(loginEnabled(tester), isTrue);

      // The locked one again: still counting.
      await tester.enterText(textFieldLabeled(l10n.mobileNumber), phone);
      await tester.pump();
      expect(find.byType(LoginLockedNotice), findsOneWidget);
      await tester.pump(const Duration(minutes: 5));
    });

    testWidgets('the school didn\'t say how long: its message', (tester) async {
      locked(retryAfter: null);
      await harness.pump(tester, AppRoutes.login, const LoginPage());
      await fillIn(tester);
      await logIn(tester);

      expect(
        find.text('Too many incorrect attempts. Try again in 15 minutes.'),
        findsOneWidget,
      );
      expect(find.byType(LoginLockedNotice), findsNothing);
    });
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
