import 'package:equatable/equatable.dart';

/// The signed-in parent, as the school records have them.
class ParentEntity extends Equatable {
  const ParentEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.language,
    this.fullPhone,
  });

  final int id;
  final String name;

  /// With its middle hidden, e.g. "0120****154".
  final String phone;

  /// "en" or "ar".
  final String language;

  /// [phone] in full, as typed to log in, e.g. "01201234154" (the API only
  /// sends it masked): to fill in forms. Null when not known, e.g. kept
  /// before it was.
  final String? fullPhone;

  @override
  List<Object?> get props => [id, name, phone, language, fullPhone];
}
