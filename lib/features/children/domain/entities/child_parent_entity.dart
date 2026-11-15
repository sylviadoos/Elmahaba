import 'package:equatable/equatable.dart';

/// A child's father or mother, as the school has them.
class ChildParentEntity extends Equatable {
  const ChildParentEntity({
    required this.name,
    required this.nameAr,
    this.job,
    this.education,
    this.phone,
  });

  final String name;

  /// Empty when the school has none.
  final String nameAr;
  final String? job;
  final String? education;
  final String? phone;

  @override
  List<Object?> get props => [name, nameAr, job, education, phone];
}
