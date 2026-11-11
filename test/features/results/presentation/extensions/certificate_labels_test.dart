import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_component_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/certificate_labels.dart';

import '../../results_fixtures.dart';

void main() {
  final [october, november] = monthly.certificate!.months;

  test('a month as a result: its totals, rank and attendance', () {
    final result = monthly.resultOf(october, studentName: 'Omar Ahmed');

    // October's sheet.
    expect(result.id, 326);
    expect(result.title, 'نتيجة شهر أكتوبر');
    expect(result.academicYear, '2026-2027');
    expect(result.usesColors, isTrue);
    expect(result.publishedAt, DateTime.utc(2026, 11, 9, 12, 23));
    expect(result.studentName, 'Omar Ahmed');
    expect(result.finalResult, 245);
    // The school's maximum, not only the subjects sent.
    expect(result.finalMax, 280);
    expect(result.rank, 3);
    expect(result.attendancePercentage, 96);
  });

  test('its subjects, counted or not, by part', () {
    final result = monthly.resultOf(october, studentName: '');

    final arabic = result.subjectsIncluded.single;
    expect(arabic.name, 'Arabic');
    expect(arabic.total, 38);
    expect(arabic.maxTotal, 40);
    expect(arabic.components, const [
      ResultComponentEntity(name: 'Monthly exam', mark: 14, max: 15),
      ResultComponentEntity(name: 'Homework', mark: 5, max: 5),
      ResultComponentEntity(name: 'Class work', mark: 5, max: 5),
      ResultComponentEntity(name: 'Weekly assessment', mark: 9, max: 10),
      ResultComponentEntity(name: 'Attendance & behavior', mark: 5, max: 5),
    ]);
    expect(result.subjectsNotIncluded.single.name, 'Religion');
    // Math has no marks yet: not shown.
    expect(result.highLevel, isEmpty);
  });

  test('a month a subject has no marks for leaves it out', () {
    final result = monthly.resultOf(november, studentName: '');

    expect(result.subjectsIncluded.single.total, 39);
    expect(result.subjectsNotIncluded, isEmpty);
  });

  test('no total sent: its parts added up', () {
    const month = CertificateMonthEntity(key: 'm9', month: 'March', title: '');
    final result = monthly.resultOf(month, studentName: '');

    expect(result.subjectsIncluded, isEmpty);
    expect(result.finalResult, isNull);
    expect(result.rank, isNull);
  });
}
