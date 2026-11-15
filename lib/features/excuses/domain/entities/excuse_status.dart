/// Where a medical excuse stands with the school.
enum ExcuseStatus {
  /// Sent; the school is reviewing it.
  submitted,

  /// The school asked for more: documents can be added.
  infoRequired,

  /// The day counts as medical leave.
  accepted,
  rejected,

  /// A status the app doesn't know yet.
  unknown,
}
