import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import 'package:al_mahhaba_school/core/base/base_bloc.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/core/base/upload_progress.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/chat_error_codes.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/chat_page_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/entities/new_chat_message_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_cached_chat_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/send_chat_message_use_case.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_effect.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_intent.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_state.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/extensions/picked_attachment.dart';

/// School chat (MVI): whose chat is shown (at once as it last loaded, then
/// as it is now), its items (older ones as the parent scrolls up, each
/// marked read once it comes on screen), the message being written and
/// sending it, and the files. One per Chat page; closing it stops what it
/// was still loading or sending.
@injectable
class ChatBloc extends BaseBloc<ChatIntent, ChatState, ChatEffect> {
  ChatBloc(
    this._getChat,
    this._getCachedChat,
    this._sendMessage,
    this._markRead,
    this._downloadAttachment,
    this._previewAttachment,
  ) : super(const ChatState()) {
    on<ChildrenChangedIntent>(_onChildrenChanged);
    on<SelectedChildChangedIntent>((intent, emit) {
      if (!state.isRequested || intent.studentId == state.studentId) {
        return null;
      }
      return _show(intent.studentId, emit);
    });
    on<ShowChildChatIntent>((intent, emit) {
      if (intent.studentId case final studentId?) {
        emitEffect(ChildPickedEffect(studentId));
      }
      return _show(intent.studentId, emit);
    });
    on<RetryChatIntent>((_, emit) => _show(state.studentId, emit));
    on<RefreshChatIntent>(_onRefresh);
    on<LoadOlderChatIntent>(_onLoadOlder);
    on<ItemSeenIntent>(_onItemSeen);
    on<ItemsReadChangedIntent>(_onItemsReadChanged);
    on<PickRecipientIntent>(_onPickRecipient);
    on<StartReplyIntent>(_onStartReply);
    on<CancelReplyIntent>(_onCancelReply);
    on<EditDraftIntent>(_onEditDraft);
    on<AddAttachmentsIntent>(_onAddAttachments);
    on<RemoveAttachmentIntent>(_onRemoveAttachment);
    on<SendMessageIntent>(_onSend);
    on<OpenAttachmentIntent>(_onOpenAttachment);
    on<LoadImageIntent>(_onLoadImage);
  }

  final GetChatUseCase _getChat;
  final GetCachedChatUseCase _getCachedChat;
  final SendChatMessageUseCase _sendMessage;
  final MarkChatReadUseCase _markRead;
  final DownloadChatAttachmentUseCase _downloadAttachment;
  final PreviewChatAttachmentUseCase _previewAttachment;

  /// How long items seen are gathered, to mark them read in one request.
  static const Duration _markDelay = Duration(milliseconds: 400);

  /// How many of the newest items a refresh asks for, not a full page: it
  /// usually finds one new, or none, and a small answer comes back sooner.
  static const int _refreshLimit = 5;

  /// Counts the chats asked for: an answer for an earlier one is dropped.
  int _loads = 0;

  /// What's on its way, to stop when it's no longer needed.
  CancelHandle? _newest;
  CancelHandle? _older;
  CancelHandle? _sending;
  CancelHandle? _downloading;
  CancelHandle? _refreshing;

  /// The photos shown in the chat, asked for the child shown (none on
  /// "All").
  late final ChatImageLoads _imageLoads = ChatImageLoads(
    download: (attachment, {cancel}) => _downloadAttachment(
      attachment,
      studentId: state.studentId,
      cancel: cancel,
    ),
    preview: (attachment, {cancel}) => _previewAttachment(
      attachment,
      studentId: state.studentId,
      cancel: cancel,
    ),
  );

  /// The items marked read, or being marked, so none is sent twice.
  final Set<String> _marked = {};

  /// Items seen since the last request, marked read once [_markTimer] ends.
  final Set<String> _seen = {};
  Timer? _markTimer;

  /// The message being written. Kept when sending fails, so sending it
  /// again can't post it twice.
  String _messageUuid = const Uuid().v4();

  @override
  Future<void> close() {
    _newest?.cancel();
    _older?.cancel();
    _sending?.cancel();
    _downloading?.cancel();
    _refreshing?.cancel();
    _imageLoads.cancelAll();
    // What was seen just before leaving is still marked read.
    _markTimer?.cancel();
    unawaited(_markSeen());
    return super.close();
  }

