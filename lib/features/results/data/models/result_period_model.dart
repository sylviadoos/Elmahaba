import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/results/domain/entities/result_period_entity.dart';

class ResultPeriodModel extends ResultPeriodEntity {
  const ResultPeriodModel({
    required super.month,
    required super.monthName,
    required super.monthNameAr,
    super.year,
  });

  /// { "month": 10, "month_name": "October", "month_name_ar": "أكتوبر",
  ///   "year": 2026 }
  factory ResultPeriodModel.fromJson(Map<String, dynamic> json) =>
      ResultPeriodModel(
        month: jsonDouble(json['month'])?.toInt() ?? 0,
        monthName: jsonText(json['month_name']),
        monthNameAr: jsonText(json['month_name_ar']),
        year: jsonDouble(json['year'])?.toInt(),
      );
}
