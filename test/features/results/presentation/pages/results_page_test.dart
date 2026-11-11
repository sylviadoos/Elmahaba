import 'dart:convert';

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
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_state.dart';
import 'package:al_mahhaba_school/features/children/presentation/view_model/children_view_model.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_bloc.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/use_cases/get_latest_result_use_case.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_bloc.dart';
import 'package:al_mahhaba_school/features/results/presentation/pages/results_page.dart';
import 'package:al_mahhaba_school/features/results/presentation/view_model/results_view_model.dart';

import '../../../../helpers/fake_file_picker.dart';
import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../../auth/auth_mocks.mocks.dart';
import '../../../complaints/complaints_mocks.mocks.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));

/// The latest result, and not one of the months.
const _termResult = ResultDetailsEntity(
  id: 280,
  title: 'First term result',
  academicYear: '2026-2027',
  resultType: 'value',
  studentName: 'Omar Ahmed',
  subjectsIncluded: [],
  subjectsNotIncluded: [],
  highLevel: [],
  activities: [],
);

void main() {
  late MockGetLatestResultUseCase getLatest;
  late MockGetMonthlyResultsUseCase getMonthly;
  late MockChildrenViewModel childrenViewModel;
  late MockChatUnreadBloc chatUnreadBloc;
  late MockMarkChatReadUseCase markRead;

  setUpAll(() {
    provideResultDummy<LatestResult?>();
    provideResultDummy<MonthlyResultsEntity>();
  });

  setUp(() {
    getLatest = MockGetLatestResultUseCase();
    getMonthly = MockGetMonthlyResultsUseCase();
    markRead = MockMarkChatReadUseCase();
    childrenViewModel = MockChildrenViewModel();
    chatUnreadBloc = MockChatUnreadBloc();
    getIt
      ..registerFactory<ResultsViewModel>(
        () => ResultsViewModel(getLatest, markRead),
      )
      ..registerFactory<MonthlyResultsBloc>(
        () => MonthlyResultsBloc(getMonthly),
      );
    when(
      childrenViewModel.state,
    ).thenReturn(const ChildrenState(children: BaseState.success([omar])));
    when(childrenViewModel.stream).thenAnswer((_) => const Stream.empty());
    when(chatUnreadBloc.stream).thenAnswer((_) => const Stream.empty());
    when(getLatest(any)).thenAnswer(
      (_) async => const Success(
        data: (details: _termResult, isRead: true, chatKey: null),
      ),
    );
  });
  tearDown(getIt.reset);

  /// Opens Results for [omar], the months answering [monthlyResults].
  Future<void> pump(
    WidgetTester tester,
    Result<MonthlyResultsEntity> monthlyResults,
  ) async {
    tester.usePhoneScreen();
    when(getMonthly(any)).thenAnswer((_) async => monthlyResults);
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const ResultsPage())],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      TestApp(
        router: router,
        providers: [
          BlocProvider<ChildrenViewModel>.value(value: childrenViewModel),
          BlocProvider<ChatUnreadBloc>.value(value: chatUnreadBloc),
          // The header's complaints button: no dot.
          BlocProvider<ComplaintUpdatesBloc>(
            create: (_) => ComplaintUpdatesBloc(
              MockHasNewComplaintUpdatesUseCase(),
              MockMarkComplaintsSeenUseCase(),
            ),
          ),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('no months published: the latest result, and the certificate '
      'to download all the same', (tester) async {
    await pump(tester, const Success(data: MonthlyResultsEntity()));

    expect(find.text('First term result'), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsOneWidget);
  });

  testWidgets('the months didn\'t load: the certificate all the same', (
    tester,
  ) async {
    await pump(tester, const Failure(exception: NetworkException()));

    expect(find.text('First term result'), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsOneWidget);
  });

  testWidgets('no months: the certificate has the child on it', (tester) async {
    final dialog = useFakeFilePicker();
    await pump(tester, const Success(data: MonthlyResultsEntity()));

    await tester.ensureVisible(find.text(en.downloadCertificate));
    await tester.tap(find.text(en.downloadCertificate));
    await tester.pumpAndSettle();

    // The child's year, "2026/2027".
    expect(dialog.fileName, 'monthly-certificate-2026-2027.pdf');
    expect(ascii.decode(dialog.bytes!.sublist(0, 5)), '%PDF-');
    expect(find.text(en.certificateSaved), findsOneWidget);
  });

  testWidgets('months too: the latest result\'s tab has it as well', (
    tester,
  ) async {
    await pump(tester, Success(data: monthly));

    // The months first: published after.
    expect(find.text(en.downloadCertificate), findsOneWidget);
    await tester.tap(find.text(en.latestResult));
    await tester.pump();

    expect(find.text('First term result'), findsOneWidget);
    expect(find.text(en.downloadCertificate), findsOneWidget);
  });
}
