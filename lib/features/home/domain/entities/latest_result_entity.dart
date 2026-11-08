import 'package:equatable/equatable.dart';

/// The child's latest published result.
class LatestResultEntity extends Equatable {
  const LatestResultEntity({
    required this.id,
    required this.title,
    required this.academicYear,
    required this.resultType,
    this.publishedAt,
    this.isRead = true,
  });

  final int id;

  /// As the school wrote it, e.g. "نتيجة الصف الاول الابتدائي".
  final String title;

  /// e.g. "2025-2026".
  final String academicYear;

  /// How the grades are shown, e.g. "value and color".
  final String resultType;

  /// null when the API doesn't give one.
  final DateTime? publishedAt;

  /// Whether the parent saw it in the chat; true when the API doesn't say.
  final bool isRead;

  @override
  List<Object?> get props => [
    id,
    title,
    academicYear,
    resultType,
    publishedAt,
    isRead,
  ];
}
