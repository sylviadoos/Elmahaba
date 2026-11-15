import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_period_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/school_order.dart';

/// A month's result for [month] of [year], published [publishedAt].
ResultDetailsEntity _month(
  String title,
  int month,
  int year, {
  required DateTime publishedAt,
}) => ResultDetailsEntity(
  id: title.hashCode,
  kind: ResultKind.monthly,
  title: title,
  academicYear: '2026-2027',
  resultType: 'value',
  period: ResultPeriodEntity(
    month: month,
    monthName: '',
    monthNameAr: '',
    year: year,
  ),
  publishedAt: publishedAt,
  subjectsIncluded: const [],
  subjectsNotIncluded: const [],
  highLevel: const [],
  activities: const [],
);

/// A term's result, published [publishedAt].
ResultDetailsEntity _term(String title, DateTime? publishedAt) =>
    ResultDetailsEntity(
      id: title.hashCode,
      kind: ResultKind.term,
      title: title,
      academicYear: '2026-2027',
      resultType: 'value',
      publishedAt: publishedAt,
      subjectsIncluded: const [],
      subjectsNotIncluded: const [],
      highLevel: const [],
      activities: const [],
    );

void main() {
  final october = _month(
    'October',
    10,
    2026,
    publishedAt: DateTime(2026, 11, 9),
  );
  final november = _month(
    'November',
    11,
    2026,
    publishedAt: DateTime(2026, 12, 5),
  );
  final firstTerm = _term('First term', DateTime(2027, 1, 25));
  final march = _month('March', 3, 2027, publishedAt: DateTime(2027, 4, 6));
  final april = _month('April', 4, 2027, publishedAt: DateTime(2027, 5, 4));
  final secondTerm = _term('Second term', DateTime(2027, 6, 20));

  test('the school year\'s order: the months, each term after the months '
      'before it', () {
    final newestFirst = [
      secondTerm,
      april,
      march,
      firstTerm,
      november,
      october,
    ];

    expect(newestFirst.inSchoolOrder(), [
      october,
      november,
      firstTerm,
      march,
      april,
      secondTerm,
    ]);
  });

  test('a month published late stays in its month', () {
    final lateOctober = _month(
      'October',
      10,
      2026,
      publishedAt: DateTime(2026, 12, 20),
    );

    expect([november, lateOctober].inSchoolOrder(), [lateOctober, november]);
  });

  test('one saying neither its month nor when: last', () {
    final undated = _term('Undated', null);

    expect([undated, firstTerm, october].inSchoolOrder(), [
      october,
      firstTerm,
      undated,
    ]);
  });

  test('leaves the list it was given as it was', () {
    final given = [november, october];

    given.inSchoolOrder();

    expect(given, [november, october]);
  });
}
