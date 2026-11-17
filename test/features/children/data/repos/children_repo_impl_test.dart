import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_proof_entity.dart';
import 'package:al_mahhaba_school/features/auth/domain/entities/phone_verification_entity.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/data/repos/children_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';

void main() {
  late MockChildrenRemoteDataSource remoteDataSource;
  late MockChildrenLocalDataSource localDataSource;
  late MockPhoneVerificationDataSource phoneVerification;
  late ChildrenRepoImpl repo;

  setUp(() {
    remoteDataSource = MockChildrenRemoteDataSource();
    localDataSource = MockChildrenLocalDataSource();
    phoneVerification = MockPhoneVerificationDataSource();
    repo = ChildrenRepoImpl(
      remoteDataSource,
      localDataSource,
      phoneVerification,
    );
    when(localDataSource.getSavedChildren()).thenAnswer((_) async => []);
  });

  group('verifyChildLink', () {
    test('the right code: the child, saved with the others', () async {
      when(
        remoteDataSource.verifyChildLink(
          token: 'token-1',
          proof: const SchoolCodeProof('123456'),
        ),
      ).thenAnswer((_) async => ereny);

      final result = await repo.verifyChildLink(
        token: 'token-1',
        proof: const SchoolCodeProof('123456'),
      );

      expect(result, isSuccess(ereny));
      verify(localDataSource.saveChildren([ereny])).called(1);
      verifyNever(phoneVerification.signOut());
    });

    test('proved by Firebase: linked, then signed out of Firebase', () async {
      when(
        remoteDataSource.verifyChildLink(
          token: 'token-1',
          proof: const FirebaseProof('firebase-id-token'),
        ),
      ).thenAnswer((_) async => ereny);

      expect(
        await repo.verifyChildLink(
          token: 'token-1',
          proof: const FirebaseProof('firebase-id-token'),
        ),
        isSuccess(ereny),
      );
      verify(phoneVerification.signOut()).called(1);
    });

    test(
      'a wrong code: fails with the school\'s error, nothing saved',
      () async {
        when(
          remoteDataSource.verifyChildLink(
            token: anyNamed('token'),
            proof: anyNamed('proof'),
          ),
        ).thenThrow(const ServerException(code: 'otp_incorrect'));

        expect(
          await repo.verifyChildLink(
            token: 'token-1',
            proof: const SchoolCodeProof('000000'),
          ),
          isFailure<ServerException>(),
        );
        verifyNever(localDataSource.saveChildren(any));
      },
    );
  });

  test('sendChildLinkCode: Firebase sends to the number', () async {
    provideDummy<PhoneVerificationEntity>(
      const PhoneAutoVerified(firebaseIdToken: ''),
    );
    const sent = SmsCodeSent(verificationId: 'vid', resendToken: 3);
    when(
      phoneVerification.sendCode(any, resendToken: anyNamed('resendToken')),
    ).thenAnswer((_) async => sent);

    expect(
      await repo.sendChildLinkCode('01012345678', resendToken: 2),
      isSuccess(sent),
    );
    verify(phoneVerification.sendCode('01012345678', resendToken: 2)).called(1);
  });

  test('resendChildLinkCode: the check, as the school sent it again', () async {
    final again = LinkVerificationModel.fromJson({
      ...verificationJson,
      'resends_left': 2,
    });
    when(
      remoteDataSource.resendChildLinkCode('token-1'),
    ).thenAnswer((_) async => again);

    expect(await repo.resendChildLinkCode('token-1'), isSuccess(again));
  });
}
