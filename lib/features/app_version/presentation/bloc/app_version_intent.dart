/// What changes what the app shows about its version, sent to
/// `AppVersionBloc`.
sealed class AppVersionIntent {
  const AppVersionIntent();
}

/// Asks the school about the version installed here: as the app opens, and
/// on coming back to it.
final class CheckAppVersionIntent extends AppVersionIntent {
  const CheckAppVersionIntent();
}

/// "Later" on an optional update: not shown again until the app opens
/// again. Nothing on a forced one.
final class PostponeUpdateIntent extends AppVersionIntent {
  const PostponeUpdateIntent();
}
