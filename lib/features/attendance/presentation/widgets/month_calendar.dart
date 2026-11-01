import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/constants/app_assets.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/app_svg_icon.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/features/attendance/data/mock_attendance.dart';

/// Month grid (weeks start on Sunday) with each school day colored by
/// attendance, month arrows and a legend.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({super.key, required this.month, required this.days});

  final DateTime month;

  /// Status of day 1, 2, 3… of [month].
  final List<DayStatus> days;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    // Sunday-first column of the 1st (DateTime.weekday is 1 = Monday).
    final leadingBlanks = DateTime(month.year, month.month).weekday % 7;
    final cells = <Widget>[
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (final (index, status) in days.indexed)
        _DayCell(
          label: DateFormat.d(
            locale,
          ).format(DateTime(month.year, month.month, index + 1)),
          status: status,
        ),
    ];
    // A Sunday, so the header reads Sun … Sat.
    final firstSunday = DateTime(2026, 10, 4);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12.h,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO: load the previous month.
              _MonthButton(
                icon: AppIcons.chevronLeft,
                tooltip: l10n.previousMonth,
                onPressed: () {},
              ),
              Text(
                DateFormat.yMMMM(locale).format(month),
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 16.sp,
                  height: 1.3,
                ),
              ),
              // The current month is the latest; nothing after it yet.
              _MonthButton(
                icon: AppIcons.chevronRight,
                tooltip: l10n.nextMonth,
              ),
            ],
          ),
          _WeekRow(
            children: [
              for (var i = 0; i < 7; i++)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat.E(
                      locale,
                    ).format(firstSunday.add(Duration(days: i))),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            spacing: 4.h,
            children: [
              for (var start = 0; start < cells.length; start += 7)
                _WeekRow(
                  children: [
                    for (var i = start; i < start + 7; i++)
                      i < cells.length
                          ? SizedBox(height: 38.h, child: cells[i])
                          : const SizedBox.shrink(),
                  ],
                ),
            ],
          ),
          const _Legend(),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4.w,
      children: [for (final child in children) Expanded(child: child)],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.label, required this.status});

  final String label;
  final DayStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, color, weight) = switch (status) {
      DayStatus.present => (
        AppColors.blush,
        AppColors.mahabbahRed,
        FontWeight.w600,
      ),
      DayStatus.absent => (
        AppColors.mahabbahRed,
        AppColors.white,
        FontWeight.w700,
      ),
      DayStatus.late => (null, AppColors.mahabbahRed, FontWeight.w600),
      DayStatus.holiday => (
        AppColors.gold,
        AppColors.goldText,
        FontWeight.w700,
      ),
      DayStatus.off => (null, AppColors.mist, FontWeight.w400),
      DayStatus.future => (null, AppColors.slate, FontWeight.w400),
    };
    final radius = 10.r;

    final cell = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        label,
        style: context.textTheme.bodyMedium?.copyWith(
          height: 1,
          fontWeight: weight,
          color: color,
        ),
      ),
    );

    return status == DayStatus.late
        ? DashedBorder(radius: radius, child: cell)
        : cell;
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final String icon;
  final String tooltip;

  /// Null shows the button greyed out.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        disabledBackgroundColor: AppColors.surface,
        fixedSize: Size.square(44.r),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      icon: AppSvgIcon(
        icon,
        size: 18.r,
        color: onPressed == null ? AppColors.mist : AppColors.ink,
        matchTextDirection: true,
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = 12.r;
    final radius = BorderRadius.circular(4.r);

    Widget swatch(Color? color, {Color? border}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: border == null ? null : Border.all(color: border),
      ),
    );

    final items = [
      (swatch(AppColors.blush, border: AppColors.rose), l10n.present),
      (swatch(AppColors.mahabbahRed), l10n.absent),
      (
        DashedBorder(
          radius: 4.r,
          child: SizedBox.square(dimension: size),
        ),
        l10n.late,
      ),
      (swatch(AppColors.gold), l10n.officialHoliday),
      (swatch(AppColors.surface), l10n.friSatOff),
    ];

    return Wrap(
      spacing: 14.w,
      runSpacing: 8.h,
      children: [
        for (final (marker, label) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6.w,
            children: [
              marker,
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
