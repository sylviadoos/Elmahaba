sealed class AttendanceEvent {
  const AttendanceEvent();
}

/// Loads a child's attendance in a month, unless it's already shown or
/// loading. Also "Try again".
final class LoadAttendanceEvent extends AttendanceEvent {
  const LoadAttendanceEvent({required this.childId, required this.month});

  /// The child's `studentId`.
  final int childId;

  /// Its first day.
  final DateTime month;
}

/// Asks the school again for the month shown, which stays shown until the
/// answer comes: a day may have changed (an excuse accepted, attendance
/// taken). After a failure, it's "Try again".
final class RefreshAttendanceEvent extends AttendanceEvent {
  const RefreshAttendanceEvent();
}
