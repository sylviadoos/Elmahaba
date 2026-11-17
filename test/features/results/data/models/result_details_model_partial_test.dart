import 'package:flutter_test/flutter_test.dart';

import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_kind.dart';

import '../../results_fixtures.dart';

/// What a result reads as when the school leaves parts of it out, sends
/// them as null, or sends a number as text. None of it may throw: one bad
/// result would take the whole page down.
void main() {
  /// [octoberJson] with its `data` replaced by [data].
  Map<String, dynamic> monthWithData(Map<String, dynamic> data) => {
    ...octoberJson,
    'data': data,
  };

  group('the parts the school may leave out', () {
    test('only an id: every text empty, every list empty, nothing thrown', () {
      final result = ResultDetailsModel.fromJson({'result_id': 1});

      expect(result.id, 1);
      expect(result.kind, ResultKind.other);
      expect(result.isMonthly, isFalse);
      expect(result.title, isEmpty);
      expect(result.academicYear, isEmpty);
      expect(result.resultType, isEmpty);
      expect(result.usesColors, isFalse);
      expect(result.period, isNull);
      expect(result.publishedAt, isNull);
      expect(result.finalResult, isNull);
      expect(result.finalResultMax, isNull);
      expect(result.finalMax, 0);
      expect(result.verdict, isNull);
      expect(result.rank, isNull);
      expect(result.attendancePercentage, isNull);
      expect(result.subjectsIncluded, isEmpty);
      expect(result.subjectsNotIncluded, isEmpty);
      expect(result.highLevel, isEmpty);
      expect(result.activities, isEmpty);
    });

    test('every field explicitly null: the same as missing', () {
      final result = ResultDetailsModel.fromJson({
        'result_id': 2,
        'result_type': null,
        'title': null,
        'academic_year': null,
        'period': null,
        'display': null,
        'published_at': null,
        'data': null,
      });

      expect(result.title, isEmpty);
      expect(result.period, isNull);
      expect(result.publishedAt, isNull);
      expect(result.subjectsIncluded, isEmpty);
    });

    test('"data": [] — how an empty map is written — reads as a result '
        'with nothing recorded yet', () {
      final result = ResultDetailsModel.fromJson({
        'result_id': 3,
        'result_type': 'monthly',
        'title': 'نتيجة شهر ديسمبر',
        'data': const <dynamic>[],
      });

      // It is still a result the parent can see and pick in the filter.
      expect(result.id, 3);
      expect(result.isMonthly, isTrue);
      expect(result.title, 'نتيجة شهر ديسمبر');
      expect(result.subjectsIncluded, isEmpty);
      expect(result.subjectsNotIncluded, isEmpty);
      expect(result.highLevel, isEmpty);
      expect(result.activities, isEmpty);
      expect(result.finalResult, isNull);
      expect(result.finalMax, 0);
      expect(result.verdict, isNull);
      expect(result.rank, isNull);
    });

    test('"data" sent as something else entirely: the same, no throw', () {
      for (final data in [
        <int>[1, 2, 3],
        'nonsense',
        42,
        true,
      ]) {
        final result = ResultDetailsModel.fromJson({
          'result_id': 3,
          'data': data,
        });

        expect(result.subjectsIncluded, isEmpty, reason: 'for $data');
        expect(result.finalResult, isNull, reason: 'for $data');
      }
    });

    test('a published_at that is not a date: no date, no crash', () {
      final result = ResultDetailsModel.fromJson({
        'result_id': 4,
        'published_at': 'not a date',
      });

      expect(result.publishedAt, isNull);
    });

    test('an unknown result_type: neither a month nor a term', () {
      final result = ResultDetailsModel.fromJson({
        'result_id': 5,
        'result_type': 'semester',
      });

      expect(result.kind, ResultKind.other);
      expect(result.isMonthly, isFalse);
    });

    test('a result_type that isn\'t text at all: `other`, not a throw', () {
      for (final type in [2, true, const <String>[], const <String, int>{}]) {
        final result = ResultDetailsModel.fromJson({
          'result_id': 5,
          'result_type': type,
        });

        expect(result.kind, ResultKind.other, reason: 'for $type');
      }
    });

    test('a month whose period is missing: still a month', () {
      final result = ResultDetailsModel.fromJson({
        'result_id': 6,
        'result_type': 'MONTHLY',
        'period': null,
      });

      expect(result.isMonthly, isTrue);
      expect(result.period, isNull);
    });
  });

  group('numbers the school sends as text', () {
    test('marks and totals as strings: read as numbers', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'grand_total': '245.5',
          'max_grand_total': '280',
          'rank': '3',
          'attendance_percentage': '96.5',
          'subjects': [
            {
              'name': 'Arabic',
              'included_in_total': true,
              'total': '38',
              'max_total': '40',
              'components': [
                {'name': 'Monthly exam', 'mark': '14', 'max': '15'},
              ],
            },
          ],
        }),
      );

      expect(result.finalResult, 245.5);
      expect(result.finalMax, 280);
      expect(result.rank, 3);
      expect(result.attendancePercentage, 96.5);
      expect(result.subjectsIncluded.single.total, 38);
      expect(result.subjectsIncluded.single.components.single.mark, 14);
    });

    test('a mark that is not a number at all: read as 0, not a crash', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            {
              'name': 'Arabic',
              'total': 'absent',
              'max_total': null,
              'components': [
                {'name': 'Exam', 'mark': '-', 'max': 'x'},
              ],
            },
          ],
        }),
      );

      final arabic = result.subjectsIncluded.single;
      expect(arabic.components.single.mark, 0);
      expect(arabic.components.single.max, 0);
      // No total and no parts to add up: out of 100 by default.
      expect(arabic.total, 0);
      expect(arabic.maxTotal, 100);
    });
  });

  group('included_in_total, however the school sends it', () {
    /// Whether the subject in a result built with [flag] is counted.
    bool isCounted(Object? flag) {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            {'name': 'Arabic', 'included_in_total': flag, 'total': 38},
          ],
        }),
      );
      return result.subjectsIncluded.isNotEmpty;
    }

    test('true / false, as the API documents it', () {
      expect(isCounted(true), isTrue);
      expect(isCounted(false), isFalse);
    });

    test('1 / 0 — how a MySQL tinyint comes back — not a throw', () {
      expect(isCounted(1), isTrue);
      expect(isCounted(0), isFalse);
    });

    test('"true" / "false" / "1" / "0" as text', () {
      expect(isCounted('true'), isTrue);
      expect(isCounted('false'), isFalse);
      expect(isCounted('1'), isTrue);
      expect(isCounted('0'), isFalse);
      expect(isCounted('TRUE'), isTrue);
    });

    test('missing, null, or something it can\'t read: counted', () {
      expect(isCounted(null), isTrue);
      expect(isCounted('maybe'), isTrue);
      expect(isCounted(const <String>[]), isTrue);
    });

    test('the marks still land in the right section either way', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'grand_total': null,
          'subjects': [
            {'name': 'Arabic', 'included_in_total': 1, 'total': 38},
            {'name': 'Religion', 'included_in_total': 0, 'total': 40},
          ],
        }),
      );

      expect(result.subjectsIncluded.single.name, 'Arabic');
      expect(result.subjectsNotIncluded.single.name, 'Religion');
      // Only the counted one adds up.
      expect(result.finalResult, 38);
    });
  });

  group('the subjects list', () {
    test('nulls and odd entries in it are left out', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            null,
            'nonsense',
            7,
            {'name': 'Arabic', 'total': 38, 'max_total': 40},
          ],
        }),
      );

      expect(result.subjectsIncluded.map((subject) => subject.name), [
        'Arabic',
      ]);
    });

    test('a subject with no components: its own total stands', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            {'name': 'Art', 'total': 18, 'max_total': 20},
          ],
        }),
      );

      expect(result.subjectsIncluded.single.total, 18);
      expect(result.subjectsIncluded.single.maxTotal, 20);
      expect(result.subjectsIncluded.single.components, isEmpty);
    });

    test('no total given: the components add up to it, and to its max', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            {
              'name': 'Science',
              'components': [
                {'name': 'Exam', 'mark': 18, 'max': 20},
                {'name': 'Homework', 'mark': 9, 'max': 10},
              ],
            },
          ],
        }),
      );

      final science = result.subjectsIncluded.single;
      expect(science.total, 27);
      expect(science.maxTotal, 30);
    });

    test('no grand total: the counted subjects add up to it, and the ones '
        'not counted stay out', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'subjects': [
            {
              'name': 'Arabic',
              'included_in_total': true,
              'total': 38,
              'max_total': 40,
            },
            {
              'name': 'Religion',
              'included_in_total': false,
              'total': 40,
              'max_total': 40,
            },
          ],
        }),
      );

      expect(result.finalResult, 38);
      expect(result.finalMax, 40);
      expect(result.subjectsNotIncluded.single.name, 'Religion');
    });
  });

  group('the final result', () {
    test('a word and a mark together: the mark counts, the word is the '
        'verdict', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({'final_result': 'ناجح', 'final_result_2': '297.4'}),
      );

      expect(result.finalResult, 297.4);
      expect(result.verdict, 'ناجح');
    });

    test('a grand total beats both', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({
          'grand_total': 245,
          'final_result': 'ناجح',
          'final_result_2': 297.4,
        }),
      );

      expect(result.finalResult, 245);
      expect(result.verdict, 'ناجح');
    });

    test('an empty word is no verdict', () {
      final result = ResultDetailsModel.fromJson(
        monthWithData({'final_result': '   ', 'final_result_2': null}),
      );

      expect(result.verdict, isNull);
    });
  });
}
