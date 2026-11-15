import 'package:al_mahhaba_school/features/home/domain/entities/message_counts_entity.dart';

class MessageCountsModel extends MessageCountsEntity {
  const MessageCountsModel({
    required super.messages,
    required super.notices,
    required super.total,
  });

  factory MessageCountsModel.fromJson(Map<String, dynamic> json) =>
      MessageCountsModel(
        messages: json['messages'] as int? ?? 0,
        notices: json['notices'] as int? ?? 0,
        total: json['total'] as int? ?? 0,
      );
}
