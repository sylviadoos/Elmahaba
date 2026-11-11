import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/home/domain/entities/announcement_entity.dart';

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

const agendaFile = ChatAttachmentEntity(
  id: 77,
  fileName: 'agenda.pdf',
  mimeType: 'application/pdf',
  size: 84211,
  isAvailable: true,
);

const _allParents = ChatAudienceEntity(
  type: ChatAudienceType.all,
  name: 'All parents',
  nameAr: 'كل أولياء الأمور',
);

/// The API's example announcements.
final meeting = AnnouncementEntity(
  id: 9,
  title: 'Parents meeting',
  body: 'Parents meeting on Sunday at 10 AM.',
  publishedAt: DateTime.utc(2026, 11, 7, 8),
  attachments: const [agendaFile],
  audience: _allParents,
  chatKey: 'event:40',
  isRead: false,
);

final sportsDay = AnnouncementEntity(
  id: 7,
  title: 'Sports day',
  body: 'Parents meeting on Sunday at 10 AM.',
  publishedAt: DateTime.utc(2026, 11, 7, 8),
  expiresAt: DateTime.utc(2026, 11, 1, 10),
  isExpired: true,
  attachments: const [agendaFile],
  audience: _allParents,
  chatKey: 'event:31',
);

/// [items] as the first of [lastPage] pages.
AnnouncementsPageEntity announcementsPage(
  List<AnnouncementEntity> items, {
  int page = 1,
  int lastPage = 1,
  int? total,
  int unread = 0,
}) => AnnouncementsPageEntity(
  items: items,
  page: page,
  lastPage: lastPage,
  total: total ?? items.length,
  unread: unread,
);
