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

  /// The code the school texted to a child's phone, to link them.
  static const String linkChildCode = '/add-children/code';
  static const String home = '/home';
  static const String chat = '/chat';

  /// With the photos as `extra` (a `ChatImagesArgs`).
  static const String chatImages = '/chat/images';

  /// With the file as `extra` (a `ChatPdfArgs`).
  static const String chatPdf = '/chat/pdf';
  static const String results = '/results';
  static const String attendance = '/attendance';

  /// With the child to show first as `extra` (an `int` student id).
  static const String homework = '/homework';

  /// One homework on a page of its own, with a `HomeworkArgs` as `extra`
  /// when the parent holds it (else it's looked for by its id).
  static const String homeworkDetails = '/homework/:id';
  static String homeworkDetailsOf(int homeworkId) => '/homework/$homeworkId';

  /// With the child to show first as `extra` (an `int` student id).
  static const String announcements = '/announcements';

  /// One announcement on a page of its own, with an `AnnouncementArgs`
  /// as `extra`: the parent already has it, so nothing is loaded.
  static const String announcementDetails = '/announcements/:id';
  static String announcementDetailsOf(int announcementId) =>
      '/announcements/$announcementId';
  static const String fees = '/fees';
  static const String feesPay = '/fees/pay';
  static const String feesCheckout = '/fees/pay/checkout';
  static const String feeStatementPreview = '/fees/statement';

  /// The monthly certificate PDF, to look over before downloading it.
  static const String certificatePreview = '/results/certificate';
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
