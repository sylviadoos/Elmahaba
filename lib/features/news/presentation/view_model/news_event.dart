sealed class NewsEvent {
  const NewsEvent();
}

/// Loads the news list — when the page opens and on "Try again".
final class GetNewsEvent extends NewsEvent {
  const GetNewsEvent();
}
