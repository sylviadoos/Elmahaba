import 'package:equatable/equatable.dart';

/// A file sent with a medical excuse.
class ExcuseDocumentEntity extends Equatable {
  const ExcuseDocumentEntity({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.isAvailable,
  });

  final int id;

  /// e.g. "medical-report.pdf".
  final String fileName;

  /// e.g. "application/pdf".
  final String mimeType;

  /// In bytes.
  final int size;

  /// False while the school can't hand it out (any `status` but
  /// "available").
  final bool isAvailable;

  @override
  List<Object?> get props => [id, fileName, mimeType, size, isAvailable];
}
