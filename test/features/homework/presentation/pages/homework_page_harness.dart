import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_bloc.dart';
import 'package:al_mahhaba_school/features/homework/presentation/pages/homework_page.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../homework_fixtures.dart';
import '../../homework_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

/// A phone as the designs are drawn (390 × 844) and a small one (320 ×
/// 568, e.g. an iPhone SE), at 3x.
const Size designPhone = Size(390, 844);
const Size smallPhone = Size(320, 568);

/// Shows Homework as the app does: its [HomeworkBloc] is a real one over
/// the mocked use cases here; the parent's children and the chat badge are
/// mocks.
///
/// Create one in `setUp`, then [register]; `getIt.reset` in `tearDown`.
class HomeworkPageHarness {
  final getHomework = MockGetHomeworkUseCase();
  final markRead = MockMarkChatReadUseCase();
  final downloadAttachment = MockDownloadChatAttachmentUseCase();
  final childrenViewModel = MockChildrenViewModel();
  final chatUnreadBloc = MockChatUnreadBloc();

  /// What the page gets from getIt, and what the use cases answer unless a
  /// test says otherwise: [homeworkPage] of the fixtures, read marks fine.
  void register() {
    provideResultDummy<HomeworkPageEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
    getIt.registerFactory<HomeworkBloc>(
      () => HomeworkBloc(getHomework, markRead, downloadAttachment),
    );
    when(markRead(any)).thenAnswer((_) async => const Success(data: 0));
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    homeworkIs(homeworkPage([exercise, reading], unread: 1));
  }

  /// Every page asked for (any child, filter or subject) comes back as
  /// [page].
  void homeworkIs(HomeworkPageEntity page) =>
      when(_anyGetHomework()).thenAnswer((_) async => Success(data: page));

  /// Every page asked for fails with [exception].
  void homeworkFails(AppException exception) => when(
    _anyGetHomework(),
  ).thenAnswer((_) async => Failure(exception: exception));

  Future<Result<HomeworkPageEntity>> _anyGetHomework() => getHomework(
    any,
    filter: anyNamed('filter'),
    subjectId: anyNamed('subjectId'),
    page: anyNamed('page'),
    cancel: anyNamed('cancel'),
  );

  /// Opens Homework on a [size] phone in [locale], with the system's text
  /// [textScale]d, for the parent's [children]; [studentId] first.
  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = designPhone,
    double textScale = 1,
    List<ChildEntity> children = const [omar, lina],
    int? studentId,
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    when(
      childrenViewModel.state,
    ).thenReturn(ChildrenState(children: BaseState.success(children)));

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => HomeworkPage(studentId: studentId),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        locale: locale,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider<ChatUnreadBloc>.value(value: chatUnreadBloc),
        ],
      ),
    );
    // The first page comes, then the cards build.
    await tester.pump();
    await tester.pump();
  }
}
