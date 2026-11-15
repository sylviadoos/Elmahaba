import 'package:al_mahhaba_school/features/chat/domain/entities/chat_child_entity.dart';

class ChatChildModel extends ChatChildEntity {
  const ChatChildModel({
    required super.studentId,
    required super.name,
    required super.nameAr,
  });

  /// { "student_id": 1208, "name": "Omar Ahmed", "name_ar": "عمر أحمد" }
  factory ChatChildModel.fromJson(Map<String, dynamic> json) => ChatChildModel(
    studentId: json['student_id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    nameAr: json['name_ar'] as String? ?? '',
  );
}
