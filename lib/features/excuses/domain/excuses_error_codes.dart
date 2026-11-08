/// The `code`s the excuses API fails with that the app acts on.
abstract final class ExcusesErrorCodes {
  /// The days to send one in are over.
  static const String windowClosed = 'excuse_window_closed';

  /// One for that day is being reviewed.
  static const String alreadyActive = 'excuse_already_active';

  /// The day can't have one (not an absence, no window set…).
  static const String notEligible = 'excuse_not_eligible';
  static const String recordNotFound = 'attendance_record_not_found';
  static const String readOnlyChild = 'read_only_child';
  static const String childNotAvailable = 'child_not_available';

  /// Documents can only be added when the school asked for them.
  static const String notAwaitingDocuments = 'excuse_not_awaiting_documents';
}
