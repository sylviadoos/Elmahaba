import 'dart:convert';

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
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/result_filter_chip.dart';

import '../../../../helpers/fake_file_picker.dart';
import '../../../../helpers/fake_pushes.dart';
import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

void main() {
  late MockGetResultsUseCase getResults;
  late MockMarkLatestResultReadUseCase markLatestRead;
  late MockChildrenViewModel childrenViewModel;
  late MockChatUnreadBloc chatUnreadBloc;
  late FakePushes pushes;

  setUpAll(() {
    provideResultDummy<List<ResultDetailsEntity>>();
    provideResultDummy<void>();
  });

  setUp(() {
    getResults = MockGetResultsUseCase();
    markLatestRead = MockMarkLatestResultReadUseCase();
    childrenViewModel = MockChildrenViewModel();
    chatUnreadBloc = MockChatUnreadBloc();
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
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
  });
  tearDown(getIt.reset);

  /// Opens Results for [omar], the school answering [results].
  Future<void> pump(
    WidgetTester tester,
    Result<List<ResultDetailsEntity>> results,
  ) async {
    tester.usePhoneScreen();
    when(getResults(any)).thenAnswer((_) async => results);
    final router = GoRouter(
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
    await tester.pump();
  }

  Finder chip(String label) => find.descendant(
    of: find.byType(SingleChildScrollView).at(1),
    matching: find.text(label),
  );

  group('November published while it was open', () {
    void novemberPublished() => when(
      getResults(any),
    ).thenAnswer((_) async => Success(data: allResults));

    testWidgets('the notification comes: November shows, no leaving', (
      tester,
    ) async {
      await pump(tester, Success(data: [october, firstTerm]));
      expect(find.text(november.title), findsNothing);

      novemberPublished();
      pushes.arrive(const {'type': 'result'});
      await tester.pump();
      await tester.pump();

      expect(find.text(november.title), findsOneWidget);
    });

    testWidgets('pulled down: November shows', (tester) async {
      await pump(tester, Success(data: [october, firstTerm]));

      novemberPublished();
      await tester.fling(
        find.byType(SingleChildScrollView).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text(november.title), findsOneWidget);
    });
  });

  testWidgets('the newest shows first, with every result in the filter', (
    tester,
  ) async {
    await pump(tester, Success(data: allResults));

    expect(find.text(november.title), findsOneWidget);
    // In the school year's order: months by name, the term by its title
    // (published before November).
    final labels = tester
        .widgetList<ResultFilterChip>(find.byType(ResultFilterChip))
        .map((chip) => chip.label);
    expect(labels, ['October', firstTerm.title, 'November']);
    // The newest, shown.
    expect(
      tester
          .widget<ResultFilterChip>(
            find.widgetWithText(ResultFilterChip, 'November'),
          )
          .isSelected,
      isTrue,
    );
  });

  testWidgets('a month: the certificate to download, every month on it', (
    tester,
  ) async {
    final dialog = useFakeFilePicker();
    await pump(tester, Success(data: allResults));

    await tester.ensureVisible(find.text(en.downloadCertificate));
    await tester.tap(find.text(en.downloadCertificate));
    await tester.pumpAndSettle();

    expect(dialog.fileName, 'monthly-certificate-2026-2027.pdf');
    expect(ascii.decode(dialog.bytes!.sublist(0, 5)), '%PDF-');
    expect(find.text(en.certificateSaved), findsOneWidget);
  });

  testWidgets('a term picked: its result, and no certificate', (tester) async {
    await pump(tester, Success(data: allResults));

    // The last chip: scrolled to first.
    await tester.ensureVisible(chip(firstTerm.title));
    await tester.tap(chip(firstTerm.title));
    await tester.pump();

    expect(find.text(firstTerm.title), findsWidgets);
    expect(find.text('ناجح'), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsNothing);

    // Back to a month: the certificate again.
    await tester.ensureVisible(chip('October'));
    await tester.tap(chip('October'));
    await tester.pump();

    expect(find.text(october.title), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsOneWidget);
  });

  testWidgets('only one: no filter', (tester) async {
    await pump(tester, Success(data: [firstTerm]));

    expect(find.text(firstTerm.title), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsNothing);
  });

  testWidgets('none yet: says so', (tester) async {
    await pump(tester, const Success(data: []));

    expect(find.text(en.noResultsYet), findsOneWidget);
  });

  testWidgets('can\'t be reached: says why, and "Try again" loads again', (
    tester,
  ) async {
    await pump(tester, const Failure(exception: NetworkException()));

    expect(find.text(en.tryAgain), findsOneWidget);

    when(getResults(any)).thenAnswer((_) async => Success(data: allResults));
    await tester.tap(find.text(en.tryAgain));
    await tester.pump();
    await tester.pump();

    expect(find.text(november.title), findsOneWidget);
  });
}
