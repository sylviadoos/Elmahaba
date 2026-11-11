import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_bloc.dart';
import 'package:al_mahhaba_school/features/results/presentation/bloc/monthly_results_intent.dart';
import 'package:al_mahhaba_school/features/results/presentation/widgets/monthly_results_view.dart';

import '../../../../helpers/result_dummy.dart';
import '../../../../helpers/test_app.dart';
import '../../results_fixtures.dart';
import '../../results_mocks.mocks.dart';

final en = lookupAppLocalizations(const Locale('en'));
final ar = lookupAppLocalizations(const Locale('ar'));

void main() {
  setUpAll(() => provideResultDummy<MonthlyResultsEntity>());

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final getMonthly = MockGetMonthlyResultsUseCase();
    when(getMonthly(146)).thenAnswer((_) async => Success(data: monthly));
    final bloc = MonthlyResultsBloc(getMonthly)
      ..add(const ShowChildMonthlyIntent(146));
    addTearDown(bloc.close);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: BlocProvider.value(
                value: bloc,
                child: MonthlyResultsView(results: monthly),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(TestApp(router: router, locale: locale));
    await tester.pump();
  }

  testWidgets('the newest month, its rank, and the certificate to download', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('October'), findsOneWidget);
    expect(find.text('November'), findsOneWidget);
    expect(find.text('نتيجة شهر نوفمبر'), findsOneWidget);
    expect(find.text(en.classRank(2)), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    // Religion has no November marks; Math none at all.
    expect(find.text('Religion'), findsNothing);
    expect(find.text('Math'), findsNothing);
    expect(find.text(en.downloadCertificate), findsOneWidget);
  });

  testWidgets('another month: its own result', (tester) async {
    await pump(tester);

    await tester.tap(find.text('October'));
    await tester.pump();

    expect(find.text('نتيجة شهر أكتوبر'), findsOneWidget);
    expect(find.text(en.classRank(3)), findsOneWidget);
    expect(find.text('Religion'), findsOneWidget);
  });

  testWidgets('fits a small phone in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'), size: const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.text('أكتوبر'), findsOneWidget);
    expect(find.text(ar.downloadCertificate), findsOneWidget);
  });
}
