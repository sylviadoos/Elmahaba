import 'package:equatable/equatable.dart';

/// A complaint the parent is sending.
class NewComplaintEntity extends Equatable {
  const NewComplaintEntity({
    required this.categoryId,
    this.studentId,
    required this.description,
    this.attachments = const [],
    required this.clientUuid,
  });

  final int categoryId;

  /// The child it's about; null for a general complaint.
  final int? studentId;
  final String description;

  /// The paths of the files sent with it (see [ComplaintAttachmentRules]).
  final List<String> attachments;

  /// Names this complaint, so sending it again after a lost answer doesn't
  /// make a second one.
  final String clientUuid;

  @override
  List<Object?> get props => [
    categoryId,
    studentId,
    description,
    attachments,
    clientUuid,
  ];
}

/// The files a complaint takes, as the API checks them.
abstract final class ComplaintAttachmentRules {
  /// "jpeg" too: the server checks the file's type, which is the same.
  static const List<String> photoExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> documentExtensions = ['pdf', 'doc', 'docx'];
  static const List<String> extensions = [
    ...photoExtensions,
    ...documentExtensions,
  ];
  static const int maxFiles = 5;
  static const int maxMegabytes = 10;
  static const int maxBytes = maxMegabytes * 1024 * 1024;

  /// All of them together.
  static const int maxTotalMegabytes = 25;
  static const int maxTotalBytes = maxTotalMegabytes * 1024 * 1024;
}
