import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/otp_page.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  const page = OtpPage(request: registerRequest, phoneMasked: '0101****678');
  const registration = CompleteRegisterRequestEntity(
    phone: phone,
    password: password,
    proof: FirebaseProof(firebaseIdToken),
  );

  void whenCodeSent([
    PhoneVerificationEntity sent = const SmsCodeSent(
      verificationId: 'vid',
      resendToken: 7,
    ),
  ]) => when(
    harness.sendOtp(any, resendToken: anyNamed('resendToken')),
  ).thenAnswer((_) async => Success(data: sent));

  void whenCodeIs(String code) => when(
    harness.verifyOtp(verificationId: 'vid', smsCode: code),
  ).thenAnswer((_) async => const Success(data: firebaseIdToken));

  Future<void> verifyCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    await tester.tapShown(buttonLabeled(l10n.verify));
    await tester.settle();
  }

  testWidgets('sends the code as it opens, to the number shown', (
    tester,
  ) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.otp, page);

    verify(harness.sendOtp(phone, resendToken: null)).called(1);
    expect(
      find.textContaining('0101****678', findRichText: true),
      findsOneWidget,
    );
    // "Resend code in 5:00", the time in bold.
    expect(find.textContaining('5:00', findRichText: true), findsOneWidget);
  });

  testWidgets('Verify waits for all six digits', (tester) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.otp, page);
    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(tester.isEnabled(l10n.verify), isFalse);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.pump();
    expect(tester.isEnabled(l10n.verify), isTrue);
  });

  testWidgets('the right code: creates the account, opens Log in', (
    tester,
  ) async {
    whenCodeSent();
    whenCodeIs('123456');
    when(
      harness.completeRegister(any),
    ).thenAnswer((_) async => Success(data: session));
    await harness.pump(tester, AppRoutes.otp, page);
    await verifyCode(tester, '123456');

    verify(harness.completeRegister(registration)).called(1);
    expect(find.text(l10n.accountCreated), findsOneWidget);
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  testWidgets('a wrong code: says so, stays', (tester) async {
    whenCodeSent();
    when(
      harness.verifyOtp(
        verificationId: anyNamed('verificationId'),
        smsCode: anyNamed('smsCode'),
      ),
    ).thenAnswer(
      (_) async => const Failure(
        exception: PhoneVerificationException(code: AuthErrorCodes.wrongCode),
      ),
    );
    await harness.pump(tester, AppRoutes.otp, page);
    await verifyCode(tester, '000000');

    expect(find.text(l10n.otpWrongCode), findsOneWidget);
    expect(find.byType(OtpPage), findsOneWidget);
    verifyZeroInteractions(harness.completeRegister);
  });

  testWidgets('already registered: says so, opens Log in', (tester) async {
    whenCodeSent();
    whenCodeIs('123456');
    when(harness.completeRegister(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          code: AuthErrorCodes.alreadyRegistered,
          message: 'This number already has an account.',
        ),
      ),
    );
    await harness.pump(tester, AppRoutes.otp, page);
    await verifyCode(tester, '123456');

    expect(find.text('This number already has an account.'), findsOneWidget);
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  testWidgets('Android verified the number itself: account created', (
    tester,
  ) async {
    whenCodeSent(const PhoneAutoVerified(firebaseIdToken: firebaseIdToken));
    when(
      harness.completeRegister(any),
    ).thenAnswer((_) async => Success(data: session));
    await harness.pump(tester, AppRoutes.otp, page);
    await tester.settle();

    verify(harness.completeRegister(registration)).called(1);
    expect(find.text(AppRoutes.login), findsOneWidget);
  });

  group('resend', () {
    testWidgets("after 5 minutes: sends again, by the school; 5 minutes "
        "again, the school's wait shorter", (tester) async {
      whenCodeSent();
      when(
        harness.sendOtp(
          any,
          resendToken: anyNamed('resendToken'),
          bySchool: true,
        ),
      ).thenAnswer(
        (_) async => const Success(
          data: SchoolCodeSent(resendAfter: Duration(seconds: 60)),
        ),
      );
      await harness.pump(tester, AppRoutes.otp, page);
      expect(find.text(l10n.resendCode), findsNothing);

      await tester.pump(const Duration(seconds: 299));
      expect(find.text(l10n.resendCode), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.tapShown(buttonLabeled(l10n.resendCode));
      await tester.pump();

      verifyInOrder([
        harness.sendOtp(phone, resendToken: null, bySchool: false),
        harness.sendOtp(phone, resendToken: 7, bySchool: true),
      ]);
      expect(find.textContaining('5:00', findRichText: true), findsOneWidget);
    });

    testWidgets('sending failed: says why, can resend right away', (
      tester,
    ) async {
      when(
        harness.sendOtp(any, resendToken: anyNamed('resendToken')),
      ).thenAnswer(
        (_) async => const Failure(
          exception: PhoneVerificationException(
            code: AuthErrorCodes.tooManyRequests,
          ),
        ),
      );
      await harness.pump(tester, AppRoutes.otp, page);
      await tester.settle();

      expect(find.text(l10n.tooManyAttempts), findsOneWidget);
      expect(find.text(l10n.resendCode), findsOneWidget);
    });
  });

  testWidgets('Change it goes back to Register', (tester) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.otp, page);
    await tester.tapShown(buttonLabeled(l10n.changeIt));
    await tester.settle();

    expect(find.text(AppRoutes.register), findsOneWidget);
  });
}
