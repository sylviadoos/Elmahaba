import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/fee_statement_card.dart';

import '../../../../helpers/test_app.dart';
import '../../fees_fixtures.dart';

void main() {
  late List<(FeeEntity, bool)> changes;

  setUp(() => changes = []);

  /// The statement card showing [fees], with the school allowing changes
  /// unless [canChange] says otherwise.
  Future<void> pumpCard(
    WidgetTester tester,
    List<FeeEntity> fees, {
    bool canChange = true,
    bool listening = true,
    int? changingFeeId,
  }) async {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: FeeStatementCard(
                statement: statement(
                  fees: fees,
                  canChangeOptionalFees: canChange,
                ),
                onChangeOptional: listening
                    ? (fee, add) => changes.add((fee, add))
                    : null,
                changingFeeId: changingFeeId,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(TestApp(router: router));
    // Not pumpAndSettle: the spinner never stops turning.
    await tester.pump();
    await tester.pump();
  }

  /// The boxes on screen, in order.
  List<bool?> boxes(WidgetTester tester) => [
    for (final box in tester.widgetList<Checkbox>(find.byType(Checkbox)))
      box.value,
  ];

  testWidgets('a fee on offer: an empty box the parent can tick', (
    tester,
  ) async {
    await pumpCard(tester, const [tuition, busOnOffer]);

    // Only the bus: the tuition is always owed.
    expect(boxes(tester), [false]);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(changes, [(busOnOffer, true)]);
  });

  testWidgets('one the parent added: a ticked box that drops it', (
    tester,
  ) async {
    await pumpCard(tester, const [tuition, busAdded]);

    expect(boxes(tester), [true]);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(changes, [(busAdded, false)]);
  });

  testWidgets('fees the parent has no say over: no boxes at all', (
    tester,
  ) async {
    await pumpCard(tester, const [tuition]);

    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets("the school doesn't allow changes: no boxes", (tester) async {
    await pumpCard(tester, const [tuition, busOnOffer], canChange: false);

    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('nobody listening: no boxes', (tester) async {
    await pumpCard(tester, const [tuition, busOnOffer], listening: false);

    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('while the school is changing it: a spinner, no box', (
    tester,
  ) async {
    await pumpCard(tester, const [
      tuition,
      busOnOffer,
    ], changingFeeId: busFeeId);

    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
