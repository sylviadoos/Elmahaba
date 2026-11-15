import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:al_mahhaba_school/config/di/injectable_config.dart';
import 'package:al_mahhaba_school/config/l10n/translations/app_localizations.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/pages/pay_fees_page.dart';
import 'package:al_mahhaba_school/features/fees/presentation/view_model/pay_fees_view_model.dart';

import '../../../../helpers/test_app.dart';
import '../../fees_fixtures.dart';
import 'pay_fees_page_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PayFeesViewModel>()])
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  late MockPayFeesViewModel viewModel;

  setUp(() {
    viewModel = MockPayFeesViewModel();
    when(viewModel.state).thenReturn(const BaseState.initial());
    when(viewModel.stream).thenAnswer((_) => const Stream.empty());
    getIt.registerFactory<PayFeesViewModel>(() => viewModel);
  });

  tearDown(getIt.reset);

  Future<void> pumpPage(WidgetTester tester, FeeStatementEntity shown) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => PayFeesPage(statement: shown),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    await tester.pumpAndSettle();
  }

  /// Ticks only the bus installment, leaving the education one out.
  Future<void> tickTheBusOnly(WidgetTester tester) async {
    await tester.tap(find.text(l10n.payInInstallments));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الباص').first);
    await tester.pumpAndSettle();
  }

  testWidgets("out of order: the school's own sentence, not the app's", (
    tester,
  ) async {
    await pumpPage(tester, statement());

    await tickTheBusOnly(tester);

    expect(find.text(busReason), findsOneWidget);
    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsNothing);
  });

  testWidgets('the school sends no sentence: the app says it plainly', (
    tester,
  ) async {
    await pumpPage(tester, statement(reason: ''));

    await tickTheBusOnly(tester);

    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsOneWidget);
  });

  testWidgets('nothing out of order: no sentence at all', (tester) async {
    await pumpPage(tester, statement());

    expect(find.text(busReason), findsNothing);
    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsNothing);
  });
}
