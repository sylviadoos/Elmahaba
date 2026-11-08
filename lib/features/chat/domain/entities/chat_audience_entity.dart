import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_audience_type.dart';

/// The parents a general item went to, e.g. class 4B.
class ChatAudienceEntity extends Equatable {
  const ChatAudienceEntity({
    required this.type,
    required this.name,
    required this.nameAr,
  });

  final ChatAudienceType type;

  /// As the school shows it, e.g. "Class 4B" / "فصل 4B".
  final String name;
  final String nameAr;

  @override
  List<Object?> get props => [type, name, nameAr];
}
