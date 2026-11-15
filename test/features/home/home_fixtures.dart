import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/child_dashboard_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/dashboard_attendance_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

const allParents = ChatAudienceEntity(
  type: ChatAudienceType.all,
  name: 'All parents',
  nameAr: 'كل أولياء الأمور',
);

final holiday = AnnouncementEntity(
  id: 2,
  title: 'اجازه بمناسبه عيد الام',
  body: 'يوم السبت الموافق 7-11 اجازه بمناسبه عيد الام',
  publishedAt: DateTime.utc(2026, 11, 5, 10, 7),
  isEdited: true,
  audience: allParents,
  chatKey: 'event:38',
);

final trip = AnnouncementEntity(
  id: 4,
  title: 'School trip on Thursday',
  body: 'Please send the signed permission form.',
  publishedAt: DateTime.utc(2026, 11, 4, 9),
  audience: allParents,
  chatKey: 'event:52',
  isRead: false,
);

final mathSheet = HomeworkEntity(
  id: 12,
  title: 'Exercise 1, pages 1–3',
  subject: 'Math',
  subjectId: 3,
  description: 'Solve all questions.',
  dueDate: DateTime(2026, 11, 11),
  dueStatus: HomeworkDueStatus.upcoming,
  isEdited: false,
  chatKey: 'event:41',
  isRead: false,
);

final termResult = LatestResultEntity(
  id: 280,
  title: 'نتيجة نصف الترم',
  academicYear: '2026-2027',
  resultType: 'value and color',
  publishedAt: DateTime.utc(2026, 11, 4, 17, 48),
);

LatestItemsEntity<T> latest<T>(List<T> items, {int? total, int unread = 0}) =>
    LatestItemsEntity(
      items: items,
      total: total ?? items.length,
      unread: unread,
    );

/// A dashboard with the latest of each: an announcement and the homework
/// not seen yet.
ChildDashboardEntity dashboardWith({
  List<AnnouncementEntity>? announcements,
  List<HomeworkEntity>? homework,
  List<LatestResultEntity>? results,
  int presentDays = 3,
  MessageCountsEntity messages = const MessageCountsEntity(
    messages: 0,
    notices: 0,
    total: 0,
  ),
}) => ChildDashboardEntity(
  attendance: DashboardAttendanceEntity(
    todayStatus: 'present',
    presentDays: presentDays,
  ),
  latestResult: termResult,
  messages: messages,
  announcements: latest(announcements ?? [holiday, trip], unread: 1),
  homework: latest(homework ?? [mathSheet], unread: 1),
  results: latest(results ?? [termResult]),
);

/// The `data` of the API's example dashboard (one of its announcements and
/// results left out).
const dashboardJson = <String, dynamic>{
  'child': {
    'student_id': 9,
    'name': 'Selena Mina Nagy mina',
    'name_ar': 'سيلينا مينا ناجى',
    'national_id': '••••0923',
    'relationship': 'father',
    'access': 'active',
    'read_only_until': null,
    'photo_url': null,
    'grade': 'Second Primary',
    'class': 'A',
    'academic_year': '2026-2027',
  },
  'attendance': {'today': 'absent', 'present_days': 3},
  'announcements': {
    'items': [
      {
        'id': 3,
        'title': 'تيسسستت',
        'body': 'تتتتتتتتتتتتتتتتتتتتتانانان',
        'published_at': '2026-11-05T13:11:55+00:00',
        'expires_at': null,
        'expired': false,
        'edited': false,
        'last_updated': null,
        'attachments': [],
        'scope': 'general',
        'audience': {
          'type': 'all',
          'name': 'All parents',
          'name_ar': 'كل أولياء الأمور',
        },
        'chat_key': 'event:47',
        'is_read': true,
      },
      {
        'id': 2,
        'title': 'اجازه بمناسبه عيد الام',
        'body': 'يوم السبت الموافق 7-11 اجازه بمناسبه عيد الام',
        'published_at': '2026-11-05T10:07:13+00:00',
        'expires_at': null,
        'expired': false,
        'edited': true,
        'last_updated': '2026-11-05T11:22:24+00:00',
        'attachments': [],
        'scope': 'general',
        'audience': {
          'type': 'all',
          'name': 'All parents',
          'name_ar': 'كل أولياء الأمور',
        },
        'chat_key': 'event:38',
        'is_read': true,
      },
    ],
    'total': 3,
    'unread': 0,
  },
  'homework': {
    'items': [
      {
        'id': 2,
        'title': 'teest',
        'subject': 'Arabic',
        'subject_id': 24,
        'description': 'nnnnnnnnnnnnnnnnnnn',
        'issue_date': '2026-11-09',
        'due_date': '2026-11-12',
        'edited': false,
        'last_updated': null,
        'attachments': [
          {
            'id': 12,
            'file_name': 'SRS_IEEE830 (1).pdf',
            'mime': 'application/pdf',
            'size': 3014622,
            'status': 'available',
          },
        ],
        'due_status': 'upcoming',
        'chat_key': 'event:55',
        'is_read': true,
      },
    ],
    'total': 1,
    'unread': 0,
  },
  'results': {
    'latest': {
      'id': 280,
      'title': 'تيسسستتت',
      'academic_year': '2026-2027',
      'result_type': 'value and color',
      'published_at': '2026-11-04T17:48:00+00:00',
    },
    'items': [
      {
        'id': 280,
        'title': 'تيسسستتت',
        'academic_year': '2026-2027',
        'result_type': 'value and color',
        'published_at': '2026-11-04T17:48:00+00:00',
        'publication_id': 46,
        'chat_key': 'event:34',
        'is_read': true,
      },
      {
        'id': 222,
        'title': 'الوان قط',
        'academic_year': '2026-2027',
        'result_type': 'color',
        'published_at': '2026-11-03T12:01:00+00:00',
        'publication_id': 44,
        'chat_key': 'event:14',
        'is_read': true,
      },
    ],
    'total': 7,
    'unread': 0,
  },
  'fees': {
    'selection_status': 'UPCOMING',
    'selected_installment': {
      'fee_type': 'مصاريف التعليم والنشاط',
      'label': 'قسط رابع',
      'amount': 3000,
      'due_date': '2027-02-01',
    },
  },
  'messages': {'messages': 0, 'notices': 0, 'total': 0},
};
