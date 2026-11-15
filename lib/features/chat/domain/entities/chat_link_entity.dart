import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';

/// The screen a chat item opens when tapped, e.g. an absence opens
/// Attendance.
class ChatLinkEntity extends Equatable {
  const ChatLinkEntity({required this.screen, this.studentId, this.itemId});

  final ChatScreen screen;

  /// The child it's about.
  final int? studentId;

  /// What it's about on that screen, e.g. the complaint's id.
  final int? itemId;

  @override
  List<Object?> get props => [screen, studentId, itemId];
}
