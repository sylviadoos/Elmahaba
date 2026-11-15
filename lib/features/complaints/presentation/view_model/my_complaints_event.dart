sealed class MyComplaintsEvent {
  const MyComplaintsEvent();
}

/// Loads the first page, dropping any loaded before. With [refresh], the
/// ones shown stay until the new ones arrive, and if that fails.
final class LoadComplaintsEvent extends MyComplaintsEvent {
  const LoadComplaintsEvent({this.refresh = false});

  final bool refresh;
}

/// Adds the next page under the loaded ones.
final class LoadMoreComplaintsEvent extends MyComplaintsEvent {
  const LoadMoreComplaintsEvent();
}
