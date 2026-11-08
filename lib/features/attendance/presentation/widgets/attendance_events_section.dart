import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:al_mahhaba_school/config/routes/app_routes.dart';
import 'package:al_mahhaba_school/config/theme/app_colors.dart';
import 'package:al_mahhaba_school/core/extensions/context_extensions.dart';
import 'package:al_mahhaba_school/core/widgets/section_title.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_record_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/attendance_status.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/month_attendance_entity.dart';
import 'package:al_mahhaba_school/features/attendance/presentation/widgets/attendance_event_row.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absence_entity.dart';
import 'package:al_mahhaba_school/features/excuses/domain/entities/excusable_absences_entity.dart';
import 'package:al_mahhaba_school/features/excuses/presentation/extensions/excuse_labels.dart';

/// "This month": the absences, late days and holidays, latest first. An
/// absence a medical excuse can be sent for has "Submit excuse"; one that
/// has an excuse shows where it stands, with "View excuse".
class AttendanceEventsSection extends StatelessWidget {
  const AttendanceEventsSection({
    super.key,
    required this.attendance,
    this.excuses,
    required this.onSubmitExcuse,
    required this.onOpenExcuse,
  });

  final MonthAttendanceEntity attendance;

  /// The child's excusable absences; null until they load (or if they
  /// can't).
  final ExcusableAbsencesEntity? excuses;
  final ValueChanged<ExcusableAbsenceEntity> onSubmitExcuse;

  /// With the excuse's id.
  final ValueChanged<int> onOpenExcuse;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final record in attendance.records) ?_recordRow(context, record),
      for (final holiday in attendance.holidays) _holidayRow(context, holiday),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10.h,
      children: [
        SectionTitle(context.l10n.thisMonth),
        if (rows.isEmpty)
          Text(
            context.l10n.noAbsencesThisMonth,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate,
            ),
          )
        else
          ...rows,
      ],
    );
  }

  /// Null for a plain "present" or a status the app doesn't know.
  AttendanceEventRow? _recordRow(
    BuildContext context,
    AttendanceRecordEntity record,
  ) {
    final l10n = context.l10n;
    final reason = record.reason;
    final reasonText = reason == null
        ? l10n.noReasonGiven
        : l10n.reasonIs(reason);
    final absence = excuses?.on(record.date);
    final excuse = absence?.excuse;

    // An excuse sent: where it stands. One that can be sent: until when.
    final (detail, actionLabel, onAction) = switch (absence) {
      _ when excuse != null => (
        l10n.excuseStatusLine(excuse.status.label(context)),
        l10n.viewExcuse,
        () => onOpenExcuse(excuse.id),
      ),
      ExcusableAbsenceEntity(canSubmit: true, :final submitUntil) => (
        [
          reasonText,
          if (submitUntil != null)
            l10n.excuseSubmitBy(submitUntil.excuseDayLabel(context)),
        ].join(' · '),
        l10n.submitExcuse,
        () => onSubmitExcuse(absence),
      ),
      _ => (reasonText, null, null),
    };

    return switch (record.status) {
      AttendanceStatus.absent => AttendanceEventRow(
        date: record.date,
        title: l10n.absent,
        detail: detail,
        background: AppColors.mahabbahRed,
        foreground: AppColors.white,
        actionLabel: actionLabel,
        // Without a reason or an excuse, the school asks for one in the
        // chat.
        onAction:
            onAction ??
            (reason == null ? () => context.push(AppRoutes.chat) : null),
      ),
      AttendanceStatus.late => AttendanceEventRow(
        date: record.date,
        title: l10n.late,
        detail: reason ?? l10n.arrivedLate,
        background: AppColors.blush,
        foreground: AppColors.mahabbahRed,
      ),
      AttendanceStatus.excused => AttendanceEventRow(
        date: record.date,
        title: l10n.excusedAbsence,
        detail: detail,
        background: AppColors.infoBg,
        foreground: AppColors.info,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
      AttendanceStatus.present || AttendanceStatus.unknown => null,
    };
  }

  static AttendanceEventRow _holidayRow(
    BuildContext context,
    HolidayEntity holiday,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final name = isArabic && holiday.nameAr.isNotEmpty
        ? holiday.nameAr
        : (holiday.name.isNotEmpty ? holiday.name : holiday.nameAr);

    return AttendanceEventRow(
      date: holiday.date,
      title: context.l10n.officialHoliday,
      detail: context.l10n.holidayNoSchool(name),
      background: AppColors.gold,
      foreground: AppColors.goldText,
    );
  }
}
