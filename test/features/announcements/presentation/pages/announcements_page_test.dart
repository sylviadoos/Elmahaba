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
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/pages/announcements_page.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../announcements_fixtures.dart';
import '../../announcements_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

void main() {
  late MockGetAnnouncementsUseCase getAnnouncements;
  late MockMarkChatReadUseCase markRead;
  late MockChildrenViewModel childrenViewModel;
  late MockChatUnreadBloc chatUnreadBloc;

  setUpAll(() {
    provideResultDummy<AnnouncementsPageEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
  });

  setUp(() {
    getAnnouncements = MockGetAnnouncementsUseCase();
    markRead = MockMarkChatReadUseCase();
    childrenViewModel = MockChildrenViewModel();
    chatUnreadBloc = MockChatUnreadBloc();
    getIt.registerFactory<AnnouncementsBloc>(
      () => AnnouncementsBloc(
        getAnnouncements,
        markRead,
        MockDownloadChatAttachmentUseCase(),
        MockPreviewChatAttachmentUseCase(),
      ),
    );
    when(
      markRead(any, studentId: anyNamed('studentId')),
    ).thenAnswer((_) async => const Success(data: 0));
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    when(childrenViewModel.state).thenReturn(
      const ChildrenState(children: BaseState.success([omar, lina])),
    );
  });
  tearDown(getIt.reset);

  /// Every page asked for answers [result].
  void answer(Result<AnnouncementsPageEntity> result) => when(
    getAnnouncements(any, page: anyNamed('page'), cancel: anyNamed('cancel')),
  ).thenAnswer((_) async => result);

  /// Opens Announcements on a [size] phone in [locale], from Home on
  /// [studentId].
  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
    int? studentId,
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => AnnouncementsPage(studentId: studentId),
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

  testWidgets('the announcements: how many, who for, new, ended, files', (
    tester,
  ) async {
    answer(Success(data: announcementsPage([meeting, sportsDay], unread: 1)));
    await pump(tester);

    expect(find.text(en.announcements), findsOneWidget);
    expect(
      find.text('${en.announcementsCount(2)} · ${en.newCount(1)}'),
      findsOneWidget,
    );
    expect(find.byType(AnnouncementCard), findsNWidgets(2));
    expect(find.text('Parents meeting'), findsOneWidget);
    expect(find.text('Sports day'), findsOneWidget);
    expect(find.text('All parents'), findsNWidgets(2));
    // The meeting is unread; sports day has ended.
    expect(find.text(en.homeworkNew), findsOneWidget);
    expect(find.text(en.announcementEnded), findsOneWidget);
    expect(find.text('agenda.pdf'), findsNWidgets(2));
  });

  testWidgets('from Home: the child it showed', (tester) async {
    answer(Success(data: announcementsPage([meeting])));
    await pump(tester, studentId: lina.studentId);

    expect(find.text('Lina Ahmed'), findsOneWidget);
    verify(
      getAnnouncements(lina.studentId, cancel: anyNamed('cancel')),
    ).called(1);
  });

  testWidgets('an unread one on screen: marked read', (tester) async {
    answer(Success(data: announcementsPage([meeting], unread: 1)));
    await pump(tester);
    await tester.pump(const Duration(milliseconds: 500));

    verify(markRead(['event:40'], studentId: omar.studentId)).called(1);
  });

  testWidgets('none yet: says so', (tester) async {
    answer(Success(data: announcementsPage([])));
    await pump(tester);

    expect(find.text(en.noAnnouncements), findsOneWidget);
    expect(find.text(en.noAnnouncementsHint), findsOneWidget);
  });

  testWidgets('a read-only child: the school\'s reason, and Try again', (
    tester,
  ) async {
    answer(
      const Failure(
        exception: ServerException(
          statusCode: 403,
          code: 'read_only_child',
          message: 'This action is not available for this child.',
        ),
      ),
    );
    await pump(tester);

    expect(
      find.text('This action is not available for this child.'),
      findsOneWidget,
    );
    answer(Success(data: announcementsPage([meeting])));
    await tester.tap(find.text(en.tryAgain));
    await tester.pump();
    await tester.pump();
    expect(find.text('Parents meeting'), findsOneWidget);
  });

  testWidgets('fits a small phone in Arabic', (tester) async {
    answer(Success(data: announcementsPage([meeting, sportsDay], unread: 1)));
    await pump(tester, locale: const Locale('ar'), size: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.text(ar.announcements), findsOneWidget);
    expect(find.text('كل أولياء الأمور'), findsWidgets);
  });
}
