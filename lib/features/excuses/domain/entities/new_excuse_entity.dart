import 'package:equatable/equatable.dart';

/// A medical excuse for one absence, as the parent fills it in.
class NewExcuseEntity extends Equatable {
  const NewExcuseEntity({
    required this.attendanceId,
    this.note = '',
    required this.documents,
  });

  /// The absence, from the excusable absences.
  final int attendanceId;

  /// Empty for none.
  final String note;

  /// The files' paths on the phone; at least one.
  final List<String> documents;

  @override
  List<Object?> get props => [attendanceId, note, documents];
}
