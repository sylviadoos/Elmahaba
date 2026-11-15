import 'package:al_mahhaba_school/core/utils/json_values.dart';
import 'package:al_mahhaba_school/features/children/data/models/child_parent_model.dart';
import 'package:al_mahhaba_school/features/profile/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.name,
    required super.phone,
    required super.language,
    super.father,
    super.mother,
  });

  /// { "name": "Hany Adel", "phone": "0101****222", "language": "ar",
  ///   "father": { "name": "Hany Adel", "name_ar": "هاني عادل",
  ///   "job": "Engineer", "education": "Bachelor", "phone": "0101****222" },
  ///   "mother": { …the same… }, "children": […], "school_contact": {…} }
  /// — the children come from the children API, which has more of them.
  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    name: jsonText(json['name']),
    phone: json['phone'] as String? ?? '',
    language: json['language'] as String? ?? '',
    father: ChildParentModel.maybeFromJson(json['father']),
    mother: ChildParentModel.maybeFromJson(json['mother']),
  );
}
