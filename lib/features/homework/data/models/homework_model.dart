import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/data/models/chat_attachment_model.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_due_status.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_entity.dart';

class HomeworkModel extends HomeworkEntity {
  const HomeworkModel({
    required super.id,
    required super.title,
    required super.subject,
    super.subjectId,
    required super.description,
    super.issueDate,
    super.dueDate,
    required super.dueStatus,
    required super.isEdited,
    super.lastUpdated,
    super.attachments,
    super.chatKey,
    required super.isRead,
  });

  /// { "id": 12, "title": "Ex 1", "subject": "Math", "subject_id": 3,
  ///   "description": "Pages 1-3", "issue_date": "2026-11-08",
  ///   "due_date": "2026-11-11", "due_status": "upcoming", "edited": false,
  ///   "last_updated": null, "attachments": [ …file… ],
  ///   "chat_key": "event:41", "is_read": false }
  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
    id: json['id'] as int? ?? 0,
    title: jsonText(json['title']),
    subject: jsonText(json['subject']),
    subjectId: json['subject_id'] as int?,
    description: jsonText(json['description']),
    issueDate: DateTime.tryParse(json['issue_date'] as String? ?? ''),
    dueDate: DateTime.tryParse(json['due_date'] as String? ?? ''),
    dueStatus: switch (json['due_status']) {
      'upcoming' => HomeworkDueStatus.upcoming,
      'due_today' => HomeworkDueStatus.dueToday,
      'past' => HomeworkDueStatus.past,
      'no_due_date' => HomeworkDueStatus.noDueDate,
      _ => HomeworkDueStatus.unknown,
    },
    isEdited: json['edited'] as bool? ?? false,
    lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? ''),
    attachments: [
      for (final file in jsonObjects(json['attachments']))
        ChatAttachmentModel.fromJson(file),
    ],
    chatKey: jsonTextOrNull(json['chat_key']),
    // Not said: nothing to mark.
    isRead: json['is_read'] as bool? ?? true,
  );
}
