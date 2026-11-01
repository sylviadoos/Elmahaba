import 'package:equatable/equatable.dart';

/// A visitor's message to the school from the Contact page.
class ContactMessageEntity extends Equatable {
  const ContactMessageEntity({
    required this.firstName,
    required this.lastName,
    this.educationType,
    this.stage,
    this.phone,
    this.email,
    required this.message,
  });

  final String firstName;
  final String lastName;
  final EducationType? educationType;
  final SchoolStage? stage;

  /// Local Egyptian mobile, e.g. "01012345678".
  final String? phone;
  final String? email;
  final String message;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    educationType,
    stage,
    phone,
    email,
    message,
  ];
}

/// The education types the school offers (as on the website's form).
enum EducationType { language }

/// The stages the school takes students into (as on the website's form).
enum SchoolStage {
  babyClass,
  kg1,
  kg2,
  primary1,
  primary2,
  primary3,
  primary4,
  primary5,
}