  /// The children loaded or changed: the one shown was unlinked, or they're
  /// here at last. All of them stay shown while there are two or more.
  Future<void> _onChildrenChanged(
    ChildrenChangedIntent intent,
    Emitter<ChatState> emit,
  ) async {
    final children = intent.children;
    if (children != null) emit(state.copyWith(children: children));
    // Still loading: shown once they're here.
    if (intent.isLoading && (state.isRequested || children == null)) return;
    final list = children ?? const <ChildEntity>[];
    final studentId = state.studentId;
    final stillShown = studentId == null
        ? list.length > 1
        : list.any((child) => child.studentId == studentId);
    if (state.isRequested && stillShown) return;
    // Opening: the child every page shows.
    final selected = state.isRequested ? null : intent.selectedId;
    final pick = list.any((child) => child.studentId == selected)
        ? selected
        : list.firstOrNull?.studentId;
    if (state.isRequested && pick == studentId) return;
    await _show(pick, emit);
  }

  /// Loads the chat of the child with [studentId] (everything without
  /// one), shown meanwhile as it last loaded, if it did. An answer started
  /// is dropped: the item may not be in it.
  Future<void> _show(int? studentId, Emitter<ChatState> emit) async {
    final load = ++_loads;
    _newest?.cancel();
    _older?.cancel();
    final cancel = _newest = CancelHandle();
    final cached = _getCachedChat(studentId);
    emit(
      state
          .copyWith(
            isRequested: true,
            studentId: () => studentId,
            aboutId: () => null,
            replyingTo: () => null,
          )
          .showing(
            cached == null
                ? const BaseState.loading()
                : BaseState.success(cached),
          ),
    );
    final result = await _getChat(studentId: studentId, cancel: cancel);
    // Another child picked meanwhile.
    if (load != _loads) return;
    result.when(
      success: (page) => emit(state.showing(BaseState.success(page))),
      failure: (exception) {
        if (exception is CancelledException) return;
        // As it last loaded, still: why it isn't new goes in a snack bar.
        if (cached != null) return emitEffect(ShowErrorEffect(exception));
        emit(state.showing(BaseState.error(exception)));
      },
    );
  }

  /// The newest items again, joined to what's shown (older ones loaded
  /// while scrolling stay). Only while the chat shows and isn't loading;
  /// one at a time. Dropped when another child is picked meanwhile, and
  /// when it doesn't load: what's shown stays, no snack bar.
  Future<void> _onRefresh(
    RefreshChatIntent intent,
    Emitter<ChatState> emit,
  ) async {
    if (!state.isRequested ||
        state.chat.state != StateType.success ||
        state.chat.data == null ||
        _refreshing != null) {
      return;
    }
    final load = _loads;
    final cancel = _refreshing = CancelHandle();
    final studentId = state.studentId;
    final before = state.chat.data!;
    // Just the latest few: a refresh usually finds one new item, or none.
    var result = await _getChat(
      studentId: studentId,
      limit: _refreshLimit,
      cancel: cancel,
    );
    // More came than that (back after a while): none of them is shown, so
    // those between could be missing. The full page instead.
    if (result case Success(
      data: final latest,
    ) when load == _loads && _leavesGap(latest, before)) {
      result = await _getChat(studentId: studentId, cancel: cancel);
    }
    _refreshing = null;
    if (load != _loads) return;
    final shown = state.chat.data;
    if (shown == null) return;
    result.when(
      success: (newest) =>
          emit(state.showing(BaseState.success(newest.after(shown)))),
      failure: (exception) => debugPrint('Refreshing the chat: $exception'),
    );
  }

  /// Whether [latest] (the newest few) could leave items out between it and
  /// [shown]: there are more than it brought, and none of it is shown.
  static bool _leavesGap(ChatPageEntity latest, ChatPageEntity shown) {
    if (!latest.hasMore || latest.items.isEmpty) return false;
    final shownKeys = {for (final item in shown.items) item.key};
    return !latest.items.any((item) => shownKeys.contains(item.key));
  }

