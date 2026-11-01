import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/dashed_border.dart';
import 'package:al_mahhaba_school/core/widgets/equal_height_grid.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/attendance/data/mock_attendance.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/month_calendar.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/main_nav_bar.dart';
import 'package:al_mahhaba_school/features/shell/presentation/widgets/parent_tab_page.dart';

/// The month's attendance for the selected child: totals, calendar and
/// what happened this month.
class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int _selectedChild = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final month = mockAttendanceMonth;
    final attendance = mockAttendance[_selectedChild];
    final days = [
      for (
        var day = 1;
        day <= DateUtils.getDaysInMonth(month.year, month.month);
        day++
      )
        dayStatus(month, day, attendance),
    ];
    int count(DayStatus status) => days.where((d) => d == status).length;

    return ParentTabPage(
      title: l10n.attendance,
      tab: MainTab.attendance,
      selectedChild: _selectedChild,
      onChildSelected: (index) => setState(() => _selectedChild = index),
      children: [
        EqualHeightGrid(
          columns: 3,
          spacing: 10.w,
          children: [
            _CountTile(
              count: count(DayStatus.present),
              label: l10n.present,
              style: _TileStyle.soft,
            ),
            _CountTile(
              count: count(DayStatus.absent),
              label: l10n.absent,
              style: _TileStyle.solid,
            ),
            _CountTile(
              count: count(DayStatus.late),
              label: l10n.late,
              style: _TileStyle.dashed,
            ),
          ],
        ),
        MonthCalendar(month: month, days: days),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10.h,
          children: [
            SectionTitle(l10n.thisMonth),
            for (final event in attendance.events)
              _EventRow(event: event, month: month),
          ],
        ),
      ],
    );
  }
}

enum _TileStyle { soft, solid, dashed }

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.label,
    required this.style,
  });

  final int count;
  final String label;
  final _TileStyle style;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final solid = style == _TileStyle.solid;
    final radius = 16.r;

    final tile = Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: switch (style) {
          _TileStyle.soft => AppColors.blush,
          _TileStyle.solid => AppColors.mahabbahRed,
          _TileStyle.dashed => null,
        },
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Column(
        spacing: 2.h,
        children: [
          Text(
            '$count',
            style: textTheme.titleLarge?.copyWith(
              fontSize: 22.sp,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: solid ? AppColors.white : AppColors.mahabbahRed,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: solid
                  ? AppColors.white.withValues(alpha: 0.88)
                  : AppColors.slate,
            ),
          ),
        ],
      ),
    );

    return style == _TileStyle.dashed
        ? DashedBorder(radius: radius, child: tile)
        : tile;
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.month});

  final AttendanceEvent event;
  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime(month.year, month.month, event.day);
    final title = switch (event.type) {
      AttendanceEventType.absent => l10n.absent,
      AttendanceEventType.late => l10n.late,
      AttendanceEventType.holiday => l10n.officialHoliday,
    };

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        spacing: 12.w,
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: AppColors.blush,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('dd', locale).format(date),
                  style: textTheme.bodyLarge?.copyWith(
                    height: 18 / 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mahabbahRed,
                  ),
                ),
                Text(
                  DateFormat.MMM(locale).format(date).toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 10.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mahabbahRed,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2.h,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  event.detail,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
