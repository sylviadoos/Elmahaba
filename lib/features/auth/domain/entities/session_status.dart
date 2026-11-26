/// Whether the parent is signed in, checked when the app starts.
enum SessionStatus {
  /// Never logged in on this phone, or logged out.
  none,

  /// The saved token still works.
  active,

  /// The server ended the session; the token was forgotten.
  ended,

  /// The parent logged in on another phone, which ended this one's
  /// session; the token was forgotten.
  replaced,

  /// The account is closed — the child left the school — so logging in
  /// again won't work; the token was forgotten.
  withdrawn,
}
