import 'package:equatable/equatable.dart';

/// Asks the school to link a child to the parent's account by the child's
/// national ID.
class LinkChildRequestEntity extends Equatable {
  const LinkChildRequestEntity({
    required this.nationalId,
    this.relationship,
    this.note,
  });

  /// The child's 14-digit national ID.
  final String nationalId;

  /// The parent's relationship to the child, e.g. "father". Optional.
  final String? relationship;

  /// Anything the school should know, e.g. "Second child".
  final String? note;

  @override
  List<Object?> get props => [nationalId, relationship, note];
}
