/// API paths, relative to the server's base URL (no leading slash).
abstract final class ApiEndpoints {
  // School website — AppConfig.websiteBaseUrl (ApiNames.website).

  static const String news = 'mobile/news';
  static String newsDetails(String slug) =>
      'mobile/news/${Uri.encodeComponent(slug)}';

  static const String contactUs = 'mobile/contact-us';
  static const String contactUsSend = 'mobile/contact-us/send';

  // School system — AppConfig.schoolBaseUrl (ApiNames.school).

  static const String login = 'mobile/login';
  static const String session = 'v1/parent/auth/session';
  static const String changePassword = 'v1/parent/auth/change-password';
  static const String registerCheckPhone = 'mobile/register/check-phone';
  static const String registerComplete = 'mobile/register/complete';
  static const String forgotPassword = 'mobile/forgot-password';

  static const String profile = 'v1/parent/profile';
  static const String profileLanguage = 'v1/parent/profile/language';

  /// DELETE: deletes the parent's account.
  static const String account = 'v1/parent/account';

  /// PUT: where to send the parent's notifications (this phone's FCM
  /// token).
  static const String pushToken = 'v1/parent/devices/push-token';

  /// GET / PUT (`{"preferences": {"fees": false}}`): which kinds of
  /// notifications ring the phone.
  static const String notificationPreferences =
      'v1/parent/notification-preferences';

  static const String children = 'v1/parent/children';
  static const String linkChild = 'v1/parent/children/link';
  static String childDetails(int childId) =>
      'v1/parent/children/$childId/details';
  static String childDashboard(int childId) =>
      'v1/parent/children/$childId/dashboard';
  static String childResult(int childId, int resultId) =>
      'v1/parent/children/$childId/results/$resultId';

  /// GET: the newest 3, newest first, with how many there are and how
  /// many the parent hasn't seen.
  static String childAnnouncementsLatest(int childId) =>
      'v1/parent/children/$childId/announcements/latest';
  static String childHomeworkLatest(int childId) =>
      'v1/parent/children/$childId/homework/latest';
  static String childResultsLatest(int childId) =>
      'v1/parent/children/$childId/results/latest';

  /// With `?month=2026-10`.
  static String childAttendance(int childId) =>
      'v1/parent/children/$childId/attendance';

  /// With `?status=all&subject_id=3&page=1&per_page=20`.
  static String childHomework(int childId) =>
      'v1/parent/children/$childId/homework';

  /// GET (with `?date=2026-11-04` for one day): the absences a medical
  /// excuse can be (or was) sent for.
  static String childExcuseAbsences(int childId) =>
      'v1/parent/children/$childId/excuses/absences';

  /// POST (multipart): a medical excuse.
  static String childExcuses(int childId) =>
      'v1/parent/children/$childId/excuses';
  static String childExcuse(int childId, int excuseId) =>
      'v1/parent/children/$childId/excuses/$excuseId';

  /// POST (multipart `documents[]`): more documents, when the school asks.
  static String childExcuseDocuments(int childId, int excuseId) =>
      'v1/parent/children/$childId/excuses/$excuseId/documents';

  /// GET: a link to the file, valid for 10 minutes.
  static String childExcuseDocument(
    int childId,
    int excuseId,
    int documentId,
  ) => 'v1/parent/children/$childId/excuses/$excuseId/documents/$documentId';
  static String childFees(int childId) => 'v1/parent/children/$childId/fees';
  static String childFeesPayOnline(int childId) =>
      'v1/parent/children/$childId/fees/pay-online';

  /// GET (with `?page=1&per_page=20`): the parent's complaints. POST
  /// (multipart): sends one.
  static const String complaints = 'v1/parent/complaints';
  static const String complaintCategories = 'v1/parent/complaints/categories';
  static String complaint(int complaintId) =>
      'v1/parent/complaints/$complaintId';

  /// POST (multipart): the parent's reply.
  static String complaintReplies(int complaintId) =>
      'v1/parent/complaints/$complaintId/replies';

  /// GET: the file itself.
  static String complaintAttachment(int complaintId, int attachmentId) =>
      'v1/parent/complaints/$complaintId/attachments/$attachmentId';

  /// GET (with `?limit=30`, and `student_id` / `before`): the chat with the
  /// school, oldest first.
  static const String chat = 'v1/parent/chat';
  static const String chatUnreadCount = 'v1/parent/chat/unread-count';

  /// POST (multipart): the parent's message.
  static const String chatMessages = 'v1/parent/chat/messages';

  /// POST (`{"items": [keys]}`): what the parent saw.
  static const String chatRead = 'v1/parent/chat/read';

  /// GET: a link to the file, valid for a few minutes.
  static String chatAttachment(int attachmentId) =>
      'v1/parent/chat/attachments/$attachmentId';
}
