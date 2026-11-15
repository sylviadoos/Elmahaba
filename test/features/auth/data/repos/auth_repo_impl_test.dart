import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source.dart';
import 'package:al_mahhaba_school/features/auth/data/models/change_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/complete_register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/login_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/register_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/models/reset_password_request_model.dart';
import 'package:al_mahhaba_school/features/auth/data/repos/auth_repo_impl.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/complete_register_request_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/children/data/data_sources/children_local_data_source.dart';

import '../../../../helpers/result_matchers.dart';
import '../../auth_fixtures.dart';
import 'auth_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthRemoteDataSource>(),
  MockSpec<AuthLocalDataSource>(),
  MockSpec<PhoneVerificationDataSource>(),
  MockSpec<ChildrenLocalDataSource>(),
  MockSpec<ChatLocalDataSource>(),
])
void main() {
  late MockAuthRemoteDataSource remoteDataSource;
  late MockAuthLocalDataSource localDataSource;
  late MockPhoneVerificationDataSource phoneVerification;
  late MockChildrenLocalDataSource childrenLocalDataSource;
  late MockChatLocalDataSource chatLocalDataSource;
  late AuthRepoImpl repo;

  setUpAll(() {
    // Sealed, so mockito can't make one up.
    provideDummy<PhoneVerificationEntity>(
      const PhoneAutoVerified(firebaseIdToken: ''),
    );
  });

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSource();
    localDataSource = MockAuthLocalDataSource();
    phoneVerification = MockPhoneVerificationDataSource();
    childrenLocalDataSource = MockChildrenLocalDataSource();
    chatLocalDataSource = MockChatLocalDataSource();
    repo = AuthRepoImpl(
      remoteDataSource,
      localDataSource,
      phoneVerification,
      childrenLocalDataSource,
      chatLocalDataSource,
    );
    when(localDataSource.clientInfo()).thenAnswer((_) async => client);
  });

  void verifyNothingKept() {
    verifyNever(localDataSource.saveToken(any));
    verifyNever(localDataSource.saveParent(any));
    verifyNever(childrenLocalDataSource.saveChildren(any));
  }

  void verifyNothingForgotten() {
    verifyNever(localDataSource.clearToken());
    verifyNever(localDataSource.clearParent());
    verifyNever(childrenLocalDataSource.clearChildren());
  }

  group('checkPhone', () {
    test('sends what was filled in, returns the eligibility', () async {
      when(
        remoteDataSource.checkPhone(any),
      ).thenAnswer((_) async => eligibility);

      expect(await repo.checkPhone(registerRequest), isSuccess(eligibility));
      final sent =
          verify(remoteDataSource.checkPhone(captureAny)).captured.single
              as RegisterRequestModel;
      expect(sent.toJson(), {
        'phone_number': phone,
        'password': password,
        'password_confirmation': password,
      });
    });

    test('not in the school records: fails with the server error', () async {
      when(remoteDataSource.checkPhone(any)).thenThrow(
        const ServerException(code: AuthErrorCodes.registrationNotEligible),
      );

      expect(
        await repo.checkPhone(registerRequest),
        isFailure<ServerException>(),
      );
    });
  });

  group('login', () {
    test('signs in with the device, keeps token, parent (with the number in '
        'full) and children', () async {
      when(remoteDataSource.login(any)).thenAnswer((_) async => session);

      expect(await repo.login(loginRequest), isSuccess(session));
      final sent =
          verify(remoteDataSource.login(captureAny)).captured.single
              as LoginRequestModel;
      expect(sent.toJson(), {
        'phone_number': phone,
        'password': password,
        ...client.toJson(),
      });
      verifyInOrder([
        localDataSource.saveToken('jwt-token'),
        localDataSource.saveParent(parent.withFullPhone(phone)),
        childrenLocalDataSource.saveChildren(session.children),
      ]);
    });

    test('wrong password: fails, nothing kept', () async {
      when(remoteDataSource.login(any)).thenThrow(
        const ServerException(statusCode: 401, code: 'invalid_credentials'),
      );

      expect(await repo.login(loginRequest), isFailure<ServerException>());
      verifyNothingKept();
    });
  });

  group('sendOtp', () {
    test('sends to the number, with the resend token', () async {
      const sent = SmsCodeSent(verificationId: 'vid', resendToken: 8);
      when(
        phoneVerification.sendCode(any, resendToken: anyNamed('resendToken')),
      ).thenAnswer((_) async => sent);

      expect(await repo.sendOtp(phone, resendToken: 7), isSuccess(sent));
      verify(phoneVerification.sendCode(phone, resendToken: 7)).called(1);
    });

    test('Firebase refuses: fails with its error', () async {
      when(
        phoneVerification.sendCode(any, resendToken: anyNamed('resendToken')),
      ).thenThrow(
        const PhoneVerificationException(code: AuthErrorCodes.tooManyRequests),
      );

      expect(
        await repo.sendOtp(phone),
        isFailure<PhoneVerificationException>(),
      );
    });
  });

  group('verifyOtp', () {
    test("returns Firebase's proof of the number", () async {
      when(
        phoneVerification.verifyCode(verificationId: 'vid', smsCode: '123456'),
      ).thenAnswer((_) async => firebaseIdToken);

      expect(
        await repo.verifyOtp(verificationId: 'vid', smsCode: '123456'),
        isSuccess(firebaseIdToken),
      );
    });

    test('a wrong code: fails', () async {
      when(
        phoneVerification.verifyCode(
          verificationId: anyNamed('verificationId'),
          smsCode: anyNamed('smsCode'),
        ),
      ).thenThrow(
        const PhoneVerificationException(code: AuthErrorCodes.wrongCode),
      );

      expect(
        await repo.verifyOtp(verificationId: 'vid', smsCode: '000000'),
        isFailure<PhoneVerificationException>(),
      );
    });
  });

  group('completeRegistration', () {
    const request = CompleteRegisterRequestEntity(
      phone: phone,
      password: password,
      firebaseIdToken: firebaseIdToken,
    );

    test(
      'creates the account, signs out of Firebase, keeps no token',
      () async {
        when(
          remoteDataSource.completeRegistration(any),
        ).thenAnswer((_) async => session);

        expect(await repo.completeRegistration(request), isSuccess(session));
        final sent =
            verify(
                  remoteDataSource.completeRegistration(captureAny),
                ).captured.single
                as CompleteRegisterRequestModel;
        expect(sent.toJson(), {
          'phone_number': phone,
          'password': password,
          'firebase_id_token': firebaseIdToken,
          ...client.toJson(),
        });
        verify(phoneVerification.signOut()).called(1);
        // The parent logs in next.
        verifyNothingKept();
      },
    );

    test("a failed Firebase sign-out doesn't matter", () async {
      when(
        remoteDataSource.completeRegistration(any),
      ).thenAnswer((_) async => session);
      when(
        phoneVerification.signOut(),
      ).thenAnswer((_) => Future.error(Exception('offline')));

      expect(await repo.completeRegistration(request), isSuccess(session));
    });

    test('already registered: fails, still signed in to Firebase', () async {
      when(remoteDataSource.completeRegistration(any)).thenThrow(
        const ServerException(code: AuthErrorCodes.alreadyRegistered),
      );

      expect(
        await repo.completeRegistration(request),
        isFailure<ServerException>(),
      );
      verifyNever(phoneVerification.signOut());
    });
  });

  group('resetPassword', () {
    test('sets the new password, signs out of Firebase', () async {
      expect(await repo.resetPassword(resetRequest), isSuccess<void>(isNull));
      final sent =
          verify(remoteDataSource.resetPassword(captureAny)).captured.single
              as ResetPasswordRequestModel;
      expect(sent.toJson(), {
        'phone_number': phone,
        'firebase_id_token': firebaseIdToken,
        'password': password,
        'password_confirmation': password,
      });
      verify(phoneVerification.signOut()).called(1);
    });

    test('the proof is too old: fails', () async {
      when(remoteDataSource.resetPassword(any)).thenThrow(
        const ServerException(code: AuthErrorCodes.resetVerificationExpired),
      );

      expect(
        await repo.resetPassword(resetRequest),
        isFailure<ServerException>(),
      );
      verifyNever(phoneVerification.signOut());
    });
  });

  group('changePassword', () {
    test('sends the current and new passwords', () async {
      expect(await repo.changePassword(changeRequest), isSuccess<void>(isNull));
      final sent =
          verify(remoteDataSource.changePassword(captureAny)).captured.single
              as ChangePasswordRequestModel;
      expect(sent.toJson(), {
        'current_password': 'old-pass1',
        'password': password,
        'password_confirmation': password,
      });
    });

    test('signed out meanwhile: fails with UnauthorizedException', () async {
      when(
        remoteDataSource.changePassword(any),
      ).thenThrow(const UnauthorizedException());

      expect(
        await repo.changePassword(changeRequest),
        isFailure<UnauthorizedException>(),
      );
    });
  });

  group('checkSession', () {
    test('no token kept: none, without asking the server', () async {
      when(localDataSource.hasToken()).thenAnswer((_) async => false);

      expect(await repo.checkSession(), isSuccess(SessionStatus.none));
      verifyNever(remoteDataSource.checkSession());
      verifyNothingForgotten();
    });

    test('the token still works: active', () async {
      when(localDataSource.hasToken()).thenAnswer((_) async => true);
      when(remoteDataSource.checkSession()).thenAnswer((_) async {});

      expect(await repo.checkSession(), isSuccess(SessionStatus.active));
      verify(remoteDataSource.checkSession()).called(1);
      verifyNothingForgotten();
    });

    test(
      'the server ended it: ended, the token, parent and children forgotten',
      () async {
        when(localDataSource.hasToken()).thenAnswer((_) async => true);
        when(
          remoteDataSource.checkSession(),
        ).thenThrow(const UnauthorizedException());

        expect(await repo.checkSession(), isSuccess(SessionStatus.ended));
        verifyInOrder([
          localDataSource.clearToken(),
          localDataSource.clearParent(),
          childrenLocalDataSource.clearChildren(),
        ]);
      },
    );

    test('the account is closed: withdrawn, and all of it forgotten', () async {
      when(localDataSource.hasToken()).thenAnswer((_) async => true);
      when(
        remoteDataSource.checkSession(),
      ).thenThrow(const UnauthorizedException(isAccountWithdrawn: true));

      expect(await repo.checkSession(), isSuccess(SessionStatus.withdrawn));
      verifyInOrder([
        localDataSource.clearToken(),
        localDataSource.clearParent(),
        childrenLocalDataSource.clearChildren(),
      ]);
    });

    test('offline: fails, the session is kept', () async {
      when(localDataSource.hasToken()).thenAnswer((_) async => true);
      when(remoteDataSource.checkSession()).thenThrow(const NetworkException());

      expect(await repo.checkSession(), isFailure<NetworkException>());
      verifyNothingForgotten();
    });

    test('a server error: fails, the session is kept', () async {
      when(localDataSource.hasToken()).thenAnswer((_) async => true);
      when(
        remoteDataSource.checkSession(),
      ).thenThrow(const ServerException(statusCode: 500));

      expect(await repo.checkSession(), isFailure<ServerException>());
      verifyNothingForgotten();
    });
  });

  test('logout forgets the token, parent, children and chats', () async {
    expect(await repo.logout(), isSuccess<void>(isNull));
    verifyInOrder([
      localDataSource.clearToken(),
      localDataSource.clearParent(),
      childrenLocalDataSource.clearChildren(),
    ]);
    // The next parent mustn't see this one's chats.
    verify(chatLocalDataSource.clear()).called(1);
  });

  group('getSavedParent', () {
    test('the parent kept by the last log in', () async {
      when(localDataSource.getSavedParent()).thenAnswer((_) async => parent);

      expect(await repo.getSavedParent(), parent);
      verifyZeroInteractions(remoteDataSource);
    });

    test('none kept: null', () async {
      expect(await repo.getSavedParent(), isNull);
    });
  });
}