  Future<void> _onLoadOlder(
    LoadOlderChatIntent intent,
    Emitter<ChatState> emit,
  ) async {
    final loaded = state.chat.data;
    if (loaded == null ||
        !loaded.hasMore ||
        state.chat.state == StateType.moreLoading) {
      return;
    }
    final load = _loads;
    final cancel = _older = CancelHandle();
    emit(
      state.copyWith(
        chat: BaseState.all(
          state: StateType.moreLoading,
          data: loaded,
          exception: null,
        ),
      ),
    );
    final result = await _getChat(
      studentId: state.studentId,
      before: loaded.nextBefore,
      cancel: cancel,
    );
    // Loaded again from the newest meanwhile.
    if (load != _loads) return;
    // With any message sent meanwhile.
    final shown = state.chat.data ?? loaded;
    result.when(
      success: (older) =>
          emit(state.showing(BaseState.success(shown.after(older)))),
      failure: (exception) => emit(
        state.copyWith(
          chat: BaseState.all(
            state: StateType.error,
            data: shown,
            exception: exception,
          ),
        ),
      ),
    );
  }

  /// Gathered for a moment, then marked read together.
  void _onItemSeen(ItemSeenIntent intent, Emitter<ChatState> emit) {
    if (_marked.contains(intent.key) || !_seen.add(intent.key)) return;
    _markTimer?.cancel();
    _markTimer = Timer(_markDelay, _markSeen);
  }

  /// Tells the school the parent saw the items gathered: they show as read
  /// at once, not when the school answers; what's still unread goes to the
  /// badge on Chat.
  Future<void> _markSeen() async {
    if (_seen.isEmpty) return;
    final keys = _seen.toSet();
    _seen.clear();
    _marked.addAll(keys);
    // Not after leaving: there's nothing on screen to change.
    void show(bool isRead, {int? unread}) {
      if (!isClosed) {
        add(ItemsReadChangedIntent(keys, isRead: isRead, unread: unread));
      }
    }

    show(true);
    // Read for the child shown, as the school asks of every chat request:
    // an item about two children stays new for the other. On "All", none.
    final result = await _markRead(keys.toList(), studentId: state.studentId);
    result.when(
      success: (unread) => show(true, unread: unread),
      failure: (exception) {
        // New again, and tried again when they come on screen again.
        _marked.removeAll(keys);
        show(false);
        debugPrint('Marking chat items read: $exception');
      },
    );
  }

  /// The items marked read (or not) in what's shown, as it is: loading
  /// older ones or not.
  void _onItemsReadChanged(
    ItemsReadChangedIntent intent,
    Emitter<ChatState> emit,
  ) {
    final chat = state.chat;
    final page = chat.data;
    if (page == null) return;
    emit(
      state.showing(
        BaseState.all(
          state: chat.state,
          data: page.withRead(
            intent.keys,
            isRead: intent.isRead,
            unread: intent.unread,
          ),
          exception: chat.exception,
        ),
      ),
    );
  }

  void _onPickRecipient(PickRecipientIntent intent, Emitter<ChatState> emit) =>
      emit(_withoutNotes.copyWith(aboutId: () => intent.studentId));

  /// The message answers the item, ready to type. With all children shown,
  /// it's about the child the item is about, when that's one of them.
  void _onStartReply(StartReplyIntent intent, Emitter<ChatState> emit) {
    final item = intent.item;
    final about = item.children.length == 1
        ? item.children.single.studentId
        : null;
    final aboutOne =
        state.studentId == null &&
        state.children.any((child) => child.studentId == about);
    emit(
      _withoutNotes.copyWith(
        replyingTo: () => item,
        aboutId: aboutOne ? () => about : null,
      ),
    );
    emitEffect(const FocusComposerEffect());
  }

  void _onCancelReply(CancelReplyIntent intent, Emitter<ChatState> emit) =>
      emit(_withoutNotes.copyWith(replyingTo: () => null));

  void _onEditDraft(EditDraftIntent intent, Emitter<ChatState> emit) =>
      emit(_withoutNotes.copyWith(draft: intent.text));

  void _onAddAttachments(AddAttachmentsIntent intent, Emitter<ChatState> emit) {
    if (intent.files.isEmpty) return;
    emit(
      _withoutNotes.copyWith(
        attachments: [...state.attachments, ...intent.files],
      ),
    );
  }

  void _onRemoveAttachment(
    RemoveAttachmentIntent intent,
    Emitter<ChatState> emit,
  ) => emit(
    state.copyWith(attachments: [...state.attachments]..removeAt(intent.index)),
  );

