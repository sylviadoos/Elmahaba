import 'package:equatable/equatable.dart';

/// The month a monthly result is for, e.g. October 2026.
class ResultPeriodEntity extends Equatable {
  const ResultPeriodEntity({
    required this.month,
    required this.monthName,
    required this.monthNameAr,
    this.year,
  });

  /// 1–12; 0 when the school didn't say.
  final int month;

  /// "October", "أكتوبر"; empty when not given.
  final String monthName;
  final String monthNameAr;

  /// e.g. 2026; null when not given.
  final int? year;

  @override
  List<Object?> get props => [month, monthName, monthNameAr, year];
}
