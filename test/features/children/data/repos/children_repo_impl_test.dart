import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/children/data/models/link_verification_model.dart';
import 'package:al_mahhaba_school/features/children/data/repos/children_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../children_fixtures.dart';
import '../../children_mocks.mocks.dart';

void main() {
  late MockChildrenRemoteDataSource remoteDataSource;
  late MockChildrenLocalDataSource localDataSource;
  late ChildrenRepoImpl repo;

  setUp(() {
    remoteDataSource = MockChildrenRemoteDataSource();
    localDataSource = MockChildrenLocalDataSource();
    repo = ChildrenRepoImpl(remoteDataSource, localDataSource);
    when(localDataSource.getSavedChildren()).thenAnswer((_) async => []);
  });

  group('verifyChildLink', () {
    test('the right code: the child, saved with the others', () async {
      when(
        remoteDataSource.verifyChildLink(token: 'token-1', code: '123456'),
      ).thenAnswer((_) async => ereny);

      final result = await repo.verifyChildLink(
        token: 'token-1',
        code: '123456',
      );

      expect(result, isSuccess(ereny));
      verify(localDataSource.saveChildren([ereny])).called(1);
    });

    test(
      'a wrong code: fails with the school\'s error, nothing saved',
      () async {
        when(
          remoteDataSource.verifyChildLink(
            token: anyNamed('token'),
            code: anyNamed('code'),
          ),
        ).thenThrow(const ServerException(code: 'otp_incorrect'));

        expect(
          await repo.verifyChildLink(token: 'token-1', code: '000000'),
          isFailure<ServerException>(),
        );
        verifyNever(localDataSource.saveChildren(any));
      },
    );
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
