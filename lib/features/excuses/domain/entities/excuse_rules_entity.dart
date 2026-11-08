import 'package:equatable/equatable.dart';

/// The school's limits for an excuse's documents.
class ExcuseRulesEntity extends Equatable {
  const ExcuseRulesEntity({
    required this.windowDays,
    required this.maxDocuments,
    required this.allowedTypes,
    required this.maxFileMegabytes,
  });

  /// As documented, for what the API leaves out.
  static const ExcuseRulesEntity defaults = ExcuseRulesEntity(
    windowDays: 3,
    maxDocuments: 5,
    allowedTypes: ['jpg', 'png', 'pdf'],
    maxFileMegabytes: 10,
  );

  /// Days after an absence to send one in.
  final int windowDays;
  final int maxDocuments;

  /// Extensions, e.g. ["jpg", "png", "pdf"].
  final List<String> allowedTypes;
  final int maxFileMegabytes;

  @override
  List<Object?> get props => [
    windowDays,
    maxDocuments,
    allowedTypes,
    maxFileMegabytes,
  ];
}
