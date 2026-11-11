import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/results_forms.dart';

import '../../results_fixtures.dart';

ResultDetailsEntity _latest({required int id, DateTime? publishedAt}) =>
    ResultDetailsEntity(
      id: id,
      title: 'Term 1',
      academicYear: '2026-2027',
      resultType: 'value',
      publishedAt: publishedAt,
      studentName: 'Omar Ahmed',
      subjectsIncluded: const [],
      subjectsNotIncluded: const [],
      highLevel: const [],
      activities: const [],
    );

void main() {
  test('only the months', () {
    final forms = ResultsForms.of(monthly: monthly);

    expect(forms.monthly, monthly);
    expect(forms.latest, isNull);
    expect(forms.hasBoth, isFalse);
  });

  test('only the latest: no months published', () {
    final latest = _latest(id: 280);
    final forms = ResultsForms.of(
      monthly: const MonthlyResultsEntity(),
      latest: latest,
    );

    expect(forms.monthly, isNull);
    expect(forms.latest, latest);
  });

  test('the latest is a month: shown with the months', () {
    final forms = ResultsForms.of(monthly: monthly, latest: _latest(id: 341));

    expect(forms.latest, isNull);
    expect(forms.monthly, monthly);
  });

  test('both: the newer first', () {
    final older = ResultsForms.of(
      monthly: monthly,
      latest: _latest(id: 280, publishedAt: DateTime.utc(2026, 11, 4)),
    );
    final newer = ResultsForms.of(
      monthly: monthly,
      latest: _latest(id: 400, publishedAt: DateTime.utc(2027, 1, 20)),
    );

    expect(older.hasBoth, isTrue);
    expect(older.monthlyIsNewer, isTrue);
    expect(newer.monthlyIsNewer, isFalse);
  });

  test('nothing: empty', () {
    expect(ResultsForms.of().isEmpty, isTrue);
  });
}
