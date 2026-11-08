import 'package:equatable/equatable.dart';

/// The signed-in parent, as the school records have them.
class ParentEntity extends Equatable {
  const ParentEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.language,
  });

  final int id;
  final String name;

  /// With its middle hidden, e.g. "0120****154".
  final String phone;

  /// "en" or "ar".
  final String language;

  @override
  List<Object?> get props => [id, name, phone, language];
}
