/// The chat API's error `code`s the app acts on.
abstract final class ChatErrorCodes {
  /// The item answered doesn't take answers (any more).
  static const String replyNotAllowed = 'reply_not_allowed';

  /// The school closed the chat (409): it can only be read.
  static const String chatClosed = 'chat_closed';

  /// A file wasn't accepted (MSG-18); the error names it in `file_name`.
  static const String fileRejected = 'file_rejected';
}
