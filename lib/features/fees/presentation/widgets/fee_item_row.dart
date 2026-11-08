import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';

/// A fee on the statement: its name, the account to pay into and the
/// amount. An optional one has a box, ticked while subscribed. A paid one
/// is marked in grey instead of red.
class FeeItemRow extends StatelessWidget {
  const FeeItemRow({super.key, required this.fee, this.onSubscribedChanged});

  final FeeEntity fee;

  /// null shows the box without letting it change.
  final ValueChanged<bool>? onSubscribedChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final onSubscribedChanged = this.onSubscribedChanged;
    final mark = fee.isPaid ? AppColors.mist : AppColors.actionRed;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 12.w, 12.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: BorderDirectional(
            start: BorderSide(color: mark, width: 4.w),
          ),
        ),
        child: Row(
          spacing: 10.w,
          children: [
            if (fee.isOptional)
              SizedBox.square(
                dimension: 20.r,
                child: Checkbox(
                  value: fee.isSubscribed ?? false,
                  onChanged: onSubscribedChanged == null
                      ? null
                      : (value) => onSubscribedChanged(value ?? false),
                  fillColor: fee.isPaid
                      ? WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? AppColors.mist
                              : Colors.transparent,
                        )
                      : null,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2.h,
                children: [
                  // The school's words: right to left when Arabic.
                  Text(
                    fee.name,
                    textDirection: fee.name.textDirection,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (fee.bankAccount.isNotEmpty)
                    Text(
                      context.l10n.accountNumber(fee.bankAccount.ltrIsolated),
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.slate,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              context.money(fee.amount),
              style: textTheme.titleLarge?.copyWith(
                fontSize: 16.sp,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: AppColors.mahabbahRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
