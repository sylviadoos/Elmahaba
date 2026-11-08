import 'package:equatable/equatable.dart';

import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_item_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_screen.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/attachment_picker.dart';

/// Everything the chat shows: whose chat, its items, and the message being
/// written.
class ChatState extends Equatable {
  const ChatState({
    this.children = const [],
    this.isRequested = false,
    this.studentId,
    this.chat = const BaseState.initial(),
    this.screensWithNews = const {},
    this.othersUnread = false,
    this.downloadingId,
    this.noReply = const {},
    this.aboutId,
    this.replyingTo,
    this.draft = '',
    this.attachments = const [],
    this.isSending = false,
    this.upload,
    this.sendError,
  });

  /// The parent's children.
  final List<ChildEntity> children;

  /// Whether a chat was asked for yet (the children may still be loading).
  final bool isRequested;

  /// The child whose chat is shown, whom messages are about; null for
  /// everything (all children, or none).
  final int? studentId;

  /// Everything loaded, oldest first. `moreLoading` while older items load;
  /// an error with data when they didn't.
  final BaseState<ChatPageEntity> chat;

  /// The screens the school's unread items lead to, as they loaded: what
  /// the parent saw here stays dotted until the chat opens again.
  final Set<ChatScreen> screensWithNews;

  /// The other children have unread items (see [showing]).
  final bool othersUnread;

  /// The attachment downloading now.
  final int? downloadingId;

  /// Items the school refused an answer to since they loaded.
  final Set<String> noReply;

  /// With all children shown, the one the message is about; null for none
  /// of them (a general message).
  final int? aboutId;

  /// The item the message answers.
  final ChatItemEntity? replyingTo;

  /// What's typed in the message box.
  final String draft;

  /// The files to send with it, and the ones that won't go, which say why.
  final List<PickedAttachment> attachments;

  final bool isSending;

  /// How far the message and its files got, while it's sent.
  final UploadProgress? upload;

  /// Why the last message wasn't sent, shown above the box.
  final AppException? sendError;

  ChatPageEntity? get page => chat.data;

  /// Every child's chat, in one (two or more children).
  bool get showsAll => studentId == null && children.length > 1;

  /// Where the child shown is in [children]; -1 for none.
  int get shownIndex =>
      children.indexWhere((child) => child.studentId == studentId);

  /// The message box is there: the school takes messages, about the child
  /// shown or one picked from all of them.
  bool get canWrite {
    final page = this.page;
    return page != null && page.canSend && (shownIndex >= 0 || showsAll);
  }

  /// [item] shows "Reply".
  bool canReplyTo(ChatItemEntity item) =>
      canWrite &&
      item.canReply &&
      !item.isDeleted &&
      !noReply.contains(item.key);

  /// Another file fits, by count and by total size.
  bool get canAttachMore => attachments.canAddMore;

  /// "Send" works: text, or a file that can go (files alone make a
  /// message), and no file picked only to be refused.
  bool get canSendMessage =>
      !isSending &&
      !attachments.allInvalid &&
      (draft.trim().isNotEmpty || attachments.valid.isNotEmpty);

  /// [page] shown with its dots: the screens its unread items lead to, and
  /// whether the other children have unread ones. Worked out once, as it
  /// loads, so drawing the header doesn't go through every item.
  ChatState showing(BaseState<ChatPageEntity> chat) {
    final page = chat.data;
    if (page == null) {
      return copyWith(
        chat: chat,
        screensWithNews: const {},
        othersUnread: false,
      );
    }
    final unreadHere = page.items.where((item) => !item.isRead).length;
    return copyWith(
      chat: chat,
      screensWithNews: {
        for (final item in page.items)
          if (!item.isRead && !item.isDeleted) ?item.link?.screen,
      },
      // The whole chat's unread is more than this child's here. (Unread
      // items of this child older than what's loaded count too.) None
      // while all are shown.
      othersUnread: studentId != null && page.unread > unreadHere,
    );
  }

  ChatState copyWith({
    List<ChildEntity>? children,
    bool? isRequested,
    int? Function()? studentId,
    BaseState<ChatPageEntity>? chat,
    Set<ChatScreen>? screensWithNews,
    bool? othersUnread,
    int? Function()? downloadingId,
    Set<String>? noReply,
    int? Function()? aboutId,
    ChatItemEntity? Function()? replyingTo,
    String? draft,
    List<PickedAttachment>? attachments,
    bool? isSending,
    UploadProgress? Function()? upload,
    AppException? Function()? sendError,
  }) => ChatState(
    children: children ?? this.children,
    isRequested: isRequested ?? this.isRequested,
    studentId: studentId != null ? studentId() : this.studentId,
    chat: chat ?? this.chat,
    screensWithNews: screensWithNews ?? this.screensWithNews,
    othersUnread: othersUnread ?? this.othersUnread,
    downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
    noReply: noReply ?? this.noReply,
    aboutId: aboutId != null ? aboutId() : this.aboutId,
    replyingTo: replyingTo != null ? replyingTo() : this.replyingTo,
    draft: draft ?? this.draft,
    attachments: attachments ?? this.attachments,
    isSending: isSending ?? this.isSending,
    upload: upload != null ? upload() : this.upload,
    sendError: sendError != null ? sendError() : this.sendError,
  );

  @override
  List<Object?> get props => [
    children,
    isRequested,
    studentId,
    chat,
    screensWithNews,
    othersUnread,
    downloadingId,
    noReply,
    aboutId,
    replyingTo,
    draft,
    attachments,
    isSending,
    upload,
    sendError,
  ];
}
