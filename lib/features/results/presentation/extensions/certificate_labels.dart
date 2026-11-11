import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:al_mahhaba_school/core/constants/app_constants.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_component_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_subject_entity.dart';

const _months = [
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december',
];

extension CertificateMonthLabel on CertificateMonthEntity {
  /// Its name in the app's language, "أكتوبر"; as the school wrote it when
  /// it isn't a month's name.
  String label(BuildContext context) {
    final index = _months.indexOf(month.trim().toLowerCase());
    if (index < 0) return month;
    return DateFormat.MMMM(
      Localizations.localeOf(context).toString(),
    ).format(DateTime(2000, index + 1));
  }
}

extension CertificateStudentName on MonthlyCertificateEntity {
  /// The Arabic name in Arabic (when the school has one), else the English.
  String studentNameIn(BuildContext context) =>
      Localizations.localeOf(context).languageCode == AppConstants.arKey &&
          studentNameAr.isNotEmpty
      ? studentNameAr
      : studentName;
}

extension MonthlyResultDetails on MonthlyResultsEntity {
  /// [month] laid out as a result, so it shows like any other: its totals,
  /// and each subject it has marks for, counted or not.
  ResultDetailsEntity resultOf(
    CertificateMonthEntity month, {
    required String studentName,
  }) {
    final certificate = this.certificate;
    final sheet = sheets
        .where((sheet) => sheet.month == month.month)
        .firstOrNull;
    final counted = <ResultSubjectEntity>[];
    final notCounted = <ResultSubjectEntity>[];
    for (final subject in certificate?.subjects ?? const []) {
      final marks = subject.marks[month.key];
      if (marks == null) continue;
      final components = [
        for (final component in subject.components)
          if (marks.components[component.name] case final double mark)
            ResultComponentEntity(
              name: component.name,
              mark: mark,
              max: component.max,
            ),
      ];
      final result = ResultSubjectEntity(
        name: subject.name,
        total:
            marks.total ??
            components.fold(0, (sum, component) => sum + component.mark),
        maxTotal:
            marks.maxTotal ??
            subject.components.fold(0, (sum, component) => sum + component.max),
        components: components,
      );
      (marks.includedInTotal ?? subject.includedInTotal ?? true)
          ? counted.add(result)
          : notCounted.add(result);
    }

    return ResultDetailsEntity(
      id: sheet?.id ?? 0,
      title: month.title,
      academicYear: certificate?.academicYear ?? sheet?.academicYear ?? '',
      resultType: sheet?.display ?? 'value',
      publishedAt: month.publishedAt,
      studentName: studentName,
      finalResult: month.grandTotal,
      finalResultMax: month.maxGrandTotal,
      rank: month.rank,
      attendancePercentage: month.attendancePercentage,
      subjectsIncluded: counted,
      subjectsNotIncluded: notCounted,
      highLevel: const [],
      activities: const [],
    );
  }
}
