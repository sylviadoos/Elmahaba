import 'package:equatable/equatable.dart';

/// One of the school's choices (e.g. gender), with its names in English
/// and Arabic.
class LabeledValueEntity extends Equatable {
  const LabeledValueEntity({
    required this.value,
    required this.label,
    required this.labelAr,
  });

  /// e.g. "female".
  final String value;

  /// e.g. "Female".
  final String label;

  /// e.g. "أنثى"; empty when the school has none.
  final String labelAr;

  @override
  List<Object?> get props => [value, label, labelAr];
}
