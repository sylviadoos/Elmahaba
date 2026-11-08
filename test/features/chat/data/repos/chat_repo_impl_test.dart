import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_page_model.dart';
import 'package:al_mahhaba_school/features/chat/data/repos/chat_repo_impl.dart';

import '../../../../helpers/result_matchers.dart';
import '../../chat_fixtures.dart';
import 'chat_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ChatRemoteDataSource>(),
  MockSpec<ChatLocalDataSource>(),
])
void main() {
  late MockChatRemoteDataSource remoteDataSource;
  late MockChatLocalDataSource localDataSource;
  late ChatRepoImpl repo;

  final page = ChatPageModel(
    items: [schoolItem('message:41', about: omar)],
    hasMore: true,
    nextBefore: 'cursor-1',
    unread: 1,
    isOpen: true,
    canSend: true,
  );

  setUp(() {
    remoteDataSource = MockChatRemoteDataSource();
    localDataSource = MockChatLocalDataSource();
    repo = ChatRepoImpl(remoteDataSource, localDataSource);
  });

  group('getChat', () {
    test('the newest: kept for the next time it opens', () async {
      final cancel = CancelHandle();
      when(
        remoteDataSource.getChat(studentId: omar.studentId, cancel: cancel),
      ).thenAnswer((_) async => page);

      final result = await repo.getChat(
        studentId: omar.studentId,
        cancel: cancel,
      );

      expect(result, isSuccess<Object?>(page));
      verify(localDataSource.saveNewestPage(omar.studentId, page)).called(1);
    });

    test('older ones: not kept', () async {
      when(
        remoteDataSource.getChat(
          studentId: omar.studentId,
          before: 'cursor-1',
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => page);

      await repo.getChat(studentId: omar.studentId, before: 'cursor-1');

      verifyNever(localDataSource.saveNewestPage(any, any));
    });

    test('didn\'t load: what was kept stays', () async {
      when(
        remoteDataSource.getChat(
          studentId: anyNamed('studentId'),
          cancel: anyNamed('cancel'),
        ),
      ).thenThrow(const NetworkException());

      expect(await repo.getChat(), isFailure<NetworkException>());
      verifyNever(localDataSource.saveNewestPage(any, any));
    });
  });

  test('cachedChat: what was kept for that child', () {
    when(localDataSource.newestPage(omar.studentId)).thenReturn(page);

    expect(repo.cachedChat(omar.studentId), page);
    expect(repo.cachedChat(lina.studentId), isNull);
  });
}
