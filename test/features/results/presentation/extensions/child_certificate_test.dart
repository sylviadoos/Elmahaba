import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/child_certificate.dart';

import '../../results_fixtures.dart';

void main() {
  test('the child, and every month with its marks', () {
    final certificate = omar.certificateWith([october, november]);

    expect(certificate.studentName, 'Omar Ahmed');
    expect(certificate.studentNameAr, 'عمر أحمد');
    expect(certificate.grade, 'First Primary');
    expect(certificate.className, 'A');
    // The results' year, as they write it.
    expect(certificate.academicYear, '2026-2027');

    expect(certificate.months.map((month) => month.month), [
      'October',
      'November',
    ]);
    final firstMonth = certificate.months.first;
    expect(firstMonth.key, 'r820');
    expect(firstMonth.grandTotal, 245);
    expect(firstMonth.maxGrandTotal, 280);
    expect(firstMonth.rank, 3);

    final [arabic, religion] = certificate.subjects;
    expect(arabic.name, 'Arabic');
    expect(arabic.includedInTotal, isTrue);
    expect(arabic.components.map((part) => (part.name, part.max)), [
      ('Monthly exam', 15),
      ('Homework', 5),
      ('Class work', 5),
      ('Weekly assessment', 10),
      ('Attendance & behavior', 5),
    ]);
    expect(arabic.marks['r820']?.components['Monthly exam'], 14);
    expect(arabic.marks['r905']?.components['Monthly exam'], 15);
    expect(arabic.marks['r905']?.total, 39);
    expect(religion.includedInTotal, isFalse);
    expect(religion.marks.keys, ['r820', 'r905']);
  });

  test('one more month published: one more on the certificate', () {
    expect(omar.certificateWith([october]).months, hasLength(1));
    expect(omar.certificateWith([october, november]).months, hasLength(2));
  });

  test('a month published again: both kept, the newer last, so its marks '
      'are the ones written', () {
    final again = ResultDetailsModel.fromJson({
      ...octoberJson,
      'result_id': 830,
    });

    final certificate = omar.certificateWith([october, again]);

    expect(certificate.months.map((month) => month.key), ['r820', 'r830']);
    expect(certificate.months.last.month, 'October');
  });

  test('no months: just the child, the year as theirs', () {
    final certificate = omar.certificateWith(const []);

    expect(certificate.months, isEmpty);
    expect(certificate.subjects, isEmpty);
    expect(certificate.academicYear, '2026/2027');
  });
}
