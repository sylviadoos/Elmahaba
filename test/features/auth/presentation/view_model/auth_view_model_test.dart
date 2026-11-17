import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/auth_session_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_event.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_state.dart';
import 'package:al_mahhaba_school/features/auth/presentation/view_model/auth_view_model.dart';

import '../../../../helpers/base_state_matchers.dart';
import '../../../../helpers/result_dummy.dart';
import '../../auth_fixtures.dart';
import '../../auth_mocks.mocks.dart';

void main() {
  late MockCheckRegisterPhoneUseCase checkPhone;
  late MockLoginUseCase login;
  late MockSendOtpUseCase sendOtp;
  late MockVerifyOtpUseCase verifyOtp;
  late MockCompleteRegisterUseCase completeRegister;
  late MockResetPasswordUseCase resetPassword;
  late MockChangePasswordUseCase changePassword;

  setUpAll(() {
    provideResultDummy<RegisterEligibilityEntity>();
    provideResultDummy<AuthSessionEntity>();
    provideResultDummy<PhoneVerificationEntity>();
    provideResultDummy<String>();
    provideResultDummy<void>();
  });

  setUp(() {
    checkPhone = MockCheckRegisterPhoneUseCase();
    login = MockLoginUseCase();
    sendOtp = MockSendOtpUseCase();
    verifyOtp = MockVerifyOtpUseCase();
    completeRegister = MockCompleteRegisterUseCase();
    resetPassword = MockResetPasswordUseCase();
    changePassword = MockChangePasswordUseCase();
  });

  AuthViewModel build() => AuthViewModel(
    checkPhone,
    login,
    sendOtp,
    verifyOtp,
    completeRegister,
    resetPassword,
    changePassword,
  );

  const codeSent = SmsCodeSent(verificationId: 'vid', resendToken: 7);
  const registration = CompleteRegisterRequestEntity(
    phone: phone,
    password: password,
    proof: FirebaseProof(firebaseIdToken),
  );

  void whenCodeSent([PhoneVerificationEntity sent = codeSent]) => when(
    sendOtp(any, resendToken: anyNamed('resendToken')),
  ).thenAnswer((_) async => Success(data: sent));

  void whenRegistered() => when(
    completeRegister(any),
  ).thenAnswer((_) async => Success(data: session));

  test('starts with nothing done', () {
    expect(build().state, const AuthState.initial());
  });

  group('CheckRegisterPhoneEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'can sign up: PhoneEligible, with what was filled in',
      setUp: () => when(
        checkPhone(registerRequest),
      ).thenAnswer((_) async => const Success(data: eligibility)),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const CheckRegisterPhoneEvent(registerRequest)),
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<PhoneEligible>()
              .having((r) => r.request, 'request', registerRequest)
              .having((r) => r.eligibility, 'eligibility', eligibility),
        ),
      ],
    );

    blocTest<AuthViewModel, AuthState>(
      'not in the school records: the error',
      setUp: () => when(checkPhone(any)).thenAnswer(
        (_) async => const Failure(
          exception: ServerException(
            code: AuthErrorCodes.registrationNotEligible,
          ),
        ),
      ),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const CheckRegisterPhoneEvent(registerRequest)),
      expect: () => [isLoadingState, isErrorState<ServerException>()],
    );
  });

  group('LoginEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'signed in: LoggedIn with the session',
      setUp: () => when(
        login(loginRequest),
      ).thenAnswer((_) async => Success(data: session)),
      build: build,
      act: (viewModel) => viewModel.doAction(const LoginEvent(loginRequest)),
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<LoggedIn>().having((r) => r.session, 'session', session),
        ),
      ],
    );

    blocTest<AuthViewModel, AuthState>(
      'wrong password: the error',
      setUp: () => when(login(any)).thenAnswer(
        (_) async => const Failure(exception: ServerException(statusCode: 401)),
      ),
      build: build,
      act: (viewModel) => viewModel.doAction(const LoginEvent(loginRequest)),
      expect: () => [isLoadingState, isErrorState<ServerException>()],
    );

    blocTest<AuthViewModel, AuthState>(
      'tapped again while signing in: signs in once',
      setUp: () =>
          when(login(any)).thenAnswer((_) async => Success(data: session)),
      build: build,
      act: (viewModel) async {
        final first = viewModel.doAction(const LoginEvent(loginRequest));
        await viewModel.doAction(const LoginEvent(loginRequest));
        await first;
      },
      expect: () => [isLoadingState, isSuccessState(isA<LoggedIn>())],
      verify: (_) => verify(login(any)).called(1),
    );
  });

  group('SendOtpEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'the code was sent: OtpSent',
      setUp: whenCodeSent,
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const SendOtpEvent(registerRequest)),
      expect: () => [isLoadingState, isSuccessState(isA<OtpSent>())],
      verify: (_) {
        verify(sendOtp(phone, resendToken: null)).called(1);
        verifyNever(completeRegister(any));
      },
    );

    blocTest<AuthViewModel, AuthState>(
      "again after Firebase's: by the school (Firebase's may never come)",
      setUp: whenCodeSent,
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(const SendOtpEvent(registerRequest));
      },
      verify: (_) => verifyInOrder([
        sendOtp(phone, resendToken: null, bySchool: false),
        sendOtp(phone, resendToken: 7, bySchool: true),
      ]),
    );

    blocTest<AuthViewModel, AuthState>(
      "the school's resent code: goes with the account, unchecked by Firebase",
      setUp: () {
        whenCodeSent();
        when(
          sendOtp(any, resendToken: anyNamed('resendToken'), bySchool: true),
        ).thenAnswer(
          (_) async => const Success(
            data: SchoolCodeSent(resendAfter: Duration(seconds: 60)),
          ),
        );
        whenRegistered();
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(
          const VerifyOtpEvent(registerRequest, '123456'),
        );
      },
      skip: 4,
      expect: () => [isLoadingState, isSuccessState(isA<Registered>())],
      verify: (_) {
        verify(
          completeRegister(
            const CompleteRegisterRequestEntity(
              phone: phone,
              password: password,
              proof: SchoolCodeProof('123456'),
            ),
          ),
        ).called(1);
        verifyZeroInteractions(verifyOtp);
      },
    );

    blocTest<AuthViewModel, AuthState>(
      'Android verified the number itself: creates the account',
      setUp: () {
        whenCodeSent(const PhoneAutoVerified(firebaseIdToken: firebaseIdToken));
        whenRegistered();
      },
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const SendOtpEvent(registerRequest)),
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<Registered>().having((r) => r.session, 'session', session),
        ),
      ],
      verify: (_) => verify(completeRegister(registration)).called(1),
    );

    blocTest<AuthViewModel, AuthState>(
      'too many tries: the error',
      setUp: () =>
          when(sendOtp(any, resendToken: anyNamed('resendToken'))).thenAnswer(
            (_) async => const Failure(
              exception: PhoneVerificationException(
                code: AuthErrorCodes.tooManyRequests,
              ),
            ),
          ),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const SendOtpEvent(registerRequest)),
      expect: () => [
        isLoadingState,
        isErrorState<PhoneVerificationException>(),
      ],
    );
  });

  group('VerifyOtpEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'the right code: creates the account with the proof',
      setUp: () {
        whenCodeSent();
        when(
          verifyOtp(verificationId: 'vid', smsCode: '123456'),
        ).thenAnswer((_) async => const Success(data: firebaseIdToken));
        whenRegistered();
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(
          const VerifyOtpEvent(registerRequest, '123456'),
        );
      },
      skip: 2, // sending the code
      expect: () => [isLoadingState, isSuccessState(isA<Registered>())],
      verify: (_) => verify(completeRegister(registration)).called(1),
    );

    blocTest<AuthViewModel, AuthState>(
      'a wrong code: the error, no account',
      setUp: () {
        whenCodeSent();
        when(
          verifyOtp(
            verificationId: anyNamed('verificationId'),
            smsCode: anyNamed('smsCode'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            exception: PhoneVerificationException(
              code: AuthErrorCodes.wrongCode,
            ),
          ),
        );
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(
          const VerifyOtpEvent(registerRequest, '000000'),
        );
      },
      skip: 2,
      expect: () => [
        isLoadingState,
        isErrorState<PhoneVerificationException>(),
      ],
      verify: (_) => verifyNever(completeRegister(any)),
    );

    blocTest<AuthViewModel, AuthState>(
      'no code sent yet: noCodeSent',
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const VerifyOtpEvent(registerRequest, '123456')),
      expect: () => [
        isLoadingState,
        isA<AuthState>().having(
          (state) => state.exception,
          'exception',
          isA<PhoneVerificationException>().having(
            (e) => e.code,
            'code',
            AuthErrorCodes.noCodeSent,
          ),
        ),
      ],
      verify: (_) => verifyZeroInteractions(verifyOtp),
    );

    blocTest<AuthViewModel, AuthState>(
      'already registered: the error',
      setUp: () {
        whenCodeSent();
        when(
          verifyOtp(
            verificationId: anyNamed('verificationId'),
            smsCode: anyNamed('smsCode'),
          ),
        ).thenAnswer((_) async => const Success(data: firebaseIdToken));
        when(completeRegister(any)).thenAnswer(
          (_) async => const Failure(
            exception: ServerException(code: AuthErrorCodes.alreadyRegistered),
          ),
        );
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(
          const VerifyOtpEvent(registerRequest, '123456'),
        );
      },
      skip: 2,
      expect: () => [isLoadingState, isErrorState<ServerException>()],
    );
  });

  group('the school sent the code (Firebase could not)', () {
    const schoolSent = SchoolCodeSent(resendAfter: Duration(seconds: 60));

    void whenSchoolSent() => when(
      sendOtp(
        any,
        resendToken: anyNamed('resendToken'),
        bySchool: anyNamed('bySchool'),
      ),
    ).thenAnswer((_) async => const Success(data: schoolSent));

    blocTest<AuthViewModel, AuthState>(
      "OtpSent, with the school's wait",
      setUp: whenSchoolSent,
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const SendOtpEvent(registerRequest)),
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<OtpSent>().having(
            (r) => r.resendAfter,
            'resendAfter',
            const Duration(seconds: 60),
          ),
        ),
      ],
    );

    blocTest<AuthViewModel, AuthState>(
      'again: straight from the school',
      setUp: whenSchoolSent,
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(const SendOtpEvent(registerRequest));
      },
      verify: (_) => verifyInOrder([
        sendOtp(phone, resendToken: null, bySchool: false),
        sendOtp(phone, resendToken: null, bySchool: true),
      ]),
    );

    blocTest<AuthViewModel, AuthState>(
      'the typed code goes with the new account, unchecked by Firebase',
      setUp: () {
        whenSchoolSent();
        whenRegistered();
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendOtpEvent(registerRequest));
        await viewModel.doAction(
          const VerifyOtpEvent(registerRequest, '123456'),
        );
      },
      skip: 2,
      expect: () => [isLoadingState, isSuccessState(isA<Registered>())],
      verify: (_) {
        verify(
          completeRegister(
            const CompleteRegisterRequestEntity(
              phone: phone,
              password: password,
              proof: SchoolCodeProof('123456'),
            ),
          ),
        ).called(1);
        verifyZeroInteractions(verifyOtp);
      },
    );

    blocTest<AuthViewModel, AuthState>(
      'forgot password: PhoneVerified with the typed code',
      setUp: whenSchoolSent,
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendResetCodeEvent(phone));
        await viewModel.doAction(const VerifyResetCodeEvent('123456'));
      },
      skip: 2,
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<PhoneVerified>().having(
            (r) => r.proof,
            'proof',
            const SchoolCodeProof('123456'),
          ),
        ),
      ],
    );
  });

  group('SendResetCodeEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'the code was sent: OtpSent',
      setUp: whenCodeSent,
      build: build,
      act: (viewModel) => viewModel.doAction(const SendResetCodeEvent(phone)),
      expect: () => [isLoadingState, isSuccessState(isA<OtpSent>())],
    );

    blocTest<AuthViewModel, AuthState>(
      'Android verified the number itself: PhoneVerified, no account made',
      setUp: () => whenCodeSent(
        const PhoneAutoVerified(firebaseIdToken: firebaseIdToken),
      ),
      build: build,
      act: (viewModel) => viewModel.doAction(const SendResetCodeEvent(phone)),
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<PhoneVerified>().having(
            (r) => r.proof,
            'proof',
            const FirebaseProof(firebaseIdToken),
          ),
        ),
      ],
      verify: (_) => verifyZeroInteractions(completeRegister),
    );
  });

  group('VerifyResetCodeEvent', () {
    blocTest<AuthViewModel, AuthState>(
      "the right code: PhoneVerified with Firebase's proof",
      setUp: () {
        whenCodeSent();
        when(
          verifyOtp(verificationId: 'vid', smsCode: '123456'),
        ).thenAnswer((_) async => const Success(data: firebaseIdToken));
      },
      build: build,
      act: (viewModel) async {
        await viewModel.doAction(const SendResetCodeEvent(phone));
        await viewModel.doAction(const VerifyResetCodeEvent('123456'));
      },
      skip: 2,
      expect: () => [
        isLoadingState,
        isSuccessState(
          isA<PhoneVerified>().having(
            (r) => r.proof,
            'proof',
            const FirebaseProof(firebaseIdToken),
          ),
        ),
      ],
    );
  });

  group('ResetPasswordEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'set: PasswordReset',
      setUp: () => when(
        resetPassword(resetRequest),
      ).thenAnswer((_) async => const Success(data: null)),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const ResetPasswordEvent(resetRequest)),
      expect: () => [isLoadingState, isSuccessState(isA<PasswordReset>())],
    );

    blocTest<AuthViewModel, AuthState>(
      'the proof is too old: the error',
      setUp: () => when(resetPassword(any)).thenAnswer(
        (_) async => const Failure(
          exception: ServerException(
            code: AuthErrorCodes.resetVerificationExpired,
          ),
        ),
      ),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const ResetPasswordEvent(resetRequest)),
      expect: () => [isLoadingState, isErrorState<ServerException>()],
    );
  });

  group('ChangePasswordEvent', () {
    blocTest<AuthViewModel, AuthState>(
      'changed: PasswordChanged',
      setUp: () => when(
        changePassword(changeRequest),
      ).thenAnswer((_) async => const Success(data: null)),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const ChangePasswordEvent(changeRequest)),
      expect: () => [isLoadingState, isSuccessState(isA<PasswordChanged>())],
    );

    blocTest<AuthViewModel, AuthState>(
      'signed out meanwhile: the UnauthorizedException',
      setUp: () => when(changePassword(any)).thenAnswer(
        (_) async => const Failure(exception: UnauthorizedException()),
      ),
      build: build,
      act: (viewModel) =>
          viewModel.doAction(const ChangePasswordEvent(changeRequest)),
      expect: () => [isLoadingState, isErrorState<UnauthorizedException>()],
    );
  });
}
