/// Where an installment stands, as shown to the parent.
enum InstallmentStatus {
  paid,

  /// Past its due date and not paid.
  overdue,

  /// Not due yet.
  upcoming,

  /// Paid online; the school is checking the payment went through.
  processing,

  /// Being settled with the school; can't be paid now.
  underSettlement,

  /// A status the app doesn't know yet.
  unknown,
}