  Future<void> _onSend(
    SendMessageIntent intent,
    Emitter<ChatState> emit,
  ) async {
    // "Send" is off then too.
    if (!state.canSendMessage) return;
    final message = NewChatMessageEntity(
      // With all children shown and none picked: about none of them.
      studentId: state.studentId ?? state.aboutId,
      text: state.draft.trim(),
      replyTo: state.replyingTo?.key,
      // The ones that can't go stay on screen, saying why.
      attachments: [for (final file in state.attachments.valid) file.path],
      clientUuid: _messageUuid,
    );
    final cancel = _sending = CancelHandle();
    emit(_withoutNotes.copyWith(isSending: true, upload: () => null));
    final result = await _sendMessage(
      message,
      cancel: cancel,
      onProgress: (sent, total) {
        if (!state.upload.isStepTo(sent, total)) return;
        emit(state.copyWith(upload: () => (sent: sent, total: total)));
      },
    );
    result.when(
      success: (item) {
        _messageUuid = const Uuid().v4();
        final chat = state.chat;
        final shown = chat.data;
        emit(
          state.copyWith(
            // At the end of the chat, which keeps loading older items if it
            // was. A chat loading from the newest brings it itself.
            chat: shown == null
                ? null
                : BaseState.all(
                    state: chat.state,
                    data: shown.followedBy(item),
                    exception: chat.exception,
                  ),
            isSending: false,
            upload: () => null,
            draft: '',
            attachments: const [],
            replyingTo: () => null,
          ),
        );
        emitEffect(const MessageSentEffect());
      },
      failure: (exception) => _onSendFailed(exception, emit),
    );
  }

  void _onSendFailed(AppException exception, Emitter<ChatState> emit) {
    final sent = state.copyWith(isSending: false, upload: () => null);
    switch (exception) {
      // The page closed: no one to tell.
      case CancelledException():
        return;
      case UnauthorizedException():
        emit(sent);
        emitEffect(ShowErrorEffect(exception));
      case ServerException(code: ChatErrorCodes.fileRejected, :final body)
          when state.attachments.any(
            (file) => file.isValid && file.name == body['file_name'],
          ):
        // Its row says so; take it off and send again.
        emit(
          sent.copyWith(
            attachments: state.attachments.rejecting('${body['file_name']}'),
          ),
        );
      case ServerException(code: ChatErrorCodes.replyNotAllowed):
        // It stopped taking answers: sent again, it's a plain message.
        final item = state.replyingTo;
        emit(
          sent.copyWith(
            noReply: item == null ? null : {...state.noReply, item.key},
            replyingTo: () => null,
          ),
        );
        emitEffect(ShowErrorEffect(exception));
      case ServerException(code: ChatErrorCodes.chatClosed):
        // Closed meanwhile: read-only now, as the chat says in the message
        // box's place.
        final chat = state.chat;
        final shown = chat.data;
        emit(
          sent.copyWith(
            chat: shown == null
                ? null
                : BaseState.all(
                    state: chat.state,
                    data: shown.closed(),
                    exception: chat.exception,
                  ),
            replyingTo: () => null,
          ),
        );
        emitEffect(ShowErrorEffect(exception));
      default:
        emit(sent.copyWith(sendError: () => exception));
    }
  }

  Future<void> _onOpenAttachment(
    OpenAttachmentIntent intent,
    Emitter<ChatState> emit,
  ) async {
    if (state.downloadingId != null) return;
    final cancel = _downloading = CancelHandle();
    emit(state.copyWith(downloadingId: () => intent.attachment.id));
    final result = await _downloadAttachment(
      intent.attachment,
      studentId: state.studentId,
      cancel: cancel,
    );
    emit(state.copyWith(downloadingId: () => null));
    result.when(
      success: (path) => emitEffect(OpenFileEffect(path, intent.attachment)),
      failure: (exception) {
        if (exception is! CancelledException) {
          emitEffect(ShowErrorEffect(exception));
        }
      },
    );
  }

  /// Saves a photo on the phone (once: it's kept there by its id), to show
  /// in the chat.
  Future<void> _onLoadImage(LoadImageIntent intent, Emitter<ChatState> emit) =>
      _imageLoads.load(
        intent.attachment,
        images: () => state.images,
        emit: (images) => emit(state.copyWith(images: images)),
        // The snack bar says so, and the page logs out.
        onSignedOut: (exception) => emitEffect(ShowErrorEffect(exception)),
      );

  /// A new try: the notes about the last one go.
  ChatState get _withoutNotes => state.copyWith(sendError: () => null);
}
