import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_effect.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';

import '../../../../helpers/result_dummy.dart';
import '../../homework_fixtures.dart';
import '../../homework_mocks.mocks.dart';

void main() {
  late MockGetHomeworkUseCase getHomework;
  late MockMarkChatReadUseCase markRead;
  late MockDownloadChatAttachmentUseCase downloadAttachment;
  late List<HomeworkEffect> effects;

  setUpAll(() {
    provideResultDummy<HomeworkPageEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
  });

  setUp(() {
    getHomework = MockGetHomeworkUseCase();
    markRead = MockMarkChatReadUseCase();
    downloadAttachment = MockDownloadChatAttachmentUseCase();
    effects = [];
    when(markRead(any)).thenAnswer((_) async => const Success(data: 0));
  });

  HomeworkBloc build() {
    final bloc = HomeworkBloc(getHomework, markRead, downloadAttachment);
    bloc.effects.listen(effects.add);
    return bloc;
  }

  /// Any page of [childId]'s homework comes back as [page].
  void homeworkOf(int childId, HomeworkPageEntity page) => when(
    getHomework(
      childId,
      filter: anyNamed('filter'),
      subjectId: anyNamed('subjectId'),
      page: anyNamed('page'),
      cancel: anyNamed('cancel'),
    ),
  ).thenAnswer((_) async => Success(data: page));

  /// Omar's first page shown.
  HomeworkState shown({
    HomeworkPageEntity? page,
    HomeworkFilter filter = HomeworkFilter.all,
  }) => HomeworkState(
    children: const [omar, lina],
    isRequested: true,
    studentId: omar.studentId,
    filter: filter,
    homework: BaseState.success(page ?? homeworkPage([exercise, reading])),
    subjects: const [math, arabic],
  );

  group('opening', () {
    blocTest<HomeworkBloc, HomeworkState>(
      'from the chat: the child it showed, and their subjects',
      setUp: () => homeworkOf(lina.studentId, homeworkPage([reading])),
      build: build,
      act: (bloc) => bloc.add(
        HomeworkChildrenIntent(
          const [omar, lina],
          isLoading: false,
          preferredId: lina.studentId,
        ),
      ),
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(bloc.state.page?.items, [reading]);
        expect(bloc.state.subjects, [math, arabic]);
      },
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'otherwise: the first child',
      setUp: () => homeworkOf(omar.studentId, homeworkPage([exercise])),
      build: build,
      act: (bloc) => bloc.add(
        const HomeworkChildrenIntent([omar, lina], isLoading: false),
      ),
      verify: (bloc) => expect(bloc.state.studentId, omar.studentId),
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'no children: nothing listed, nothing asked',
      build: build,
      act: (bloc) =>
          bloc.add(const HomeworkChildrenIntent([], isLoading: false)),
      verify: (bloc) {
        expect(bloc.state.page?.items, isEmpty);
        verifyNever(
          getHomework(
            any,
            filter: anyNamed('filter'),
            subjectId: anyNamed('subjectId'),
            page: anyNamed('page'),
            cancel: anyNamed('cancel'),
          ),
        );
      },
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'a read-only child: why, from the school',
      setUp: () =>
          when(
            getHomework(
              omar.studentId,
              filter: anyNamed('filter'),
              subjectId: anyNamed('subjectId'),
              page: anyNamed('page'),
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async => const Failure(
              exception: ServerException(
                statusCode: 403,
                code: 'read_only_child',
              ),
            ),
          ),
      build: build,
      act: (bloc) => bloc.add(ShowChildHomeworkIntent(omar.studentId)),
      verify: (bloc) => expect(
        bloc.state.homework.exception,
        isA<ServerException>().having((e) => e.code, 'code', 'read_only_child'),
      ),
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'a child picked in the header: every page shows them',
      setUp: () => homeworkOf(lina.studentId, homeworkPage([reading])),
      build: build,
      act: (bloc) => bloc.add(ShowChildHomeworkIntent(lina.studentId)),
      verify: (bloc) {
        expect(bloc.state.studentId, lina.studentId);
        expect(
          effects.whereType<HomeworkChildPickedEffect>().single.studentId,
          lina.studentId,
        );
      },
    );
  });

  group('filtering', () {
    blocTest<HomeworkBloc, HomeworkState>(
      'by due status: asked for again, from the first page',
      setUp: () => homeworkOf(omar.studentId, homeworkPage([exercise])),
      build: build,
      seed: shown,
      act: (bloc) =>
          bloc.add(const FilterHomeworkIntent(HomeworkFilter.dueSoon)),
      verify: (bloc) {
        verify(
          getHomework(
            omar.studentId,
            filter: HomeworkFilter.dueSoon,
            cancel: anyNamed('cancel'),
          ),
        ).called(1);
        expect(bloc.state.filter, HomeworkFilter.dueSoon);
        expect(bloc.state.isFiltered, isTrue);
        expect(bloc.state.page?.items, [exercise]);
      },
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'by subject: only it, the other subjects still to pick',
      setUp: () => homeworkOf(
        omar.studentId,
        homeworkPage([exercise], subjects: const []),
      ),
      build: build,
      seed: shown,
      act: (bloc) => bloc.add(const PickHomeworkSubjectIntent(3)),
      verify: (bloc) {
        verify(
          getHomework(omar.studentId, subjectId: 3, cancel: anyNamed('cancel')),
        ).called(1);
        expect(bloc.state.subjectId, 3);
        expect(bloc.state.subjects, [math, arabic]);
      },
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'the same filter again: nothing asked',
      build: build,
      seed: shown,
      act: (bloc) => bloc.add(const FilterHomeworkIntent(HomeworkFilter.all)),
      expect: () => <HomeworkState>[],
    );
  });

  group('more', () {
    blocTest<HomeworkBloc, HomeworkState>(
      'the next page comes after the ones shown',
      setUp: () =>
          when(
            getHomework(
              omar.studentId,
              filter: anyNamed('filter'),
              subjectId: anyNamed('subjectId'),
              page: 2,
              cancel: anyNamed('cancel'),
            ),
          ).thenAnswer(
            (_) async =>
                Success(data: homeworkPage([reading], page: 2, lastPage: 2)),
          ),
      build: build,
      seed: () => shown(page: homeworkPage([exercise], lastPage: 2)),
      act: (bloc) => bloc.add(const LoadMoreHomeworkIntent()),
      verify: (bloc) {
        expect(bloc.state.page?.items, [exercise, reading]);
        expect(bloc.state.page?.hasMore, isFalse);
      },
    );

    blocTest<HomeworkBloc, HomeworkState>(
      'pulled down and it doesn\'t load: still shown, why in a snack bar',
      setUp: () => when(
        getHomework(
          omar.studentId,
          filter: anyNamed('filter'),
          subjectId: anyNamed('subjectId'),
          page: anyNamed('page'),
          cancel: anyNamed('cancel'),
        ),
      ).thenAnswer((_) async => const Failure(exception: NetworkException())),
      build: build,
      seed: shown,
      act: (bloc) => bloc.add(const ReloadHomeworkIntent()),
      verify: (bloc) {
        expect(bloc.state.homework.state, StateType.success);
        expect(bloc.state.page?.items, [exercise, reading]);
        expect(effects, [isA<ShowHomeworkErrorEffect>()]);
      },
    );
  });

  group('read', () {
    blocTest<HomeworkBloc, HomeworkState>(
      'homework seen about the same time: one request, then the badge',
      build: build,
      seed: shown,
      act: (bloc) => bloc
        ..add(const HomeworkSeenIntent('event:41'))
        ..add(const HomeworkSeenIntent('event:42'))
        ..add(const HomeworkSeenIntent('event:41')),
      wait: const Duration(milliseconds: 500),
      verify: (_) {
        verify(markRead(['event:41', 'event:42'])).called(1);
        expect(effects, [isA<ChatUnreadChangedEffect>()]);
      },
    );
  });

  blocTest<HomeworkBloc, HomeworkState>(
    'a file downloaded: opened',
    setUp: () => when(
      downloadAttachment(exerciseFile, cancel: anyNamed('cancel')),
    ).thenAnswer((_) async => const Success(data: '/tmp/ex1.pdf')),
    build: build,
    seed: shown,
    act: (bloc) => bloc.add(const OpenHomeworkFileIntent(exerciseFile)),
    expect: () => [
      isA<HomeworkState>().having((s) => s.downloadingId, 'downloading', 88),
      isA<HomeworkState>().having((s) => s.downloadingId, 'downloading', null),
    ],
    verify: (_) => expect(effects, [
      isA<OpenHomeworkFileEffect>().having(
        (e) => e.path,
        'path',
        '/tmp/ex1.pdf',
      ),
    ]),
  );

  test('closed while it loads: the request is stopped', () async {
    CancelHandle? cancel;
    when(
      getHomework(
        omar.studentId,
        filter: anyNamed('filter'),
        subjectId: anyNamed('subjectId'),
        page: anyNamed('page'),
        cancel: anyNamed('cancel'),
      ),
    ).thenAnswer((invocation) {
      cancel = invocation.namedArguments[#cancel] as CancelHandle?;
      return Completer<Result<HomeworkPageEntity>>().future;
    });
    final bloc = build()..add(ShowChildHomeworkIntent(omar.studentId));
    await Future<void>.delayed(Duration.zero);
    expect(cancel?.isCancelled, isFalse);

    await bloc.close();
    expect(cancel?.isCancelled, isTrue);
  });
}
