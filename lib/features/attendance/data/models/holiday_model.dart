import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/attendance/domain/entities/holiday_entity.dart';

class HolidayModel extends HolidayEntity {
  const HolidayModel({
    required super.date,
    required super.name,
    required super.nameAr,
  });

  /// { "date": "2026-10-06", "name": "Armed Forces Day",
  ///   "name_ar": "عيد القوات المسلحة" }; null without a readable date.
  static HolidayModel? fromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse(json['date'] as String? ?? '');
    if (date == null) return null;

    return HolidayModel(
      date: date,
      name: jsonText(json['name']),
      nameAr: jsonText(json['name_ar']),
    );
  }
}
