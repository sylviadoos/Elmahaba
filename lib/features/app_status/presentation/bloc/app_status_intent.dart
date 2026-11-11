sealed class AppStatusIntent {
  const AppStatusIntent();
}

/// Asks the school whether parents can log in: at launch, on coming back
/// to the app, and every few minutes it stays open
/// (`AppStatusRefresher`).
final class LoadAppStatusIntent extends AppStatusIntent {
  const LoadAppStatusIntent();
}
