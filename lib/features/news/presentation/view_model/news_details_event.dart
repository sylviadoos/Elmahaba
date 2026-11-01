sealed class NewsDetailsEvent {
  const NewsDetailsEvent();
}

/// Loads one article — when the page opens and on "Try again".
final class GetNewsDetailsEvent extends NewsDetailsEvent {
  const GetNewsDetailsEvent(this.slug);

  final String slug;
}
