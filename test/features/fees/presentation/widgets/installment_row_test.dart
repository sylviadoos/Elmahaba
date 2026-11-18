import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/installment_row.dart';

import '../../../../helpers/test_app.dart';

FeeInstallmentEntity installment({
  required InstallmentStatus status,
  required bool canPay,
  double? amount = 5000,
}) => FeeInstallmentEntity(
  feeName: 'رسوم كتب',
  label: 'قسط ثاني',
  dueDate: DateTime(2027, 2),
  bankAccount: '••••••••/447',
  amount: amount,
  status: status,
  statusLabel: '',
  canPay: canPay,
  payKey: '8472|قسط ثاني|2027-02-01',
);

void main() {
  late List<bool> picks;

  setUp(() => picks = []);

  Future<void> pump(
    WidgetTester tester,
    FeeInstallmentEntity installment, {
    String? waitingReason,
  }) {
    tester.usePhoneScreen();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: InstallmentRow(
              installment: installment,
              isPicked: false,
              onPickedChanged: picks.add,
              waitingReason: waitingReason,
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    return tester.pumpWidget(TestApp(router: router));
  }

  Color background(WidgetTester tester) => tester
      .widget<Material>(
        find
            .descendant(
              of: find.byType(InstallmentRow),
              matching: find.byType(Material),
            )
            .first,
      )
      .color!;

  testWidgets('one to pay: white, and a tap ticks it', (tester) async {
    await pump(
      tester,
      installment(status: InstallmentStatus.upcoming, canPay: true),
    );

    expect(background(tester), AppColors.white);
    await tester.tap(find.byType(InstallmentRow));
    expect(picks, [true]);
  });

  testWidgets('under settlement: greyed out, the box faded, no tick', (
    tester,
  ) async {
    await pump(
      tester,
      installment(
        status: InstallmentStatus.underSettlement,
        canPay: false,
        amount: null,
      ),
    );

    expect(background(tester), AppColors.surface);
    final box = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(box.onChanged, isNull);
    expect(box.fillColor?.resolve({}), AppColors.line);
    expect(box.side?.color, AppColors.unmet);
    await tester.tap(find.byType(InstallmentRow));
    expect(picks, isEmpty);
  });

  testWidgets('waiting for earlier ones: greyed out, a tap says why', (
    tester,
  ) async {
    await pump(
      tester,
      installment(status: InstallmentStatus.upcoming, canPay: true),
      waitingReason: 'Tick the first installment first.',
    );

    expect(background(tester), AppColors.surface);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    await tester.tap(find.byType(InstallmentRow));
    await tester.pumpAndSettle();
    expect(picks, isEmpty);
    expect(find.text('Tick the first installment first.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('paid: ticked in grey, not greyed out', (tester) async {
    await pump(
      tester,
      installment(status: InstallmentStatus.paid, canPay: false),
    );

    expect(background(tester), AppColors.white);
    final box = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(box.value, isTrue);
    expect(box.fillColor?.resolve({}), AppColors.mist);
  });
}
