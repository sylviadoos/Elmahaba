import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/extensions/string_extensions.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_entity.dart';
import 'package:al_mahhaba_school/features/fees/presentation/extensions/money_text.dart';

/// A fee on the statement: its name, the account to pay into and the
/// amount. A paid one is marked in grey instead of red.
///
/// An optional fee the parent can add or drop has a box, ticked once it's
/// on the statement: an optional line isn't on it yet, and a mandatory one
/// the school lets go of ([FeeEntity.canDelete]) is. Without
/// [onSubscribedChanged] there's no box: the fee is simply owed.
class FeeItemRow extends StatelessWidget {
  const FeeItemRow({
    super.key,
    required this.fee,
    this.onSubscribedChanged,
    this.isChanging = false,
  });

  final FeeEntity fee;

  /// Called with whether the fee should be on the statement. null hides
  /// the box: this fee isn't the parent's to choose.
  final ValueChanged<bool>? onSubscribedChanged;

  /// The school is adding it or dropping it now: a spinner, and no second
  /// tap.
  final bool isChanging;

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
            if (onSubscribedChanged != null)
              SizedBox.square(
                dimension: 20.r,
                child: isChanging
                    ? Padding(
                        padding: EdgeInsets.all(2.r),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.actionRed,
                        ),
                      )
                    // On the statement already, unless it's still only on
                    // offer.
                    : Checkbox(
                        value: !fee.isOptional,
                        onChanged: (value) =>
                            onSubscribedChanged(value ?? false),
                        fillColor: fee.isPaid
                            ? WidgetStateProperty.resolveWith(
                                (states) =>
                                    states.contains(WidgetState.selected)
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
