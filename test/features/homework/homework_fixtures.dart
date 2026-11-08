import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_subject_entity.dart';

const omar = ChildEntity(
  studentId: 1208,
  name: 'Omar Ahmed',
  nameAr: 'عمر أحمد',
  nationalId: '••••2341',
  relationship: 'father',
  access: 'active',
  grade: 'Fourth Primary',
  className: '4B',
  academicYear: '2026/2027',
);

const lina = ChildEntity(
  studentId: 1209,
  name: 'Lina Ahmed',
  nameAr: 'لينا أحمد',
  nationalId: '••••7781',
  relationship: 'father',
  access: 'active',
  grade: 'KG2',
  className: 'A',
  academicYear: '2026/2027',
);

const exerciseFile = ChatAttachmentEntity(
  id: 88,
  fileName: 'ex1.pdf',
  mimeType: 'application/pdf',
  size: 52344,
  isAvailable: true,
);

const math = HomeworkSubjectEntity(id: 3, name: 'Math');
const arabic = HomeworkSubjectEntity(id: 5, name: 'Arabic');

/// The API's example: "Ex 1" in Math, due 11 Nov, unread, with a file.
final exercise = HomeworkEntity(
  id: 12,
  title: 'Ex 1',
  subject: 'Math',
  subjectId: 3,
  description: 'Pages 1-3',
  issueDate: DateTime(2026, 11, 8),
  dueDate: DateTime(2026, 11, 11),
  dueStatus: HomeworkDueStatus.upcoming,
  isEdited: false,
  attachments: const [exerciseFile],
  chatKey: 'event:41',
  isRead: false,
);

/// And "Read chapter 2" in Arabic, no due date, edited, read.
final reading = HomeworkEntity(
  id: 11,
  title: 'Read chapter 2',
  subject: 'Arabic',
  subjectId: 5,
  description: 'At home',
  issueDate: DateTime(2026, 11, 6),
  dueStatus: HomeworkDueStatus.noDueDate,
  isEdited: true,
  lastUpdated: DateTime.parse('2026-11-07T09:15:00+02:00'),
  chatKey: 'event:38',
  isRead: true,
);

HomeworkPageEntity homeworkPage(
  List<HomeworkEntity> items, {
  int page = 1,
  int lastPage = 1,
  int unread = 0,
  List<HomeworkSubjectEntity> subjects = const [math, arabic],
}) => HomeworkPageEntity(
  items: items,
  page: page,
  lastPage: lastPage,
  total: items.length,
  unread: unread,
  subjects: subjects,
);
