import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/core/pdf/pdf_previewer.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_local_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/data_sources/chat_remote_data_source.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_page_model.dart';
import 'package:al_mahhaba_school/features/chat/data/repos/chat_repo_impl.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';

import '../../../../helpers/result_matchers.dart';
import '../../chat_fixtures.dart';
import 'chat_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ChatRemoteDataSource>(),
  MockSpec<ChatLocalDataSource>(),
  MockSpec<PdfPreviewer>(),
])
void main() {
  late MockChatRemoteDataSource remoteDataSource;
  late MockChatLocalDataSource localDataSource;
  late MockPdfPreviewer pdfPreviewer;
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
    pdfPreviewer = MockPdfPreviewer();
    repo = ChatRepoImpl(remoteDataSource, localDataSource, pdfPreviewer);
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

    test('just the latest few (a refresh): asked for, the full page kept '
        'stays', () async {
      when(
        remoteDataSource.getChat(
          studentId: omar.studentId,
          limit: 5,
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => page);

      final result = await repo.getChat(studentId: omar.studentId, limit: 5);

      expect(result, isSuccess<Object?>(page));
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

  group('previewAttachment', () {
    test('saved, then its first page drawn beside it', () async {
      when(
        remoteDataSource.downloadAttachment(
          attachment,
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => '/tmp/77_trip-form.pdf');
      when(
        pdfPreviewer.firstPage('/tmp/77_trip-form.pdf'),
      ).thenAnswer((_) async => '/tmp/77_trip-form.pdf.preview.png');

      expect(
        await repo.previewAttachment(attachment),
        isSuccess<Object?>('/tmp/77_trip-form.pdf.preview.png'),
      );
    });

    test('didn\'t download: nothing drawn', () async {
      when(
        remoteDataSource.downloadAttachment(
          attachment,
          cancel: anyNamed('cancel'),
        ),
      ).thenThrow(const NetworkException());

      expect(
        await repo.previewAttachment(attachment),
        isFailure<NetworkException>(),
      );
      verifyNever(pdfPreviewer.firstPage(any));
    });

    test('can\'t be drawn: a failure, not a crash', () async {
      when(
        remoteDataSource.downloadAttachment(
          attachment,
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => '/tmp/77_trip-form.pdf');
      when(pdfPreviewer.firstPage(any)).thenThrow(Exception('not a PDF'));

      expect(
        await repo.previewAttachment(attachment),
        isFailure<UnknownException>(),
      );
    });
  });

  group('markRead', () {
    test('the school confirmed: for whom and what\'s still unread, told to '
        'every page', () async {
      when(
        remoteDataSource.markRead(['event:40'], studentId: 1208),
      ).thenAnswer((_) async => 2);
      final told = <ChatReadEntity>[];
      final listening = repo.onMarkedRead.listen(told.add);
      addTearDown(listening.cancel);

      expect(
        await repo.markRead(['event:40'], studentId: 1208),
        isSuccess<int>(2),
      );
      await Future<void>.delayed(Duration.zero);
      expect(told, [const ChatReadEntity(studentId: 1208, unread: 2)]);
    });

    test('a file: asked for the child whose page it\'s on', () async {
      when(
        remoteDataSource.downloadAttachment(
          any,
          studentId: anyNamed('studentId'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => '/tmp/77_trip-form.pdf');

      await repo.downloadAttachment(attachment, studentId: 1208);

      verify(
        remoteDataSource.downloadAttachment(
          attachment,
          studentId: 1208,
          cancel: anyNamed('cancel'),
        ),
      ).called(1);
    });

    test('read on one child\'s page: the school is told whose', () async {
      when(
        remoteDataSource.markRead(any, studentId: anyNamed('studentId')),
      ).thenAnswer((_) async => 1);

      await repo.markRead(['event:41'], studentId: 1208);

      // The same item can be about another child of theirs, and that
      // one's is still new.
      verify(
        remoteDataSource.markRead(['event:41'], studentId: 1208),
      ).called(1);
    });

    test('read on the chat\'s "All": no child', () async {
      when(
        remoteDataSource.markRead(any, studentId: anyNamed('studentId')),
      ).thenAnswer((_) async => 0);

      await repo.markRead(['event:41']);

      verify(remoteDataSource.markRead(['event:41'])).called(1);
    });

    test('it failed: nothing told', () async {
      when(remoteDataSource.markRead(any)).thenThrow(const NetworkException());
      final told = <ChatReadEntity>[];
      final listening = repo.onMarkedRead.listen(told.add);
      addTearDown(listening.cancel);

      expect(await repo.markRead(['event:40']), isFailure<NetworkException>());
      await Future<void>.delayed(Duration.zero);
      expect(told, isEmpty);
    });
  });

  test('cachedChat: what was kept for that child', () {
    when(localDataSource.newestPage(omar.studentId)).thenReturn(page);

    expect(repo.cachedChat(omar.studentId), page);
    expect(repo.cachedChat(lina.studentId), isNull);
  });
}
