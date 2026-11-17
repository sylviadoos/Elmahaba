import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_bloc.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_filter_chip.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/results_skeleton.dart';

import '../../../../helpers/fake_pushes.dart';
import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// When Results asks the school again: coming back to the tab, the app
/// coming back to the front, a notification, pulling down — and what it
/// shows meanwhile.
void main() {
  late MockGetResultsUseCase getResults;
  late MockMarkLatestResultReadUseCase markLatestRead;
  late MockChildrenViewModel childrenViewModel;
  late MockChatUnreadBloc chatUnreadBloc;
  late FakePushes pushes;
  late GoRouter router;
  late StreamController<ChildrenState> children;

  setUpAll(() {
    provideResultDummy<List<ResultDetailsEntity>>();
    provideResultDummy<void>();
  });

  setUp(() {
    getResults = MockGetResultsUseCase();
    markLatestRead = MockMarkLatestResultReadUseCase();
    childrenViewModel = MockChildrenViewModel();
    chatUnreadBloc = MockChatUnreadBloc();
    children = StreamController<ChildrenState>.broadcast();
    addTearDown(children.close);
    getIt.registerFactory<ResultsViewModel>(
      () => ResultsViewModel(getResults, markLatestRead),
    );
    pushes = useFakePushes();
    addTearDown(pushes.close);
    when(
      markLatestRead(any),
    ).thenAnswer((_) async => const Success(data: null));
    when(
      childrenViewModel.state,
    ).thenReturn(const ChildrenState(children: BaseState.success([omar])));
    when(childrenViewModel.stream).thenAnswer((_) => children.stream);
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(getIt.reset);

  /// Opens Results for [omar], with `/over` to open on top of it.
  Future<void> pump(
    WidgetTester tester, [
    Result<List<ResultDetailsEntity>> results = const Success(data: []),
  ]) async {
    tester.usePhoneScreen();
    when(getResults(any)).thenAnswer((_) async => results);
    router = GoRouter(
      initialLocation: AppRoutes.results,
      routes: [
        GoRoute(
          path: AppRoutes.results,
          builder: (_, _) => const ResultsPage(),
        ),
        GoRoute(path: '/over', builder: (_, _) => const Text('over')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider<ChatUnreadBloc>.value(value: chatUnreadBloc),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  void answerWith(List<ResultDetailsEntity> results) =>
      when(getResults(any)).thenAnswer((_) async => Success(data: results));

  group('opening it', () {
    testWidgets('the results load on their own, the skeleton first', (
      tester,
    ) async {
      tester.usePhoneScreen();
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(any)).thenAnswer((_) => pending.future);
      router = GoRouter(
        initialLocation: AppRoutes.results,
        routes: [
          GoRoute(
            path: AppRoutes.results,
            builder: (_, _) => const ResultsPage(),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        TestApp(
          router: router,
          providers: [
            BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
            BlocProvider<ChatUnreadBloc>.value(value: chatUnreadBloc),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(ResultsSkeleton), findsOneWidget);

      pending.complete(Success(data: allResults));
      await tester.pump();
      await tester.pump();

      expect(find.byType(ResultsSkeleton), findsNothing);
      expect(find.text(november.title), findsOneWidget);
      verify(getResults(146)).called(1);
    });

    testWidgets('no results yet: it says so, with no filter and no error', (
      tester,
    ) async {
      await pump(tester);

      expect(find.text(en.noResultsYet), findsOneWidget);
      expect(find.text(en.tryAgain), findsNothing);
    });
  });

  group('asked again while it stays open', () {
    testWidgets('the app comes back to the front: asked again', (tester) async {
      await pump(tester, Success(data: [october, firstTerm]));
      expect(find.text(november.title), findsNothing);

      answerWith(allResults);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();

      expect(find.text(november.title), findsOneWidget);
      verify(getResults(146)).called(2);
    });

    testWidgets('back from a page opened over it: asked again, once', (
      tester,
    ) async {
      await pump(tester, Success(data: [october, firstTerm]));

      unawaited(router.push('/over'));
      await tester.pumpAndSettle();
      // Hidden: nothing is asked.
      verify(getResults(146)).called(1);

      answerWith(allResults);
      router.pop();
      await tester.pumpAndSettle();

      expect(find.text(november.title), findsOneWidget);
      verify(getResults(146)).called(1);
    });

    testWidgets('a notification while it is hidden waits until it shows', (
      tester,
    ) async {
      await pump(tester, Success(data: [october, firstTerm]));
      unawaited(router.push('/over'));
      await tester.pumpAndSettle();

      answerWith(allResults);
      pushes.arrive(const {'type': 'result'});
      await tester.pump();
      // Still hidden: nothing asked beyond the first load.
      verify(getResults(146)).called(1);

      router.pop();
      await tester.pumpAndSettle();

      expect(find.text(november.title), findsOneWidget);
    });

    testWidgets('a push about something else (a chat message) asks for the '
        'results again too', (tester) async {
      await pump(tester, Success(data: allResults));
      verify(getResults(146)).called(1);

      pushes.arrive(const {'type': 'message'});
      await tester.pump();
      await tester.pump();

      // Recorded as it behaves today: `PageRefresher` doesn't look at the
      // push's type, so every push costs Results two requests.
      verify(getResults(146)).called(1);
    });

    testWidgets('the old results stay on screen while it asks again', (
      tester,
    ) async {
      await pump(tester, Success(data: [october, firstTerm]));
      final pending = Completer<Result<List<ResultDetailsEntity>>>();
      when(getResults(any)).thenAnswer((_) => pending.future);

      pushes.arrive(const {'type': 'result'});
      await tester.pump();

      // No skeleton, and October is still there.
      expect(find.byType(ResultsSkeleton), findsNothing);
      expect(find.text(october.title), findsOneWidget);

      pending.complete(Success(data: allResults));
      await tester.pump();
      await tester.pump();
      expect(find.text(november.title), findsOneWidget);
    });
  });

  group('a result the school published with nothing recorded on it yet', () {
    // `"data": []` is how an empty map is written: the result exists, but
    // no marks are in.
    final blank = ResultDetailsModel.fromJson({
      'result_id': 999,
      'result_type': 'monthly',
      'title': 'نتيجة شهر ديسمبر',
      'academic_year': '2026-2027',
      'period': {
        'month': 12,
        'month_name': 'December',
        'month_name_ar': 'ديسمبر',
        'year': 2026,
      },
      'published_at': '2026-12-20T10:00:00+00:00',
      'data': const <dynamic>[],
    });

    testWidgets('on its own: it shows, with a dash instead of a mark, and '
        'no subjects and no certificate', (tester) async {
      await pump(tester, Success(data: [blank]));

      // Not an error page and not the empty page.
      expect(find.text(en.tryAgain), findsNothing);
      expect(find.text(en.noResultsYet), findsNothing);
      // Its own card, with no mark yet.
      expect(find.text(blank.title), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      // Nothing to list and nothing to save.
      expect(find.text(en.subjects), findsNothing);
      expect(find.text(en.otherSubjects), findsNothing);
      expect(find.text(en.downloadCertificate), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('beside the months that do have marks: all of them show, '
        'and the marked ones keep their certificate', (tester) async {
      await pump(tester, Success(data: [blank, ...allResults]));

      // Every one of them is in the filter, December last in school order.
      final labels = tester
          .widgetList<ResultFilterChip>(find.byType(ResultFilterChip))
          .map((chip) => chip.label);
      expect(labels, ['October', firstTerm.title, 'November', 'December']);

      // December is the newest, so it shows first — with nothing on it,
      // and no subjects of its own.
      expect(find.text(blank.title), findsOneWidget);
      expect(find.text(en.subjects), findsNothing);
      // The certificate is the whole year's, and October and November are
      // on it: still worth saving, with December's column empty.
      expect(find.text(en.downloadCertificate), findsOneWidget);

      // November still has its marks and its certificate.
      await tester.ensureVisible(find.text('November'));
      await tester.tap(find.text('November'));
      await tester.pump();

      expect(find.text(november.title), findsOneWidget);
      expect(find.text('Arabic'), findsWidgets);
      expect(find.text(en.downloadCertificate), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the children list', () {
    testWidgets('refreshed with the same child selected: not loaded again', (
      tester,
    ) async {
      await pump(tester, Success(data: allResults));
      verify(getResults(146)).called(1);

      // The list comes back from the API as a new list of the same child.
      when(
        childrenViewModel.state,
      ).thenReturn(const ChildrenState(children: BaseState.success([omar])));
      children.add(const ChildrenState(children: BaseState.success([omar])));
      await tester.pump();
      await tester.pump();

      verifyNever(getResults(any));
    });

    testWidgets('another child picked: theirs load, the newest first', (
      tester,
    ) async {
      await pump(tester, Success(data: allResults));
      const sara = ChildEntity(
        studentId: 147,
        name: 'Sara Ahmed',
        nameAr: 'سارة أحمد',
        nationalId: '••••9911',
        relationship: 'father',
        access: 'active',
        grade: 'Second Primary',
        className: 'B',
        academicYear: '2026/2027',
      );
      when(getResults(147)).thenAnswer((_) async => Success(data: [firstTerm]));
      const withSara = ChildrenState(
        children: BaseState.success([omar, sara]),
        selectedId: 147,
      );
      when(childrenViewModel.state).thenReturn(withSara);

      children.add(withSara);
      await tester.pump();
      await tester.pump();

      verify(getResults(147)).called(1);
      expect(find.text(firstTerm.title), findsWidgets);
    });
  });

  group('when it fails', () {
    testWidgets('no internet: the message and "Try again", not "Log in"', (
      tester,
    ) async {
      await pump(tester, const Failure(exception: NetworkException()));

      expect(find.text(en.noInternet), findsOneWidget);
      expect(find.text(en.tryAgain), findsOneWidget);
      expect(find.text(en.login), findsNothing);
    });

    testWidgets('the session ended: "Log in", since trying again can\'t help', (
      tester,
    ) async {
      await pump(tester, const Failure(exception: UnauthorizedException()));

      expect(find.text(en.login), findsOneWidget);
      expect(find.text(en.tryAgain), findsNothing);
    });

    testWidgets('a 500: the school\'s message, with "Try again"', (
      tester,
    ) async {
      await pump(
        tester,
        const Failure(
          exception: ServerException(statusCode: 500, message: 'Server Error'),
        ),
      );

      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text(en.tryAgain), findsOneWidget);
    });

    testWidgets('a notification after it failed: it loads and the error goes', (
      tester,
    ) async {
      await pump(tester, const Failure(exception: NetworkException()));
      expect(find.text(en.tryAgain), findsOneWidget);

      answerWith(allResults);
      pushes.arrive(const {'type': 'result'});
      await tester.pump();
      await tester.pump();

      expect(find.text(en.tryAgain), findsNothing);
      expect(find.text(november.title), findsOneWidget);
    });
  });
}
