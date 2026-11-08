import 'package:equatable/equatable.dart';

/// A step in an excuse's life, e.g. sent by the parent.
class ExcuseHistoryEntity extends Equatable {
  const ExcuseHistoryEntity({
    required this.action,
    required this.by,
    this.text,
    this.at,
  });

  /// As the API names it, e.g. "submitted".
  final String action;

  /// Who did it, as the API names them, e.g. "parent".
  final String by;

  /// What was said with it, e.g. what the school asked for.
  final String? text;
  final DateTime? at;

  @override
  List<Object?> get props => [action, by, text, at];
}
