/// What a result covers: one month, a term, or something else the school
/// publishes.
enum ResultKind {
  monthly,
  term,
  other;

  /// From the API's `result_type`: "monthly", "term".
  static ResultKind of(String? type) => switch (type?.trim().toLowerCase()) {
    'monthly' => monthly,
    'term' => term,
    _ => other,
  };
}
