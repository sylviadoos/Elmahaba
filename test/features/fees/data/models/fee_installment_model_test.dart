import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/fees/data/models/fee_installment_model.dart';

/// A locked installment, as the school sends it: payable, but only with
/// the earlier ones, and with its own words for why.
Map<String, dynamic> locked({
  bool isLocked = true,
  String? reason = 'اختر أقساط التعليم السابقة أولاً',
}) => {
  'pay_key': '8472|قسط ثانى|2026-10-01',
  'fee_type': 'الباص',
  'installment': 'قسط ثانى',
  'due_date': '2026-10-01',
  'bank_account': '••••••••/446',
  'amount': 5000,
  'status': 'UNPAID',
  'status_label': 'متأخر',
  'can_pay': true,
  'locked': isLocked,
  'locked_reason': ?reason,
  'requires': ['8472|قسط اول|2026-08-16'],
};

void main() {
  test("the school's own words for why it can't be paid alone", () {
    final installment = FeeInstallmentModel.fromJson(locked());

    expect(installment.lockedReason, 'اختر أقساط التعليم السابقة أولاً');
    expect(installment.requires, ['8472|قسط اول|2026-08-16']);
    expect(installment.canPay, isTrue);
  });

  test('the school sends no reason: none to show', () {
    final installment = FeeInstallmentModel.fromJson(locked(reason: null));

    expect(installment.lockedReason, isEmpty);
  });

  test('not locked: nothing is in its way, whatever else is sent', () {
    final installment = FeeInstallmentModel.fromJson(locked(isLocked: false));

    expect(installment.lockedReason, isEmpty);
    expect(installment.requires, isEmpty);
  });

  test('ticked with the one it needs, it is in order', () {
    final installment = FeeInstallmentModel.fromJson(locked());

    expect(installment.isInOrderWith({installment.payKey}), isFalse);
    expect(
      installment.isInOrderWith({
        installment.payKey,
        '8472|قسط اول|2026-08-16',
      }),
      isTrue,
    );
  });
}
