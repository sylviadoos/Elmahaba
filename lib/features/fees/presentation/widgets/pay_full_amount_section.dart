import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/statement_labels.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/pay_total_tile.dart';

/// Paying in full: the total, what's paid and what's left, and how to pay
/// it (in both languages).
class PayFullAmountSection extends StatelessWidget {
  const PayFullAmountSection({
    super.key,
    required this.total,
    required this.paid,
    required this.remaining,
  });

  final double total;
  final double paid;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final note = context.textTheme.bodySmall?.copyWith(
      fontSize: 13.sp,
      color: AppColors.slate,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        PayTotalTile(
          label: StatementLabels.totalAmount,
          value: context.money(total),
          color: AppColors.ink,
          background: AppColors.surface,
        ),
        PayTotalTile(
          label: StatementLabels.paidAmount,
          value: context.money(paid),
          color: AppColors.success,
          background: AppColors.successBg,
        ),
        PayTotalTile(
          label: StatementLabels.remainingBalance,
          value: context.money(remaining),
          color: AppColors.mahabbahRed,
          background: AppColors.blush,
        ),
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Text(
            StatementLabels.payFullNote.$1,
            textDirection: TextDirection.ltr,
            style: note?.copyWith(height: 19 / 13),
          ),
        ),
        Text(
          StatementLabels.payFullNote.$2,
          textDirection: TextDirection.rtl,
          style: note?.copyWith(height: 20 / 13),
        ),
      ],
    );
  }
}
