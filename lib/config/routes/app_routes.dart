/// Route paths. Add a constant here for every new screen.
abstract final class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Visitor (not logged in)
  static const String explore = '/explore';
  static const String about = '/about';
  static const String news = '/news';
  static const String newsArticle = '/news/:slug';
  static String newsArticleOf(String slug) =>
      '/news/${Uri.encodeComponent(slug)}';
  static const String contact = '/contact';
  static const String contactMessage = '/contact/message';

  // Parent account
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String addChildren = '/add-children';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String results = '/results';
  static const String attendance = '/attendance';
  static const String fees = '/fees';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
}
