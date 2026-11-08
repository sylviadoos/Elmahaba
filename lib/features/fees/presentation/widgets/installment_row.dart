import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_installment_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/installment_status.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';

/// An installment to tick for paying now. Only one the school says can be
/// paid can be ticked; a paid one shows ticked in grey, the others locked.
class InstallmentRow extends StatelessWidget {
  const InstallmentRow({
    super.key,
    required this.installment,
    required this.isPicked,
    required this.onPickedChanged,
  });

  final FeeInstallmentEntity installment;

  /// Whether it's ticked to pay now.
  final bool isPicked;
  final ValueChanged<bool> onPickedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final canPick = installment.canPay;
    final isPaid = installment.status == InstallmentStatus.paid;
    final ticked = isPaid || (canPick && isPicked);
    final highlighted = canPick && isPicked;
    final dueDate = installment.dueDate;
    final due = dueDate == null
        ? '—'
        : DateFormat(
            'yyyy-MM-dd',
            Localizations.localeOf(context).toString(),
          ).format(dueDate);
    final amount = installment.amount;
    final bankAccount = installment.bankAccount;
    final (
      statusLabel,
      statusColor,
      statusBackground,
    ) = switch (installment.status) {
      InstallmentStatus.paid => (
        l10n.paid,
        AppColors.success,
        AppColors.successBg,
      ),
      InstallmentStatus.overdue => (
        l10n.overdue,
        AppColors.error,
        AppColors.blush,
      ),
      InstallmentStatus.upcoming => (
        l10n.upcoming,
        AppColors.slate,
        AppColors.hairline,
      ),
      InstallmentStatus.processing => (
        l10n.paymentInProgress,
        AppColors.info,
        AppColors.infoBg,
      ),
      InstallmentStatus.underSettlement => (
        l10n.underSettlement,
        AppColors.settlement,
        AppColors.settlementBg,
      ),
      // The school's words for it.
      InstallmentStatus.unknown => (
        installment.statusLabel.isEmpty ? '—' : installment.statusLabel,
        AppColors.slate,
        AppColors.hairline,
      ),
    };

    return Material(
      color: highlighted ? AppColors.blushPale : AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: highlighted ? AppColors.actionRed : AppColors.line,
        ),
      ),
      child: InkWell(
        onTap: canPick ? () => onPickedChanged(!isPicked) : null,
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12.w,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: SizedBox.square(
                  dimension: 20.r,
                  child: Checkbox(
                    value: ticked,
                    onChanged: canPick
                        ? (value) => onPickedChanged(value ?? false)
                        : null,
                    // Paid: ticked in grey, it's done.
                    fillColor: isPaid
                        ? const WidgetStatePropertyAll(AppColors.mist)
                        : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 3.h,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 8.w,
                      children: [
                        // The school's words: right to left when Arabic.
                        Flexible(
                          child: Text(
                            installment.feeName,
                            textDirection: installment.feeName.textDirection,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          amount == null ? '—' : context.money(amount),
                          style: textTheme.titleLarge?.copyWith(
                            fontSize: 15.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      installment.label,
                      textDirection: installment.label.textDirection,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      l10n.dueOnAccount(
                        due,
                        (bankAccount.isEmpty ? '—' : bankAccount).ltrIsolated,
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 2.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 2.h,
                      ),
                      decoration: ShapeDecoration(
                        color: statusBackground,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        statusLabel,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
