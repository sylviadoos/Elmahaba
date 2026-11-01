import 'package:al_mahhaba_school/features/contact/domain/entities/contact_message_entity.dart';

/// [ContactMessageEntity] as sent to `POST mobile/contact-us/send`.
class ContactMessageModel extends ContactMessageEntity {
  const ContactMessageModel({
    required super.firstName,
    required super.lastName,
    super.educationType,
    super.stage,
    super.phone,
    super.email,
    required super.message,
  });

  factory ContactMessageModel.fromEntity(ContactMessageEntity entity) =>
      ContactMessageModel(
        firstName: entity.firstName,
        lastName: entity.lastName,
        educationType: entity.educationType,
        stage: entity.stage,
        phone: entity.phone,
        email: entity.email,
        message: entity.message,
      );

  /// Optional fields are left out when empty.
  Map<String, dynamic> toJson() {
    final educationType = this.educationType;
    final stage = this.stage;
    final phone = this.phone;
    final email = this.email;

    return {
      'first_name': firstName,
      'last_name': lastName,
      if (educationType != null)
        'education_type': _educationTypeValues[educationType],
      if (stage != null) 'stage': _stageValues[stage],
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      'message': message,
    };
  }

  /// The values the website's form sends.
  static const _educationTypeValues = {EducationType.language: 'Language'};

  static const _stageValues = {
    SchoolStage.babyClass: 'Baby Class',
    SchoolStage.kg1: 'KG1',
    SchoolStage.kg2: 'KG2',
    SchoolStage.primary1: 'First Primary',
    SchoolStage.primary2: 'Second Primary',
    SchoolStage.primary3: 'Third Primary',
    SchoolStage.primary4: 'Fourth Primary',
    SchoolStage.primary5: 'Fifth Primary',
  };
}
