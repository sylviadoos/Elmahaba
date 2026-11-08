import 'package:equatable/equatable.dart';

/// A kind of complaint the school takes, e.g. "Academic".
class ComplaintCategoryEntity extends Equatable {
  const ComplaintCategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  final int id;
  final String nameEn;
  final String nameAr;

  @override
  List<Object?> get props => [id, nameEn, nameAr];
}
