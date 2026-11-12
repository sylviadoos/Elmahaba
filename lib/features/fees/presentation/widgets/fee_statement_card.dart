import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';
import 'package:al_mahhaba_school/features/fees/presentation/statement_labels.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/fee_item_row.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_card.dart';
import 'package:al_mahhaba_school/features/fees/presentation/widgets/statement_total_row.dart';

/// The year's fees, mandatory then optional, and the totals. The optional
/// ones the parent may choose have a box to add them or drop them.
class FeeStatementCard extends StatelessWidget {
  const FeeStatementCard({
    super.key,
    required this.statement,
    this.onChangeOptional,
    this.changingFeeId,
  });

  final FeeStatementEntity statement;

  /// Called with the fee and whether it should be on the statement. null
  /// shows them all without boxes.
  final void Function(FeeEntity fee, bool add)? onChangeOptional;

  /// The fee the school is adding or dropping now, by its id.
  final int? changingFeeId;

  /// Whether this fee is the parent's to add or drop: the school allows
  /// it on this account, the fee has an id to name it by, and it's either
  /// on offer or one they added and nothing is paid on.
  bool _canChange(FeeEntity fee) =>
      onChangeOptional != null &&
      statement.canChangeOptionalFees &&
      fee.id != null &&
      (fee.isOptional || fee.canDelete);

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
                for (final fee in fees)
                  // A line added up from several fees has no id.
                  FeeItemRow(
                    key: ValueKey(fee.id ?? fee.name),
                    fee: fee,
                    onSubscribedChanged: _canChange(fee)
                        ? (add) => onChangeOptional!(fee, add)
                        : null,
                    isChanging: fee.id != null && fee.id == changingFeeId,
                  ),
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
