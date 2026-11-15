import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/features/children/domain/entities/child_parent_entity.dart';

/// The parent's account, as the school has it now, with the children's
/// father and mother as its records have them.
class ProfileEntity extends Equatable {
  const ProfileEntity({
    required this.name,
    required this.phone,
    required this.language,
    this.father,
    this.mother,
  });

  final String name;

  /// With its middle hidden, e.g. "0128****570".
  final String phone;

  /// The account's language, "en" or "ar".
  final String language;

  /// Null when the school has no record of them.
  final ChildParentEntity? father;
  final ChildParentEntity? mother;

  /// Which of [father] and [mother] signed in: the one with the account's
  /// phone. Null when neither has it.
  ChildParentEntity? get you {
    if (phone.isEmpty) return null;
    if (father?.phone == phone) return father;
    if (mother?.phone == phone) return mother;
    return null;
  }

  @override
  List<Object?> get props => [name, phone, language, father, mother];
}
