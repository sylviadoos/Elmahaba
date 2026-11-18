import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/announcement_args.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/pages/announcement_page.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../announcements_fixtures.dart';
import '../../announcements_mocks.mocks.dart';

void main() {
  late MockGetAnnouncementsUseCase getAnnouncements;
  late MockMarkChatReadUseCase markRead;

  setUpAll(() {
    provideResultDummy<AnnouncementsPageEntity>();
    provideResultDummy<int>();
    provideResultDummy<String>();
  });

  setUp(() {
    getAnnouncements = MockGetAnnouncementsUseCase();
    markRead = MockMarkChatReadUseCase();
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
  });
  tearDown(getIt.reset);

  /// The page of [announcement], opened for [studentId] as Home and the
  /// chat open it.
  Future<void> pump(
    WidgetTester tester,
    AnnouncementEntity announcement, {
    int? studentId = 1208,
  }) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => AnnouncementPage(
            args: AnnouncementArgs(announcement, studentId: studentId),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();
  }

  testWidgets('the announcement the parent tapped, whole', (tester) async {
    await pump(tester, meeting);

    expect(find.byType(AnnouncementCard), findsOneWidget);
    expect(find.text(meeting.title), findsOneWidget);
    expect(find.text(meeting.body), findsOneWidget);
    // Its file is there to open, as it is in the list.
    expect(find.text(agendaFile.fileName), findsOneWidget);
  });

  testWidgets('nothing is asked of the school to show it', (tester) async {
    await pump(tester, meeting);

    verifyNever(
      getAnnouncements(any, page: anyNamed('page'), cancel: anyNamed('cancel')),
    );
  });

  testWidgets('opened is seen: it is marked read for its child', (
    tester,
  ) async {
    await pump(tester, meeting);
    // The bloc gathers what was seen before telling the school.
    await tester.pump(const Duration(milliseconds: 500));

    verify(markRead(['event:40'], studentId: 1208)).called(1);
  });

  testWidgets('one that was read already is not marked again', (tester) async {
    await pump(tester, sportsDay);
    await tester.pump(const Duration(milliseconds: 500));

    verifyNever(markRead(any, studentId: anyNamed('studentId')));
  });
}
