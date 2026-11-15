import 'package:equatable/equatable.dart';

/// How many messages and notices the school has for a child.
class MessageCountsEntity extends Equatable {
  const MessageCountsEntity({
    required this.messages,
    required this.notices,
    required this.total,
  });

  final int messages;
  final int notices;

  /// [messages] and [notices] together.
  final int total;

  @override
  List<Object?> get props => [messages, notices, total];
}
