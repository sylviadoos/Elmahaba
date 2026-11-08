/// How a child's school day was recorded.
enum AttendanceStatus {
  present,
  absent,
  late,

  /// Absent with an excuse, or on medical leave.
  excused,

  /// A status the app doesn't know yet.
  unknown,
}
