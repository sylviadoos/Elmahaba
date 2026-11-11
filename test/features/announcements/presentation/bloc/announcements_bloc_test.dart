import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_effect.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../announcements_fixtures.dart';
import '../../announcements_mocks.mocks.dart';

void main() {
  late MockGetAnnouncementsUseCase getAnnouncements;
  late MockMarkChatReadUseCase markRead;
  late MockDownloadChatAttachmentUseCase downloadAttachment;
  late MockPreviewChatAttachmentUseCase previewAttachment;
  late List<AnnouncementsEffect> effects;

  setUpAll(() {
    provideResultDummy<AnnouncementsPageEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
  });

  setUp(() {
    getAnnouncements = MockGetAnnouncementsUseCase();
    markRead = MockMarkChatReadUseCase();
    downloadAttachment = MockDownloadChatAttachmentUseCase();
    previewAttachment = MockPreviewChatAttachmentUseCase();
    effects = [];
    when(markRead(any)).thenAnswer((_) async => const Success(data: 4));
  });

  AnnouncementsBloc build() {
    final bloc = AnnouncementsBloc(
      getAnnouncements,
      markRead,
      downloadAttachment,
      previewAttachment,
    );
    bloc.effects.listen(effects.add);
    return bloc;
  }

  /// [page] of [childId]'s announcements answers [page]'s number.
  void announcementsOf(int childId, AnnouncementsPageEntity page) => when(
    getAnnouncements(childId, page: page.page, cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => Success(data: page));

  void anyAnnouncementsFail(AppException exception) => when(
    getAnnouncements(any, page: anyNamed('page'), cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => Failure(exception: exception));

  group('opening', () {
    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'from Home: the child it showed',
      setUp: () => announcementsOf(
        lina.studentId,
        announcementsPage([meeting], unread: 1),
      ),
      build: build,
      act: (bloc) => bloc.add(
        AnnouncementsChildrenIntent(
          const [omar, lina],
          isLoading: false,
          preferredId: lina.studentId,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [meeting]);
        expect(bloc.state.page?.unread, 1);
      },
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'otherwise: the first child',
      setUp: () => announcementsOf(omar.studentId, announcementsPage([])),
      build: build,
      act: (bloc) => bloc.add(
        const AnnouncementsChildrenIntent([omar, lina], isLoading: false),
      ),
      verify: (bloc) => expect(bloc.state.studentId, omar.studentId),
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'children still loading: waits for them',
      build: build,
      act: (bloc) =>
          bloc.add(const AnnouncementsChildrenIntent(null, isLoading: true)),
      verify: (bloc) {
        expect(bloc.state.isRequested, isFalse);
        verifyZeroInteractions(getAnnouncements);
      },
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'no children: nothing listed, nothing asked',
      build: build,
      act: (bloc) =>
          bloc.add(const AnnouncementsChildrenIntent([], isLoading: false)),
      verify: (bloc) {
        expect(bloc.state.page?.items, isEmpty);
        verifyZeroInteractions(getAnnouncements);
      },
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'a read-only child: why, from the school',
      setUp: () => anyAnnouncementsFail(
        const ServerException(statusCode: 403, code: 'read_only_child'),
      ),
      build: build,
      act: (bloc) => bloc.add(ShowChildAnnouncementsIntent(omar.studentId)),
      verify: (bloc) => expect(
        bloc.state.announcements.exception,
        isA<ServerException>().having((e) => e.code, 'code', 'read_only_child'),
      ),
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'a child picked in the header: theirs, and every page shows them',
      setUp: () =>
          announcementsOf(lina.studentId, announcementsPage([meeting])),
      build: build,
      act: (bloc) => bloc.add(ShowChildAnnouncementsIntent(lina.studentId)),
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [meeting]);
        expect(
          effects.whereType<AnnouncementsChildPickedEffect>().single.studentId,
          lina.studentId,
        );
      },
    );
  });

  group('more', () {
    final first = announcementsPage([meeting], lastPage: 2, total: 2);
    final second = announcementsPage([sportsDay], page: 2, lastPage: 2);

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'the next page goes after the first',
      setUp: () => announcementsOf(omar.studentId, second),
      build: build,
      seed: () => AnnouncementsState(
        children: const [omar],
        isRequested: true,
        studentId: omar.studentId,
        announcements: BaseState.success(first),
      ),
      act: (bloc) => bloc.add(const LoadMoreAnnouncementsIntent()),
      verify: (bloc) {
        expect(bloc.state.page?.items, [meeting, sportsDay]);
        expect(bloc.state.page?.hasMore, isFalse);
      },
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'it didn\'t load: the first stays, with why',
      setUp: () => anyAnnouncementsFail(const NetworkException()),
      build: build,
      seed: () => AnnouncementsState(
        isRequested: true,
        studentId: omar.studentId,
        announcements: BaseState.success(first),
      ),
      act: (bloc) => bloc.add(const LoadMoreAnnouncementsIntent()),
      verify: (bloc) {
        expect(bloc.state.page?.items, [meeting]);
        expect(bloc.state.announcements.state, StateType.error);
      },
    );

    blocTest<AnnouncementsBloc, AnnouncementsState>(
      'past the last page: nothing asked',
      build: build,
      seed: () => AnnouncementsState(
        isRequested: true,
        studentId: omar.studentId,
        announcements: BaseState.success(announcementsPage([meeting])),
      ),
      act: (bloc) => bloc.add(const LoadMoreAnnouncementsIntent()),
      verify: (_) => verifyZeroInteractions(getAnnouncements),
    );
  });

  blocTest<AnnouncementsBloc, AnnouncementsState>(
    'pulled down and it fails: what was shown stays, a snack bar says why',
    setUp: () => anyAnnouncementsFail(const NetworkException()),
    build: build,
    seed: () => AnnouncementsState(
      isRequested: true,
      studentId: omar.studentId,
      announcements: BaseState.success(announcementsPage([meeting])),
    ),
    act: (bloc) => bloc.add(const ReloadAnnouncementsIntent()),
    verify: (bloc) {
      expect(bloc.state.page?.items, [meeting]);
      expect(effects.whereType<ShowAnnouncementsErrorEffect>(), hasLength(1));
    },
  );

  blocTest<AnnouncementsBloc, AnnouncementsState>(
    'seen: marked read together, once, and the chat badge updated',
    build: build,
    act: (bloc) => bloc
      ..add(const AnnouncementSeenIntent('event:40'))
      ..add(const AnnouncementSeenIntent('event:52'))
      ..add(const AnnouncementSeenIntent('event:40')),
    wait: const Duration(milliseconds: 500),
    verify: (_) {
      verify(markRead(['event:40', 'event:52'])).called(1);
      expect(
        effects.whereType<AnnouncementsChatUnreadEffect>().single.count,
        4,
      );
    },
  );

  blocTest<AnnouncementsBloc, AnnouncementsState>(
    'a file: downloaded, then opened',
    setUp: () => when(
      downloadAttachment(agendaFile, cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => const Success(data: '/files/agenda.pdf')),
    build: build,
    act: (bloc) => bloc.add(const OpenAnnouncementFileIntent(agendaFile)),
    expect: () => [
      const AnnouncementsState(downloadingId: 77),
      const AnnouncementsState(),
    ],
    verify: (_) {
      final opened = effects.whereType<OpenAnnouncementFileEffect>().single;
      expect(opened.path, '/files/agenda.pdf');
      expect(opened.attachment, agendaFile);
    },
  );
}
