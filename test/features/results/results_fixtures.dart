import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/results/data/models/result_details_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_details_entity.dart';
import 'package:al_mahhaba_school/features/results/presentation/extensions/child_certificate.dart';

/// A month's subject, its parts out of 15, 5, 5, 10 and 5.
Map<String, dynamic> _monthSubject(
  String name, {
  required bool counted,
  required List<num> marks,
}) {
  const parts = [
    ('Monthly exam', 15),
    ('Homework', 5),
    ('Class work', 5),
    ('Weekly assessment', 10),
    ('Attendance & behavior', 5),
  ];
  return {
    'name': name,
    'included_in_total': counted,
    'components': [
      for (final (index, (part, max)) in parts.indexed)
        {'name': part, 'mark': marks[index], 'max': max},
    ],
    'total': marks.fold<num>(0, (sum, mark) => sum + mark),
    'max_total': 40,
  };
}

/// A month's result, as `results-v2` lists it.
Map<String, dynamic> _month({
  required int id,
  required int month,
  required String name,
  required String nameAr,
  required String publishedAt,
  required List<num> arabic,
}) => {
  'result_id': id,
  'result_type': 'monthly',
  'layout': 'monthly',
  'title': 'نتيجة شهر $nameAr',
  'academic_year': '2026-2027',
  'period': {
    'month': month,
    'month_name': name,
    'month_name_ar': nameAr,
    'year': 2026,
  },
  'display': 'value and color',
  'published_at': publishedAt,
  'data': {
    'attendance_percentage': 96,
    'subjects': [
      _monthSubject('Arabic', counted: true, marks: arabic),
      _monthSubject('Religion', counted: false, marks: [15, 5, 5, 10, 5]),
    ],
    'grand_total': 245,
    'max_grand_total': 280,
    'percentage': 87.5,
    'rank': 3,
  },
};

final octoberJson = _month(
  id: 820,
  month: 10,
  name: 'October',
  nameAr: 'أكتوبر',
  publishedAt: '2026-11-11T12:00:00+00:00',
  arabic: [14, 5, 5, 9, 5],
);

final novemberJson = _month(
  id: 905,
  month: 11,
  name: 'November',
  nameAr: 'نوفمبر',
  publishedAt: '2026-12-06T09:30:00+00:00',
  arabic: [15, 4, 5, 10, 5],
);

/// The API's example term result.
final firstTermJson = <String, dynamic>{
  'result_id': 268,
  'result_type': 'term',
  'layout': 'term',
  'title': 'نتيجة الترم الأول',
  'academic_year': '2026-2027',
  'period': null,
  'display': 'value and color',
  'published_at': '2026-11-04T17:48:00+00:00',
  'data': {
    'attendance_percentage': 92,
    'subjects': [
      {
        'name': 'Math',
        'included_in_total': true,
        'components': [
          {'name': 'Class Performance', 'mark': 20, 'max': 20},
        ],
        'total': 96,
        'max_total': 100,
        'initial_assessment': 'F',
        'final_assessment': 'F',
        'status': null,
      },
      {
        'name': 'Art',
        'included_in_total': false,
        'components': [],
        'total': 18,
        'max_total': 20,
        'initial_assessment': null,
        'final_assessment': null,
        'status': 'Pass',
      },
    ],
    'high_level': [
      {
        'name': 'ICT',
        'included_in_total': false,
        'components': [],
        'total': 9,
        'max_total': 10,
        'initial_assessment': null,
        'final_assessment': null,
        'status': 'Pass',
      },
    ],
    'activities': [
      {'name': 'Sports', 'status': 'Pass'},
    ],
    'final_result': 'ناجح',
    'final_result_2': null,
  },
};

/// The whole answer of `results-v2` with these [results].
Map<String, dynamic> resultsResponse(List<Map<String, dynamic>> results) => {
  'status': 'success',
  'data': results,
  'meta': {
    'total': results.length,
    'periods': [],
    'academic_years': [
      {'id': 2, 'name': '2026-2027'},
    ],
  },
};

final ResultDetailsEntity october = ResultDetailsModel.fromJson(octoberJson);
final ResultDetailsEntity november = ResultDetailsModel.fromJson(novemberJson);
final ResultDetailsEntity firstTerm = ResultDetailsModel.fromJson(
  firstTermJson,
);

/// Everything published for [omar], newest first.
final allResults = [november, october, firstTerm];

/// The child the results are about, as the children list has them.
const omar = ChildEntity(
  studentId: 146,
  name: 'Omar Ahmed',
  nameAr: 'عمر أحمد',
  nationalId: '••••2341',
  relationship: 'father',
  access: 'active',
  grade: 'First Primary',
  className: 'A',
  academicYear: '2026/2027',
);

/// [omar]'s certificate with October and November on it.
final MonthlyCertificateEntity certificate = omar.certificateWith([
  october,
  november,
]);

/// [certificate], without the student's name, class or grade.
final MonthlyCertificateEntity certificateWithoutStudent =
    MonthlyCertificateEntity(
      studentName: '',
      studentNameAr: '',
      grade: '',
      className: '',
      academicYear: certificate.academicYear,
      months: certificate.months,
      subjects: certificate.subjects,
    );
