/// Records how parents use the app (Microsoft Clarity: session replays and
/// heatmaps), to see where they struggle. Does nothing while recording is
/// off (debug builds, unless asked for: see `AppConfig.clarityEnabled`).
abstract interface class SessionRecorder {
  /// Recording is on in this build.
  bool get isEnabled;

  /// The sessions from now on are the parent [parentId]'s, to find them by
  /// on the dashboard. Their id only, nothing personal.
  void identify(int parentId);

  /// The parent logged out: a new session starts, so whoever signs in next
  /// isn't counted as them.
  void forget();

  /// The screen on show, by its route, e.g. "/complaints/:id" (ids left
  /// out, so each screen is one page on the dashboard).
  void showScreen(String name);
}
