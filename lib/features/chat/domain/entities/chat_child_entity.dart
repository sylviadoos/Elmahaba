import 'package:equatable/equatable.dart';

/// A child a chat item is about.
class ChatChildEntity extends Equatable {
  const ChatChildEntity({
    required this.studentId,
    required this.name,
    required this.nameAr,
  });

  final int studentId;
  final String name;
  final String nameAr;

  @override
  List<Object?> get props => [studentId, name, nameAr];
}
