import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_subject_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';

extension ChildCertificate on ChildEntity {
  /// The monthly certificate with the child on it (name, class, grade) and
  /// every one of [months]' marks: one more each time a month is
  /// published. [months] oldest first; for a month published twice, the
  /// newer one's marks.
  MonthlyCertificateEntity certificateWith(List<ResultDetailsEntity> months) {
    final certificateMonths = <CertificateMonthEntity>[];
    // By subject, in the order they first came.
    final counted = <String, bool>{};
    final parts = <String, Map<String, double>>{};
    final marks = <String, Map<String, CertificateMarksEntity>>{};

    for (final month in months) {
      final key = 'r${month.id}';
      certificateMonths.add(
        CertificateMonthEntity(
          key: key,
          month: month.period?.monthName ?? '',
          title: month.title,
          publishedAt: month.publishedAt,
          grandTotal: month.finalResult,
          maxGrandTotal: month.finalResultMax,
          rank: month.rank,
          attendancePercentage: month.attendancePercentage,
        ),
      );
      for (final (isCounted, subjects) in [
        (true, month.subjectsIncluded),
        (false, month.subjectsNotIncluded),
      ]) {
        for (final subject in subjects) {
          counted[subject.name] = isCounted;
          final subjectParts = parts.putIfAbsent(subject.name, () => {});
          for (final component in subject.components) {
            subjectParts[component.name] = component.max;
          }
          marks.putIfAbsent(
            subject.name,
            () => {},
          )[key] = CertificateMarksEntity(
            components: {
              for (final component in subject.components)
                component.name: component.mark,
            },
            total: subject.total,
            maxTotal: subject.maxTotal,
            includedInTotal: isCounted,
          );
        }
      }
    }

    final year = months.lastOrNull?.academicYear ?? '';
    return MonthlyCertificateEntity(
      studentName: name,
      studentNameAr: nameAr,
      grade: grade,
      className: className,
      academicYear: year.isNotEmpty ? year : academicYear,
      months: certificateMonths,
      subjects: [
        for (final (index, subject) in counted.keys.indexed)
          CertificateSubjectEntity(
            subjectId: index,
            name: subject,
            includedInTotal: counted[subject],
            components: [
              for (final MapEntry(key: part, value: max)
                  in parts[subject]!.entries)
                CertificateComponentEntity(name: part, max: max),
            ],
            marks: marks[subject]!,
          ),
      ],
    );
  }
}
