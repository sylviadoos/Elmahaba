import 'package:equatable/equatable.dart';

/// An official holiday: no school that day.
class HolidayEntity extends Equatable {
  const HolidayEntity({
    required this.date,
    required this.name,
    required this.nameAr,
  });

  final DateTime date;

  /// e.g. "Armed Forces Day".
  final String name;

  /// e.g. "عيد القوات المسلحة"; empty when not given.
  final String nameAr;

  @override
  List<Object?> get props => [date, name, nameAr];
}
