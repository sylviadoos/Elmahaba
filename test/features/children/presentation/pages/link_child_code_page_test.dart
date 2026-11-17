import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/pages/link_child_code_page.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';
import 'add_children_page_test.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  late MockVerifyChildLinkUseCase verifyChildLink;
  late MockResendChildLinkCodeUseCase resendCode;
  late MockSendChildLinkCodeUseCase sendCode;
  late MockVerifyOtpUseCase checkFirebaseCode;
  late MockChildrenViewModel childrenViewModel;

  setUpAll(() {
    provideResultDummy<ChildEntity>();
    provideResultDummy<LinkVerificationEntity>();
    provideResultDummy<PhoneVerificationEntity>();
    provideResultDummy<String>();
  });

  setUp(() {
    verifyChildLink = MockVerifyChildLinkUseCase();
    resendCode = MockResendChildLinkCodeUseCase();
    sendCode = MockSendChildLinkCodeUseCase();
    checkFirebaseCode = MockVerifyOtpUseCase();
    childrenViewModel = MockChildrenViewModel();
    when(childrenViewModel.state).thenReturn(const ChildrenState());
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    getIt.registerFactory<LinkChildCodeViewModel>(
      () => LinkChildCodeViewModel(
        verifyChildLink,
        sendCode,
        resendCode,
        checkFirebaseCode,
        false,
      ),
    );
  });
  tearDown(getIt.reset);

  /// Add children, with the code page opened over it.
  Future<void> pump(
    WidgetTester tester, {
    LinkVerificationEntity? opened,
  }) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Add children')),
        ),
        GoRoute(
          path: AppRoutes.linkChildCode,
          builder: (_, state) => LinkChildCodePage(
            verification: state.extra! as LinkVerificationEntity,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
        ],
      ),
    );
    router.push(AppRoutes.linkChildCode, extra: opened ?? verification);
    await tester.pumpAndSettle();
  }

  void answerCheck(Result<ChildEntity> result) => when(
    verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
  ).thenAnswer((_) async => result);

  Future<void> enterCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    await tester.tap(find.text(en.verify));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('says where the code went, as the school hid it', (tester) async {
    await pump(tester);

    expect(find.textContaining(en.linkCodeSentTo), findsOneWidget);
    expect(find.textContaining('••• ••• 4567'), findsOneWidget);
    // Another code only after a minute (resend_after: 60).
    expect(find.text(en.resendCode), findsNothing);
  });

  testWidgets('the right code: linked, back to Add children', (tester) async {
    answerCheck(const Success(data: ereny));
    await pump(tester);

    await enterCode(tester, '123456');
    await tester.pumpAndSettle();

    verify(
      verifyChildLink(
        token: verification.token,
        proof: const SchoolCodeProof('123456'),
      ),
    ).called(1);
    final event =
        verify(childrenViewModel.doAction(captureAny)).captured.single
            as ChildLinkVerifiedEvent;
    expect(event.child, ereny);
    expect(find.text('Add children'), findsOneWidget);
  });

  testWidgets('a wrong code: the school\'s message and the tries left', (
    tester,
  ) async {
    answerCheck(
      const Failure(
        exception: ServerException(
          message: 'The code is incorrect.',
          code: 'otp_incorrect',
          body: {'attempts_left': 2},
        ),
      ),
    );
    await pump(tester);

    await enterCode(tester, '000000');

    expect(
      find.text('The code is incorrect. ${en.codeAttemptsLeft(2)}'),
      findsOneWidget,
    );
    expect(find.byType(LinkChildCodePage), findsOneWidget);
  });

  testWidgets('the code expired: another can be asked for at once', (
    tester,
  ) async {
    answerCheck(
      const Failure(
        exception: ServerException(
          message: 'The code has expired.',
          code: 'otp_expired',
        ),
      ),
    );
    await pump(tester);

    await enterCode(tester, '123456');

    expect(find.text('The code has expired.'), findsOneWidget);
    expect(find.text(en.resendCode), findsOneWidget);
  });

  testWidgets('the check is gone: back to Add children to start again', (
    tester,
  ) async {
    answerCheck(
      const Failure(
        exception: ServerException(
          message: 'Start again.',
          code: 'link_verification_invalid',
        ),
      ),
    );
    await pump(tester);

    await enterCode(tester, '123456');
    await tester.pumpAndSettle();

    expect(find.text('Add children'), findsOneWidget);
    expect(find.text('Start again.'), findsOneWidget);
    verifyNever(childrenViewModel.doAction(any));
  });

  testWidgets('no more codes: the school\'s message, no resend', (
    tester,
  ) async {
    answerCheck(
      const Failure(
        exception: ServerException(
          message: 'The code has expired.',
          code: 'otp_expired',
        ),
      ),
    );
    when(resendCode(any)).thenAnswer(
      (_) async => const Failure(
        exception: ServerException(
          message: 'No more codes.',
          code: 'otp_resend_limit',
        ),
      ),
    );
    await pump(tester);
    await enterCode(tester, '123456');

    await tester.tap(find.text(en.resendCode));
    await tester.pump();
    await tester.pump();

    expect(find.text('No more codes.'), findsOneWidget);
    expect(find.text(en.resendCode), findsNothing);
  });

  group('the school gave its number: Firebase sends the code', () {
    final withPhone = LinkVerificationModel.fromJson({
      ...verificationJson,
      'phone': '01012344567',
    });

    testWidgets('sent by Firebase as the page opens', (tester) async {
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Success(
          data: SmsCodeSent(verificationId: 'vid', resendToken: 1),
        ),
      );
      when(
        checkFirebaseCode(verificationId: 'vid', smsCode: '123456'),
      ).thenAnswer((_) async => const Success(data: 'firebase-id-token'));
      answerCheck(const Success(data: ereny));
      await pump(tester, opened: withPhone);

      verify(sendCode('01012344567', resendToken: null)).called(1);
      verifyNever(resendCode(any));

      await enterCode(tester, '123456');
      await tester.pumpAndSettle();

      verify(
        verifyChildLink(
          token: withPhone.token,
          proof: const FirebaseProof('firebase-id-token'),
        ),
      ).called(1);
      expect(find.text('Add children'), findsOneWidget);
    });

    testWidgets('Firebase fails: the school texts it instead', (tester) async {
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Failure(
          exception: PhoneVerificationException(code: 'quota-exceeded'),
        ),
      );
      when(
        resendCode(any),
      ).thenAnswer((_) async => Success(data: verification));
      answerCheck(const Success(data: ereny));
      await pump(tester, opened: withPhone);

      verify(resendCode(withPhone.token)).called(1);

      await enterCode(tester, '123456');
      await tester.pumpAndSettle();

      verify(
        verifyChildLink(
          token: withPhone.token,
          proof: const SchoolCodeProof('123456'),
        ),
      ).called(1);
      verifyZeroInteractions(checkFirebaseCode);
    });

    testWidgets('a wrong Firebase code: the app\'s message, under the boxes', (
      tester,
    ) async {
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Success(
          data: SmsCodeSent(verificationId: 'vid', resendToken: 1),
        ),
      );
      when(
        checkFirebaseCode(
          verificationId: anyNamed('verificationId'),
          smsCode: anyNamed('smsCode'),
        ),
      ).thenAnswer(
        (_) async => const Failure(
          exception: PhoneVerificationException(
            code: 'invalid-verification-code',
          ),
        ),
      );
      await pump(tester, opened: withPhone);

      await enterCode(tester, '000000');

      expect(find.text(en.otpWrongCode), findsOneWidget);
      verifyNever(
        verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
      );
    });
  });

  test('the state starts with nothing checked', () {
    expect(
      LinkChildCodeViewModel(
        verifyChildLink,
        sendCode,
        resendCode,
        checkFirebaseCode,
        false,
      ).state.checking,
      const BaseState<ChildEntity>.initial(),
    );
  });
}
