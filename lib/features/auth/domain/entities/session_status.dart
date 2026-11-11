/// Whether the parent is signed in, checked when the app starts.
enum SessionStatus {
  /// Never logged in on this phone, or logged out.
  none,

  /// The saved token still works.
  active,

  /// The server ended the session; the token was forgotten.
  ended,

  /// The account is closed — the child left the school — so logging in
  /// again won't work; the token was forgotten.
  withdrawn,
}
