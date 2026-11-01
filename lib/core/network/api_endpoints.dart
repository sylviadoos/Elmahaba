/// API paths, relative to `AppConfig.baseUrl` (no leading slash).
abstract final class ApiEndpoints {
  // TODO: replace with the school API's real endpoints.
  static const String signin = 'auth/signin';

  static const String news = 'mobile/news';
  static String newsDetails(String slug) =>
      'mobile/news/${Uri.encodeComponent(slug)}';

  static const String contactUs = 'mobile/contact-us';
  static const String contactUsSend = 'mobile/contact-us/send';
}
