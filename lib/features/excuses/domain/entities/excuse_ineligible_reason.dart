/// Why no excuse can be sent for a day.
enum ExcuseIneligibleReason {
  /// The days to send one in are over.
  windowClosed,

  /// One for it is being reviewed.
  alreadyActive,

  /// The child wasn't absent that day.
  notAbsent,

  /// The school hasn't set the days to send one in yet.
  windowNotConfigured,

  /// The child left or graduated.
  readOnlyChild,

  /// A reason the app doesn't know yet.
  unknown,
}
