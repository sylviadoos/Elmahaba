import 'package:al_mahhaba_school/features/auth/domain/entities/register_eligibility_entity.dart';

class RegisterEligibilityModel extends RegisterEligibilityEntity {
  const RegisterEligibilityModel({
    required super.phoneMasked,
    required super.eligible,
    required super.alreadyRegistered,
  });

  factory RegisterEligibilityModel.fromJson(Map<String, dynamic> json) =>
      RegisterEligibilityModel(
        phoneMasked: json['phone_masked'] as String,
        eligible: json['eligible'] as bool,
        alreadyRegistered: json['already_registered'] as bool,
      );
}
