/// API paths, relative to the server's base URL (no leading slash).
abstract final class ApiEndpoints {
  // School website — AppConfig.websiteBaseUrl (ApiNames.website).

  static const String news = 'mobile/news';
  static String newsDetails(String slug) =>
      'mobile/news/${Uri.encodeComponent(slug)}';

  static const String contactUs = 'mobile/contact-us';
  static const String contactUsSend = 'mobile/contact-us/send';

  // School system — AppConfig.schoolBaseUrl (ApiNames.school).

  /// GET: whether parents can log in now (`enabled`).
  static const String appStatus = 'mobile/app-status';

  static const String login = 'mobile/login';
  static const String session = 'v1/parent/auth/session';
  static const String changePassword = 'v1/parent/auth/change-password';
  static const String registerCheckPhone = 'mobile/register/check-phone';
  static const String registerComplete = 'mobile/register/complete';
  static const String forgotPassword = 'mobile/forgot-password';

  /// POST: the school texts a code (SMS Misr) — when Firebase can't.
  static const String otpRequest = 'v1/parent/auth/otp/request';

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

  /// POST `{verification_token, code}`: links the child [linkChild] texted
  /// a code for (`otp_required`).
  static const String linkChildVerify = 'v1/parent/children/link/verify-otp';

  /// POST `{verification_token}`: texts that code again.
  static const String linkChildResend = 'v1/parent/children/link/resend-otp';
  static String childDetails(int childId) =>
      'v1/parent/children/$childId/details';

  /// GET: everything Home shows — attendance, fees, messages, and the
  /// newest announcements, homework and results.
  static String childDashboard(int childId) =>
      'v1/parent/children/$childId/dashboard';

  /// GET: the published results, in full, newest first. Narrowed with
  /// `?result_type=monthly` (or `term`), and for a month with
  /// `&month=10&year=2026`.
  static String childResults(int childId) =>
      'v1/parent/children/$childId/results-v2';

  /// GET, with `?page=1&per_page=10`: the school's announcements to the
  /// child's parents, newest first.
  static String childAnnouncements(int childId) =>
      'v1/parent/children/$childId/announcements';

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

  /// DELETE: drops the optional fee from the child's fees again, while
  /// nothing is paid on it. [feeId] is the statement line's `fee_id`.
  static String optionalFee(int childId, int feeId) =>
      'v1/parent/children/$childId/fees/optional/$feeId';

  /// POST: adds the optional fee to the child's fees, at once.
  static String confirmOptionalFee(int childId, int feeId) =>
      '${optionalFee(childId, feeId)}/confirm';
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
