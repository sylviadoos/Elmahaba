/// Whether the parent is signed in, checked when the app starts.
enum SessionStatus {
  /// Never logged in on this phone, or logged out.
  none,

  /// The saved token still works.
  active,

  /// The server ended the session; the token was forgotten.
  ended,
}
