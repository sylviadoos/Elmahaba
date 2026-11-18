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

  const bus = ValueKey('8473|قسط اول|2026-10-01');
  const education = ValueKey(firstEducation);

  Future<void> payInInstallments(WidgetTester tester) async {
    await tester.tap(find.text(l10n.payInInstallments));
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Key row) async {
    await tester.ensureVisible(find.byKey(row));
    await tester.tap(find.byKey(row));
    await tester.pumpAndSettle();
  }

  bool ticked(WidgetTester tester, Key row) => tester
      .widget<Checkbox>(
        find.descendant(of: find.byKey(row), matching: find.byType(Checkbox)),
      )
      .value!;

  /// The toast gone, so no timer is left running.
  Future<void> letTheToastGo(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets("before the education one: the bus can't be ticked, the "
      "school's sentence says why", (tester) async {
    await pumpPage(tester, statement());
    await payInInstallments(tester);

    await tap(tester, bus);

    expect(ticked(tester, bus), isFalse);
    expect(find.text(busReason), findsOneWidget);
    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsNothing);
    await letTheToastGo(tester);
  });

  testWidgets('the school sends no sentence: the app says it plainly', (
    tester,
  ) async {
    await pumpPage(tester, statement(reason: ''));
    await payInInstallments(tester);

    await tap(tester, bus);

    expect(ticked(tester, bus), isFalse);
    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsOneWidget);
    await letTheToastGo(tester);
  });

  testWidgets('the education one ticked: the bus can be; unticked, the bus '
      'goes too', (tester) async {
    await pumpPage(tester, statement());
    await payInInstallments(tester);

    await tap(tester, education);
    await tap(tester, bus);
    expect(ticked(tester, bus), isTrue);
    expect(find.text(busReason), findsNothing);

    await tap(tester, education);
    expect(ticked(tester, education), isFalse);
    expect(ticked(tester, bus), isFalse);
  });

  group('Preview and Download PDF', () {
    bool enabled(WidgetTester tester, String label) =>
        tester
            .widget<OutlinedButton>(
              find.ancestor(
                of: find.text(label),
                matching: find.byType(OutlinedButton),
              ),
            )
            .onPressed !=
        null;

    testWidgets('in full, with an installment that can\'t be paid yet before '
        'another: the whole statement still opens', (tester) async {
      await pumpPage(tester, statement(educationPayable: false));

      expect(enabled(tester, l10n.preview), isTrue);
      expect(enabled(tester, l10n.downloadPdf), isTrue);
    });

    testWidgets('in installments, ticked out of order: off until in order', (
      tester,
    ) async {
      await pumpPage(tester, statement());
      await payInInstallments(tester);
      // Nothing ticked: nothing to show.
      expect(enabled(tester, l10n.preview), isFalse);

      await tap(tester, education);

      expect(enabled(tester, l10n.preview), isTrue);
      expect(enabled(tester, l10n.downloadPdf), isTrue);
    });
  });

  testWidgets('nothing out of order: no sentence at all', (tester) async {
    await pumpPage(tester, statement());

    expect(find.text(busReason), findsNothing);
    expect(find.text(l10n.tickEarlierInstallmentsFirst), findsNothing);
  });
}
