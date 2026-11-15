/// The complaints API's error `code`s the app acts on.
abstract final class ComplaintsErrorCodes {
  /// The category picked was withdrawn; the list needs loading again.
  static const String categoryNotAvailable = 'category_not_available';

  /// The school closed the complaint; it takes no more replies.
  static const String complaintClosed = 'complaint_closed';

  /// The school is on the complaint and hasn't asked the parent anything.
  static const String complaintReplyNotAllowed = 'complaint_reply_not_allowed';

  /// A file wasn't accepted (MSG-18); the error names it in `file_name`.
  static const String fileRejected = 'file_rejected';
}
