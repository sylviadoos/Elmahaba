import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';

class ChatAudienceModel extends ChatAudienceEntity {
  const ChatAudienceModel({
    required super.type,
    required super.name,
    required super.nameAr,
  });

  /// { "type": "class", "name": "Class 4B", "name_ar": "فصل 4B" }; type is
  /// "all", "grade" or "class".
  factory ChatAudienceModel.fromJson(Map<String, dynamic> json) =>
      ChatAudienceModel(
        type: switch (json['type']) {
          'all' => ChatAudienceType.all,
          'grade' => ChatAudienceType.grade,
          'class' => ChatAudienceType.classroom,
          _ => ChatAudienceType.unknown,
        },
        name: jsonText(json['name']),
        nameAr: jsonText(json['name_ar']),
      );
}
