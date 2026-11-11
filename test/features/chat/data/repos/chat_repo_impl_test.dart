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
    test(
      'the school confirmed: what\'s still unread, told to every page',
      () async {
        when(
          remoteDataSource.markRead(['event:40']),
        ).thenAnswer((_) async => 2);
        final told = <int>[];
        final listening = repo.onMarkedRead.listen(told.add);
        addTearDown(listening.cancel);

        expect(await repo.markRead(['event:40']), isSuccess<int>(2));
        await Future<void>.delayed(Duration.zero);
        expect(told, [2]);
      },
    );

    test('it failed: nothing told', () async {
      when(remoteDataSource.markRead(any)).thenThrow(const NetworkException());
      final told = <int>[];
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
