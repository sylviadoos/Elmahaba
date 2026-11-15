import 'package:equatable/equatable.dart';

/// Items the school confirmed read, from any page.
class ChatReadEntity extends Equatable {
  const ChatReadEntity({this.studentId, required this.unread});

  /// The child they were read for; null from the chat's "All".
  final int? studentId;

  /// What's still unread: [studentId]'s, or the whole account's without
  /// one.
  final int unread;

  @override
  List<Object?> get props => [studentId, unread];
}
