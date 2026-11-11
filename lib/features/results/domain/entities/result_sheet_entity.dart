import 'package:equatable/equatable.dart';

/// A published result sheet, e.g. one month's results.
class ResultSheetEntity extends Equatable {
  const ResultSheetEntity({
    required this.id,
    required this.title,
    required this.template,
    required this.month,
    required this.display,
    required this.academicYear,
    this.publishedAt,
  });

  /// The result's id, as the dashboard's and `results/{id}`'s.
  final int id;

  /// As the school wrote it, e.g. "نتيجة شهر نوفمبر".
  final String title;

  /// e.g. "monthly".
  final String template;

  /// The month it's for, in English, e.g. "November"; empty when not one.
  final String month;

  /// How the grades are shown: "value", or "value and color".
  final String display;

  /// e.g. "2026-2027".
  final String academicYear;
  final DateTime? publishedAt;

  @override
  List<Object?> get props => [
    id,
    title,
    template,
    month,
    display,
    academicYear,
    publishedAt,
  ];
}
