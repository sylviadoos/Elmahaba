import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/data/data_sources/phone_verification_data_source_impl.dart';
import 'package:al_mahhaba_school/features/auth/domain/auth_error_codes.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';

import '../../auth_fixtures.dart';
import 'phone_verification_data_source_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
  MockSpec<User>(),
])
void main() {
  late MockFirebaseAuth auth;
  late PhoneVerificationDataSourceImpl dataSource;

  setUp(() {
    auth = MockFirebaseAuth();
    dataSource = PhoneVerificationDataSourceImpl(auth);
  });

  /// Signing in to Firebase gives [token] as the proof of the number.
  void whenSignedIn({String? token = firebaseIdToken}) {
    final user = MockUser();
    final credential = MockUserCredential();
    when(user.getIdToken()).thenAnswer((_) async => token);
    when(credential.user).thenReturn(user);
    when(auth.signInWithCredential(any)).thenAnswer((_) async => credential);
  }

  /// Firebase answers `verifyPhoneNumber` by calling [answer] with its
  /// callbacks.
  void whenVerifying(
    void Function({
      required PhoneCodeSent codeSent,
      required PhoneVerificationCompleted verificationCompleted,
      required PhoneVerificationFailed verificationFailed,
    })
    answer,
  ) {
    when(
      auth.verifyPhoneNumber(
        phoneNumber: anyNamed('phoneNumber'),
        forceResendingToken: anyNamed('forceResendingToken'),
        codeSent: anyNamed('codeSent'),
        verificationCompleted: anyNamed('verificationCompleted'),
        verificationFailed: anyNamed('verificationFailed'),
        codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
      ),
    ).thenAnswer((invocation) async {
      final callbacks = invocation.namedArguments;
      answer(
        codeSent: callbacks[#codeSent] as PhoneCodeSent,
        verificationCompleted:
            callbacks[#verificationCompleted] as PhoneVerificationCompleted,
        verificationFailed:
            callbacks[#verificationFailed] as PhoneVerificationFailed,
      );
    });
  }

  PhoneAuthCredential smsCredential() =>
      PhoneAuthProvider.credential(verificationId: 'vid', smsCode: '123456');

  group('sendCode', () {
    test('sends to the number in international format', () async {
      whenVerifying(
        ({
          required codeSent,
          required verificationCompleted,
          required verificationFailed,
        }) => codeSent('vid', 7),
      );

      expect(
        await dataSource.sendCode(phone),
        const SmsCodeSent(verificationId: 'vid', resendToken: 7),
      );
      verify(
        auth.verifyPhoneNumber(
          phoneNumber: '+201012345678',
          forceResendingToken: null,
          codeSent: anyNamed('codeSent'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        ),
      ).called(1);
    });

    test('again: with the last resend token', () async {
      whenVerifying(
        ({
          required codeSent,
          required verificationCompleted,
          required verificationFailed,
        }) => codeSent('vid-2', 8),
      );

      await dataSource.sendCode(phone, resendToken: 7);

      verify(
        auth.verifyPhoneNumber(
          phoneNumber: anyNamed('phoneNumber'),
          forceResendingToken: 7,
          codeSent: anyNamed('codeSent'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        ),
      ).called(1);
    });

    test('Android verified the number itself: the proof, no code', () async {
      whenSignedIn();
      whenVerifying(
        ({
          required codeSent,
          required verificationCompleted,
          required verificationFailed,
        }) => verificationCompleted(smsCredential()),
      );

      expect(
        await dataSource.sendCode(phone),
        const PhoneAutoVerified(firebaseIdToken: firebaseIdToken),
      );
    });

    test('Android read the SMS after it was sent: the code is typed', () async {
      whenSignedIn();
      whenVerifying(({
        required codeSent,
        required verificationCompleted,
        required verificationFailed,
      }) {
        codeSent('vid', 7);
        verificationCompleted(smsCredential());
      });

      expect(await dataSource.sendCode(phone), isA<SmsCodeSent>());
      verifyNever(auth.signInWithCredential(any));
    });

    test(
      "Firebase refuses: a PhoneVerificationException with its code",
      () async {
        whenVerifying(
          ({
            required codeSent,
            required verificationCompleted,
            required verificationFailed,
          }) => verificationFailed(
            FirebaseAuthException(code: AuthErrorCodes.tooManyRequests),
          ),
        );

        await expectLater(
          dataSource.sendCode(phone),
          throwsA(
            isA<PhoneVerificationException>().having(
              (e) => e.code,
              'code',
              AuthErrorCodes.tooManyRequests,
            ),
          ),
        );
      },
    );

    test('offline: a NetworkException', () async {
      whenVerifying(
        ({
          required codeSent,
          required verificationCompleted,
          required verificationFailed,
        }) => verificationFailed(
          FirebaseAuthException(code: 'network-request-failed'),
        ),
      );

      await expectLater(
        dataSource.sendCode(phone),
        throwsA(isA<NetworkException>()),
      );
    });

    test('the request itself fails: a PhoneVerificationException', () async {
      when(
        auth.verifyPhoneNumber(
          phoneNumber: anyNamed('phoneNumber'),
          forceResendingToken: anyNamed('forceResendingToken'),
          codeSent: anyNamed('codeSent'),
          verificationCompleted: anyNamed('verificationCompleted'),
          verificationFailed: anyNamed('verificationFailed'),
          codeAutoRetrievalTimeout: anyNamed('codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer(
        (_) =>
            Future.error(FirebaseAuthException(code: 'invalid-phone-number')),
      );

      await expectLater(
        dataSource.sendCode(phone),
        throwsA(isA<PhoneVerificationException>()),
      );
    });
  });

  group('verifyCode', () {
    test('the right code: the proof of the number', () async {
      whenSignedIn();

      expect(
        await dataSource.verifyCode(verificationId: 'vid', smsCode: '123456'),
        firebaseIdToken,
      );
    });

    test('a wrong code: a PhoneVerificationException', () async {
      when(
        auth.signInWithCredential(any),
      ).thenThrow(FirebaseAuthException(code: AuthErrorCodes.wrongCode));

      await expectLater(
        dataSource.verifyCode(verificationId: 'vid', smsCode: '000000'),
        throwsA(
          isA<PhoneVerificationException>().having(
            (e) => e.code,
            'code',
            AuthErrorCodes.wrongCode,
          ),
        ),
      );
    });

    test('no proof given back: an UnknownException', () async {
      whenSignedIn(token: null);

      await expectLater(
        dataSource.verifyCode(verificationId: 'vid', smsCode: '123456'),
        throwsA(isA<UnknownException>()),
      );
    });
  });

  test('signOut ends the Firebase sign-in', () async {
    await dataSource.signOut();

    verify(auth.signOut()).called(1);
  });
}
