import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/installment_row.dart';

/// Paying in installments: what the ticked ones add up to, then every
/// installment. [picked] holds the `payKey`s of the ticked ones.
class PayInstallmentsSection extends StatelessWidget {
  const PayInstallmentsSection({
    super.key,
    required this.statement,
    required this.picked,
    required this.payable,
    required this.onTogglePicked,
  });

  final FeeStatementEntity statement;
  final Set<String> picked;

  /// What's left to pay of the ticked installments.
  final double payable;

  /// The installment with this `payKey` was ticked or unticked.
  final ValueChanged<String> onTogglePicked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.blush,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.rose),
          ),
          child: Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.amountPayableNow.toUpperCase(),
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.maroon,
                      ),
                    ),
                    Text(
                      l10n.tickInstallments,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                context.money(payable),
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 22.sp,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.maroon,
                ),
              ),
            ],
          ),
        ),
        for (final installment in statement.installments)
          InstallmentRow(
            key: ValueKey(installment.payKey),
            installment: installment,
            isPicked: picked.contains(installment.payKey),
            onPickedChanged: (_) => onTogglePicked(installment.payKey),
            // Locked until the earlier ones it's paid with are ticked: the
            // school's sentence naming them, or the app's.
            waitingReason:
                installment.canPay && !installment.isInOrderWith(picked)
                ? installment.lockedReason.isNotEmpty
                      ? installment.lockedReason
                      : l10n.tickEarlierInstallmentsFirst
                : null,
          ),
      ],
    );
  }
}
