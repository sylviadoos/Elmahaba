import 'package:al_mahhaba_school/features/chat/domain/entities/chat_attachment_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_child_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_link_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_sender.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

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

const attachment = ChatAttachmentEntity(
  id: 77,
  fileName: 'trip-form.pdf',
  mimeType: 'application/pdf',
  size: 84211,
  isAvailable: true,
);

const photo = ChatAttachmentEntity(
  id: 78,
  fileName: 'trip.jpg',
  mimeType: 'image/jpeg',
  size: 120400,
  isAvailable: true,
);

/// A school message about [about] (none: general), unread unless [isRead],
/// leading to [link] if given.
ChatItemEntity schoolItem(
  String key, {
  ChildEntity? about,
  bool isRead = false,
  bool canReply = true,
  ChatLinkEntity? link,
}) => ChatItemEntity(
  key: key,
  sender: ChatSender.school,
  sentAt: DateTime(2026, 11, 4, 10),
  children: [
    if (about != null)
      ChatChildEntity(
        studentId: about.studentId,
        name: about.name,
        nameAr: about.nameAr,
      ),
  ],
  text: 'Please bring the signed trip form tomorrow.',
  isRead: isRead,
  isEdited: false,
  isDeleted: false,
  canReply: canReply,
  link: link,
);

/// The parent's message, as the school saved it.
final sentItem = ChatItemEntity(
  key: 'message:50',
  sender: ChatSender.parent,
  sentAt: DateTime(2026, 11, 4, 11),
  text: 'Thank you.',
  isRead: true,
  isEdited: false,
  isDeleted: false,
  canReply: false,
);

ChatPageEntity chatPage(
  List<ChatItemEntity> items, {
  bool canSend = true,
  bool hasMore = false,
  String? nextBefore,
  int unread = 0,
}) => ChatPageEntity(
  items: items,
  hasMore: hasMore,
  nextBefore: nextBefore,
  unread: unread,
  isOpen: true,
  canSend: canSend,
);

/// A file picked that can go.
const pickedPdf = PickedAttachment(
  name: 'trip-form.pdf',
  path: '/files/trip-form.pdf',
  size: 1000,
);

/// A file picked that won't go: not a kind the school takes.
const pickedVideo = PickedAttachment(
  name: 'party.mp4',
  path: '/files/party.mp4',
  size: 4000,
  problem: AttachmentProblem.typeNotAllowed,
);
