import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/pages/reset_code_page.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';

import '../../../../helpers/form_helpers.dart';
import '../../auth_fixtures.dart';
import 'auth_page_harness.dart';

void main() {
  late AuthPageHarness harness;

  setUp(() => (harness = AuthPageHarness()).register());
  tearDown(getIt.reset);

  const page = ResetCodePage(phone: phone);

  void whenCodeSent([
    PhoneVerificationEntity sent = const SmsCodeSent(
      verificationId: 'vid',
      resendToken: 7,
    ),
  ]) => when(
    harness.sendOtp(any, resendToken: anyNamed('resendToken')),
  ).thenAnswer((_) async => Success(data: sent));

  Future<void> verifyCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    await tester.tapShown(buttonLabeled(l10n.verify));
    await tester.settle();
  }

  testWidgets('sends the code as it opens; the number shows masked', (
    tester,
  ) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.resetCode, page);

    verify(harness.sendOtp(phone, resendToken: null)).called(1);
    // Non-breaking spaces keep it on one line.
    expect(
      find.textContaining('+20 10 •••• 5678', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets("the right code: the new password page, with Firebase's proof", (
    tester,
  ) async {
    whenCodeSent();
    when(
      harness.verifyOtp(verificationId: 'vid', smsCode: '123456'),
    ).thenAnswer((_) async => const Success(data: firebaseIdToken));
    await harness.pump(tester, AppRoutes.resetCode, page);
    await verifyCode(tester, '123456');

    expect(find.text(AppRoutes.newPassword), findsOneWidget);
    expect(harness.extras[AppRoutes.newPassword], (
      phone,
      const FirebaseProof(firebaseIdToken),
    ));
    verifyZeroInteractions(harness.completeRegister);
  });

  testWidgets('an expired code: says so, stays', (tester) async {
    whenCodeSent();
    when(
      harness.verifyOtp(
        verificationId: anyNamed('verificationId'),
        smsCode: anyNamed('smsCode'),
      ),
    ).thenAnswer(
      (_) async => const Failure(
        exception: PhoneVerificationException(code: AuthErrorCodes.codeExpired),
      ),
    );
    await harness.pump(tester, AppRoutes.resetCode, page);
    await verifyCode(tester, '123456');

    expect(find.text(l10n.otpExpired), findsOneWidget);
    expect(find.byType(ResetCodePage), findsOneWidget);
  });

  testWidgets('Android verified the number itself: the new password page', (
    tester,
  ) async {
    whenCodeSent(const PhoneAutoVerified(firebaseIdToken: firebaseIdToken));
    await harness.pump(tester, AppRoutes.resetCode, page);
    await tester.settle();

    expect(harness.extras[AppRoutes.newPassword], (
      phone,
      const FirebaseProof(firebaseIdToken),
    ));
  });

  testWidgets('resends after 45 seconds', (tester) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.resetCode, page);
    await tester.pump(const Duration(seconds: 45));
    await tester.tapShown(buttonLabeled(l10n.resendCode));
    await tester.pump();

    verify(harness.sendOtp(phone, resendToken: 7)).called(1);
  });

  testWidgets('Change it goes back to Forgot password', (tester) async {
    whenCodeSent();
    await harness.pump(tester, AppRoutes.resetCode, page);
    await tester.tapShown(buttonLabeled(l10n.changeIt));
    await tester.settle();

    expect(find.text(AppRoutes.forgotPassword), findsOneWidget);
  });
}
