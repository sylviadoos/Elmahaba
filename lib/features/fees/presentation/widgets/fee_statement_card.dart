import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/statement_labels.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/fee_item_row.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_card.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_total_row.dart';

/// The year's fees, mandatory then optional, and the totals.
class FeeStatementCard extends StatelessWidget {
  const FeeStatementCard({super.key, required this.statement});

  final FeeStatementEntity statement;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final groups = [
      (
        StatementLabels.mandatory,
        [
          for (final fee in statement.fees)
            if (!fee.isOptional) fee,
        ],
      ),
      (
        StatementLabels.optional,
        [
          for (final fee in statement.fees)
            if (fee.isOptional) fee,
        ],
      ),
    ];

    return StatementCard(
      icon: AppIcons.fileReport,
      title: StatementLabels.feeStatement,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            for (final ((title, titleAr), fees) in groups)
              if (fees.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.only(top: 6.h, bottom: 8.h),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.hairline),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2.h,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: AppColors.slate,
                        ),
                      ),
                      Text(
                        titleAr,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                // TODO: subscribe to / drop an optional fee (API), when
                // `canChangeOptionalFees`.
                for (final fee in fees)
                  // A line added up from several fees has no id.
                  FeeItemRow(key: ValueKey(fee.id ?? fee.name), fee: fee),
              ],
            Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8.h,
                children: [
                  StatementTotalRow(
                    label: StatementLabels.totalAmount,
                    value: context.money(statement.totalAmount),
                    color: AppColors.ink,
                  ),
                  StatementTotalRow(
                    label: StatementLabels.paidAmount,
                    value: context.money(statement.paidAmount),
                    color: AppColors.success,
                  ),
                  StatementTotalRow(
                    label: StatementLabels.remainingBalance,
                    value: context.money(statement.remainingBalance),
                    color: AppColors.mahabbahRed,
                    background: AppColors.blush,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
