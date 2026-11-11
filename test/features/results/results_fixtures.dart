import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/results/data/models/monthly_results_model.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_certificate_entity.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/monthly_results_entity.dart';

Map<String, dynamic> _parts(
  num exam,
  num homework,
  num classWork,
  num weekly,
) => {
  'Monthly exam': exam,
  'Homework': homework,
  'Class work': classWork,
  'Weekly assessment': weekly,
  'Attendance & behavior': 5,
};

const _components = [
  {'name': 'Monthly exam', 'max': 15},
  {'name': 'Homework', 'max': 5},
  {'name': 'Class work', 'max': 5},
  {'name': 'Weekly assessment', 'max': 10},
  {'name': 'Attendance & behavior', 'max': 5},
];

/// The API's example `result-sheets?template=monthly` response.
final monthlyJson = <String, dynamic>{
  'status': 'success',
  'data': [
    {
      'id': 341,
      'publication_id': 61,
      'title': 'نتيجة شهر نوفمبر',
      'template': 'monthly',
      'layout': 'monthly',
      'month': 'November',
      'display': 'value and color',
      'academic_year': '2026-2027',
      'published_at': '2026-12-05T10:00:00+00:00',
    },
    {
      'id': 326,
      'publication_id': 59,
      'title': 'نتيجة شهر أكتوبر',
      'template': 'monthly',
      'layout': 'monthly',
      'month': 'October',
      'display': 'value and color',
      'academic_year': '2026-2027',
      'published_at': '2026-11-09T12:23:00+00:00',
    },
  ],
  'meta': {
    'page': 1,
    'per_page': 2,
    'total': 2,
    'last_page': 1,
    'months': ['October', 'November'],
  },
  'certificate': {
    'student': {
      'student_id': 146,
      'name': 'Omar Ahmed',
      'name_ar': 'عمر أحمد',
      'grade': 'First Primary',
      'class': 'A',
      'academic_year': '2026-2027',
    },
    'months': [
      {
        'key': 'm0',
        'month': 'October',
        'title': 'نتيجة شهر أكتوبر',
        'published_at': '2026-11-09T12:23:00+00:00',
        'grand_total': 245,
        'max_grand_total': 280,
        'percentage': 87.5,
        'rank': 3,
        'attendance_percentage': 96,
      },
      {
        'key': 'm1',
        'month': 'November',
        'title': 'نتيجة شهر نوفمبر',
        'published_at': '2026-12-05T10:00:00+00:00',
        'grand_total': 252,
        'max_grand_total': 280,
        'percentage': 90,
        'rank': 2,
        'attendance_percentage': 100,
      },
    ],
    'subjects': [
      {
        'subject_id': 24,
        'name': 'Arabic',
        'in_grade': true,
        'included_in_total': true,
        'components': _components,
        'marks': {
          'm0': {
            'components': _parts(14, 5, 5, 9),
            'total': 38,
            'max_total': 40,
            'included_in_total': true,
          },
          'm1': {
            'components': _parts(15, 5, 4, 10),
            'total': 39,
            'max_total': 40,
            'included_in_total': true,
          },
        },
      },
      {
        'subject_id': 31,
        'name': 'Religion',
        'in_grade': true,
        'included_in_total': false,
        'components': _components,
        'marks': {
          'm0': {
            'components': _parts(15, 5, 5, 10),
            'total': 40,
            'max_total': 40,
            'included_in_total': false,
          },
        },
      },
      {
        'subject_id': 25,
        'name': 'Math',
        'in_grade': true,
        'included_in_total': null,
        'components': [],
        'marks': {},
      },
    ],
    'pdf_url':
        'http://192.168.0.219/Almahhaba-School-back-API/public/api/v1/parent/certificate-pdf/146/7?expires=1762706400&signature=3f1c9a',
    'pdf_url_expires_in_minutes': 30,
  },
};

/// [monthlyJson], read.
final MonthlyResultsEntity monthly = MonthlyResultsModel.fromJson(monthlyJson);

/// The child [monthly] is about, as the children list has them.
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

/// [monthly]'s certificate, without the student's name, class or grade.
final MonthlyCertificateEntity certificateWithoutStudent =
    MonthlyCertificateEntity(
      studentName: '',
      studentNameAr: '',
      grade: '',
      className: '',
      academicYear: monthly.certificate!.academicYear,
      months: monthly.certificate!.months,
      subjects: monthly.certificate!.subjects,
    );
