/// How a child's school day was recorded.
enum AttendanceStatus {
  /// Came to school on time.
  present,
  absent,

  /// Came to school, late. Counts as attended.
  late,

  /// Absent with an excuse, or on medical leave.
  excused,

  /// A status the app doesn't know yet.
  unknown,
}
