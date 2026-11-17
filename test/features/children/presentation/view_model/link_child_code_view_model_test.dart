import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/link_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_event.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/link_child_code_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';

void main() {
  late MockVerifyChildLinkUseCase verifyChildLink;
  late MockSendChildLinkCodeUseCase sendCode;
  late MockResendChildLinkCodeUseCase resendCode;
  late MockVerifyOtpUseCase checkFirebaseCode;
  late LinkChildCodeViewModel viewModel;

  /// The school gave its number for the child: Firebase sends the code.
  final withPhone = LinkVerificationModel.fromJson({
    ...verificationJson,
    'phone': '01012344567',
  });

  setUpAll(() {
    provideResultDummy<ChildEntity>();
    provideResultDummy<LinkVerificationEntity>();
    provideResultDummy<PhoneVerificationEntity>();
    provideResultDummy<String>();
  });

  setUp(() {
    verifyChildLink = MockVerifyChildLinkUseCase();
    sendCode = MockSendChildLinkCodeUseCase();
    resendCode = MockResendChildLinkCodeUseCase();
    checkFirebaseCode = MockVerifyOtpUseCase();
    viewModel = LinkChildCodeViewModel(
      verifyChildLink,
      sendCode,
      resendCode,
      checkFirebaseCode,
    );
  });

  tearDown(() => viewModel.close());

  void whenFirebaseSends() =>
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Success(
          data: SmsCodeSent(verificationId: 'vid', resendToken: 7),
        ),
      );

  void whenFirebaseFails() =>
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Failure(
          exception: PhoneVerificationException(code: 'quota-exceeded'),
        ),
      );

  group('texted by the school (no number given)', () {
    test('the right code: the child, linked', () async {
      when(
        verifyChildLink(
          token: verification.token,
          proof: const SchoolCodeProof('123456'),
        ),
      ).thenAnswer((_) async => const Success(data: ereny));

      await viewModel.doAction(
        CheckLinkCodeEvent(token: verification.token, code: '123456'),
      );

      expect(viewModel.state.checking.data, ereny);
      verifyZeroInteractions(checkFirebaseCode);
    });

    test('a wrong code: the school\'s error', () async {
      when(
        verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
      ).thenAnswer(
        (_) async =>
            const Failure(exception: ServerException(code: 'otp_incorrect')),
      );

      await viewModel.doAction(
        CheckLinkCodeEvent(token: verification.token, code: '000000'),
      );

      expect(viewModel.state.checking.state, StateType.error);
      expect(
        (viewModel.state.checking.exception! as ServerException).code,
        'otp_incorrect',
      );
    });

    test('another code: texted by the school, never Firebase', () async {
      when(
        resendCode(verification.token),
      ).thenAnswer((_) async => Success(data: verification));

      await viewModel.doAction(SendLinkCodeEvent(verification));

      expect(viewModel.state.resending.data, verification);
      verifyZeroInteractions(sendCode);
    });
  });

  group('the school gave its number', () {
    test('Firebase sends the code to it', () async {
      whenFirebaseSends();

      await viewModel.doAction(SendLinkCodeEvent(withPhone));

      verify(sendCode('01012344567', resendToken: null)).called(1);
      verifyZeroInteractions(resendCode);
      expect(viewModel.state.resending.data, withPhone);
    });

    test('again: with the last resend token', () async {
      whenFirebaseSends();

      await viewModel.doAction(SendLinkCodeEvent(withPhone));
      await viewModel.doAction(SendLinkCodeEvent(withPhone));

      verifyInOrder([
        sendCode('01012344567', resendToken: null),
        sendCode('01012344567', resendToken: 7),
      ]);
    });

    test("the right code: Firebase's proof links the child", () async {
      whenFirebaseSends();
      when(
        checkFirebaseCode(verificationId: 'vid', smsCode: '123456'),
      ).thenAnswer((_) async => const Success(data: 'firebase-id-token'));
      when(
        verifyChildLink(
          token: withPhone.token,
          proof: const FirebaseProof('firebase-id-token'),
        ),
      ).thenAnswer((_) async => const Success(data: ereny));

      await viewModel.doAction(SendLinkCodeEvent(withPhone));
      await viewModel.doAction(
        CheckLinkCodeEvent(token: withPhone.token, code: '123456'),
      );

      expect(viewModel.state.checking.data, ereny);
    });

    test(
      "a wrong code: Firebase's error, nothing sent to the school",
      () async {
        whenFirebaseSends();
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

        await viewModel.doAction(SendLinkCodeEvent(withPhone));
        await viewModel.doAction(
          CheckLinkCodeEvent(token: withPhone.token, code: '000000'),
        );

        expect(
          viewModel.state.checking.exception,
          isA<PhoneVerificationException>(),
        );
        verifyNever(
          verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
        );
      },
    );

    test('Android verified the number itself: linked at once', () async {
      when(sendCode(any, resendToken: anyNamed('resendToken'))).thenAnswer(
        (_) async => const Success(
          data: PhoneAutoVerified(firebaseIdToken: 'firebase-id-token'),
        ),
      );
      when(
        verifyChildLink(
          token: withPhone.token,
          proof: const FirebaseProof('firebase-id-token'),
        ),
      ).thenAnswer((_) async => const Success(data: ereny));

      await viewModel.doAction(SendLinkCodeEvent(withPhone));

      expect(viewModel.state.checking.data, ereny);
    });

    group('Firebase fails', () {
      setUp(() {
        whenFirebaseFails();
        when(
          resendCode(any),
        ).thenAnswer((_) async => Success(data: verification));
      });

      test('the school texts the code instead', () async {
        await viewModel.doAction(SendLinkCodeEvent(withPhone));

        verify(resendCode(withPhone.token)).called(1);
        expect(viewModel.state.resending.data, verification);
      });

      test("the typed code goes to the school as it is", () async {
        when(
          verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
        ).thenAnswer((_) async => const Success(data: ereny));

        await viewModel.doAction(SendLinkCodeEvent(withPhone));
        await viewModel.doAction(
          CheckLinkCodeEvent(token: withPhone.token, code: '123456'),
        );

        verify(
          verifyChildLink(
            token: withPhone.token,
            proof: const SchoolCodeProof('123456'),
          ),
        ).called(1);
        verifyZeroInteractions(checkFirebaseCode);
      });

      test('again: straight from the school', () async {
        await viewModel.doAction(SendLinkCodeEvent(withPhone));
        await viewModel.doAction(SendLinkCodeEvent(withPhone));

        verify(sendCode(any, resendToken: anyNamed('resendToken'))).called(1);
        verify(resendCode(withPhone.token)).called(2);
      });

      test("the school fails too: its error", () async {
        when(resendCode(any)).thenAnswer(
          (_) async => const Failure(
            exception: ServerException(code: 'otp_resend_limit'),
          ),
        );

        await viewModel.doAction(SendLinkCodeEvent(withPhone));

        expect(
          (viewModel.state.resending.exception! as ServerException).code,
          'otp_resend_limit',
        );
      });
    });
  });

  test('one at a time: nothing else is sent while a code is checked', () async {
    final answer = Completer<Result<ChildEntity>>();
    when(
      verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
    ).thenAnswer((_) => answer.future);

    unawaited(
      viewModel.doAction(
        CheckLinkCodeEvent(token: verification.token, code: '123456'),
      ),
    );
    await viewModel.doAction(
      CheckLinkCodeEvent(token: verification.token, code: '654321'),
    );
    await viewModel.doAction(SendLinkCodeEvent(verification));
    answer.complete(const Success(data: ereny));
    await Future<void>.delayed(Duration.zero);

    verify(
      verifyChildLink(token: anyNamed('token'), proof: anyNamed('proof')),
    ).called(1);
    verifyNever(resendCode(any));
  });
}
