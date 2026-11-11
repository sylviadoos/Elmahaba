import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/certificate_month_entity.dart';

class CertificateMonthModel extends CertificateMonthEntity {
  const CertificateMonthModel({
    required super.key,
    required super.month,
    required super.title,
    super.publishedAt,
    super.grandTotal,
    super.maxGrandTotal,
    super.percentage,
    super.rank,
    super.attendancePercentage,
  });

  /// { "key": "m0", "month": "October", "title": "نتيجة شهر أكتوبر",
  ///   "published_at": "2026-11-09T12:23:00+00:00", "grand_total": 245,
  ///   "max_grand_total": 280, "percentage": 87.5, "rank": 3,
  ///   "attendance_percentage": 96 } — with a `key`.
  factory CertificateMonthModel.fromJson(Map<String, dynamic> json) =>
      CertificateMonthModel(
        key: jsonText(json['key']),
        month: jsonText(json['month']),
        title: jsonText(json['title']),
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
        grandTotal: jsonDouble(json['grand_total']),
        maxGrandTotal: jsonDouble(json['max_grand_total']),
        percentage: jsonDouble(json['percentage']),
        rank: jsonDouble(json['rank'])?.round(),
        attendancePercentage: jsonDouble(json['attendance_percentage']),
      );
}
