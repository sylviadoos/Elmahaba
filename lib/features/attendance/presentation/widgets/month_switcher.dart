import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_button.dart';

/// "October 2026" between the previous and next month arrows. [onNext] is
/// null on the latest month.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MonthButton(
          icon: AppIcons.chevronLeft,
          tooltip: l10n.previousMonth,
          onPressed: onPrevious,
        ),
        Text(
          DateFormat.yMMMM(
            Localizations.localeOf(context).toString(),
          ).format(month),
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: 16.sp,
            height: 1.3,
          ),
        ),
        MonthButton(
          icon: AppIcons.chevronRight,
          tooltip: l10n.nextMonth,
          onPressed: onNext,
        ),
      ],
    );
  }
}
