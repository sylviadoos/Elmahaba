/// Where a complaint stands, as the school reports it.
enum ComplaintStatus {
  /// Sent; nobody at the school has picked it up yet.
  submitted,

  /// The school is on it.
  underReview,

  /// The school asked the parent something.
  awaitingParentResponse,

  /// Closed: sorted out.
  resolved,

  /// Closed without action.
  rejected,
}
