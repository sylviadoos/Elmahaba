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
  static const String forgotPassword = '/forgot-password';
  static const String resetCode = '/forgot-password/code';
  static const String newPassword = '/forgot-password/new';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String addChildren = '/add-children';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String results = '/results';
  static const String attendance = '/attendance';

  /// With the child to show first as `extra` (an `int` student id).
  static const String homework = '/homework';
  static const String fees = '/fees';
  static const String feesPay = '/fees/pay';
  static const String feesCheckout = '/fees/pay/checkout';
  static const String feeStatementPreview = '/fees/statement';
  static const String settings = '/settings';
  static const String profile = '/settings/profile';
  static const String changePassword = '/settings/change-password';
  static const String childDetails = '/children/:id';
  static String childDetailsOf(int childId) => '/children/$childId';
  static const String complaints = '/complaints';
  static const String newComplaint = '/complaints/new';
  static const String complaintDetails = '/complaints/:id';
  static String complaintDetailsOf(int complaintId) =>
      '/complaints/$complaintId';
  static const String newExcuse = '/excuses/new';
  static const String excuseDetails = '/excuses/:childId/:id';
  static String excuseDetailsOf(int childId, int excuseId) =>
      '/excuses/$childId/$excuseId';
}
