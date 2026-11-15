import 'package:equatable/equatable.dart';

/// The item a message answers.
class ChatReplyToEntity extends Equatable {
  const ChatReplyToEntity({required this.key, required this.isDeleted});

  /// The item's `key`, e.g. "message:41".
  final String key;

  /// The school took it down since.
  final bool isDeleted;

  @override
  List<Object?> get props => [key, isDeleted];
}
