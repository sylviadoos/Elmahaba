import 'package:equatable/equatable.dart';

/// A file sent with a complaint message.
class ComplaintAttachmentEntity extends Equatable {
  const ComplaintAttachmentEntity({
    required this.id,
    required this.fileName,
    required this.mimeType,
    required this.size,
    required this.isAvailable,
  });

  final int id;

  /// e.g. "bus-photo.jpg".
  final String fileName;

  /// e.g. "image/jpeg".
  final String mimeType;

  /// In bytes.
  final int size;

  /// False while the school can't hand it out (any `status` but
  /// "available").
  final bool isAvailable;

  @override
  List<Object?> get props => [id, fileName, mimeType, size, isAvailable];
}
