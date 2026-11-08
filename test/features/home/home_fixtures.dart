import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_items_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/latest_result_entity.dart';
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
