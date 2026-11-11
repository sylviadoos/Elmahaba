import 'package:equatable/equatable.dart';

/// One month on the monthly certificate: its totals.
class CertificateMonthEntity extends Equatable {
  const CertificateMonthEntity({
    required this.key,
    required this.month,
    required this.title,
    this.publishedAt,
    this.grandTotal,
    this.maxGrandTotal,
    this.percentage,
    this.rank,
    this.attendancePercentage,
  });

  /// What the subjects' marks are filed under, e.g. "m0".
  final String key;

  /// In English, e.g. "October".
  final String month;

  /// As the school wrote it, e.g. "نتيجة شهر أكتوبر".
  final String title;
  final DateTime? publishedAt;

  /// The counted subjects' marks together, e.g. 245 out of 280.
  final double? grandTotal;
  final double? maxGrandTotal;

  /// 0–100.
  final double? percentage;

  /// In the class, 1 the first; null when not given.
  final int? rank;

  /// 0–100.
  final double? attendancePercentage;

  @override
  List<Object?> get props => [
    key,
    month,
    title,
    publishedAt,
    grandTotal,
    maxGrandTotal,
    percentage,
    rank,
    attendancePercentage,
  ];
}
