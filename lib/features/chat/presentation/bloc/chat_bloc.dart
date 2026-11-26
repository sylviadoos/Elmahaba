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
    on<RefreshChatIntent>((_, emit) => _refresh(emit));
    on<PullRefreshChatIntent>((_, emit) => _refresh(emit, pulled: true));
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

  /// A refresh asked for while older items were on their way: joining both
  /// answers would lose one, so it waits for them instead of being lost.
  bool _refreshPending = false;

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

  /// The items marked read, or being marked, so none is sent twice — each
  /// with the child it was read for (null: "All"): an item about two
  /// children is marked once for each.
  final Set<(int?, String)> _marked = {};

  /// Items seen since the last request, with the child shown then; marked
  /// read once [_markTimer] ends.
  final Set<(int?, String)> _seen = {};
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
    // This asks for the newest itself: a refresh of the chat left behind
    // has nothing to add, and would hold the next one back.
    _refreshing?.cancel();
    _refreshing = null;
    _refreshPending = false;
    final cancel = _newest = CancelHandle();
    final cached = _getCachedChat(studentId);
    emit(
      state
          .copyWith(
            isRequested: true,
            // The refresh pulled for is dropped with the chat it was for.
            isPullRefreshing: false,
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
  ///
  /// Also when older items didn't load: the parent is down at the newest,
  /// far from "Try again" up top, and the school's news mustn't wait for
  /// it. That row stays as it is.
  ///
  /// [pulled] by the parent: a spinner shows until the answer is in — that
  /// of the refresh already on its way, if one is — and a snack bar says
  /// why when it didn't come.
  Future<void> _refresh(
    Emitter<ChatState> emit, {
    bool pulled = false,
  }) async {
    if (!state.isRequested || state.chat.data == null) return;
    // Older items are on their way: asking now would join an answer to a
    // chat that is about to change under it. Once they're here instead.
    if (state.chat.state == StateType.moreLoading) {
      _refreshPending = true;
      if (pulled) emit(state.copyWith(isPullRefreshing: true));
      return;
    }
    final settled = switch (state.chat.state) {
      StateType.success || StateType.error => true,
      _ => false,
    };
    if (!settled) return;
    if (pulled) emit(state.copyWith(isPullRefreshing: true));
    if (_refreshing != null) return;
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
    // Not a later one, started once another child was picked meanwhile.
    if (identical(_refreshing, cancel)) _refreshing = null;
    if (load != _loads) return;
    final chat = state.chat;
    final shown = chat.data;
    final wasPulled = state.isPullRefreshing;
    if (shown == null) return;
    result.when(
      // As it was: older ones that didn't load still say so.
      success: (newest) => emit(
        state
            .showing(
              BaseState.all(
                state: chat.state,
                data: newest.after(shown),
                exception: chat.exception,
              ),
            )
            .copyWith(isPullRefreshing: false),
      ),
      failure: (exception) {
        debugPrint('Refreshing the chat: $exception');
        if (!wasPulled) return;
        emit(state.copyWith(isPullRefreshing: false));
        if (exception is! CancelledException) {
          emitEffect(ShowErrorEffect(exception));
        }
      },
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
      success: (older) {
        emit(state.showing(BaseState.success(shown.after(older))));
        // What the school sent meanwhile, asked for now that these are in.
        if (_refreshPending) {
          _refreshPending = false;
          add(const RefreshChatIntent());
        }
      },
      // These come again when the parent tries again; the news asked for
      // meanwhile doesn't wait for that.
      failure: (exception) {
        emit(
          state.copyWith(
            chat: BaseState.all(
              state: StateType.error,
              data: shown,
              exception: exception,
            ),
          ),
        );
        if (_refreshPending) {
          _refreshPending = false;
          add(const RefreshChatIntent());
        }
      },
    );
  }

  /// Gathered for a moment, then marked read together.
  void _onItemSeen(ItemSeenIntent intent, Emitter<ChatState> emit) {
    final seen = (state.studentId, intent.key);
    if (_marked.contains(seen) || !_seen.add(seen)) return;
    _markTimer?.cancel();
    _markTimer = Timer(_markDelay, _markSeen);
  }

  /// Tells the school the parent saw the items gathered: they show as read
  /// at once, not when the school answers; what's still unread goes to the
  /// badge on Chat.
  Future<void> _markSeen() async {
    if (_seen.isEmpty) return;
    final seen = _seen.toSet();
    _seen.clear();
    _marked.addAll(seen);
    // Usually one child; more when the parent switched before the timer.
    final children = {for (final (studentId, _) in seen) studentId};
    await Future.wait([
      for (final studentId in children)
        _markSeenFor(studentId, {
          for (final (child, key) in seen)
            if (child == studentId) key,
        }),
    ]);
  }

  /// [keys], seen in [studentId]'s chat, marked read for them.
  Future<void> _markSeenFor(int? studentId, Set<String> keys) async {
    // Not after leaving, nor once another child's chat is shown: the same
    // item may still be new there.
    void show(bool isRead, {int? unread}) {
      if (!isClosed && state.studentId == studentId) {
        add(ItemsReadChangedIntent(keys, isRead: isRead, unread: unread));
      }
    }

    show(true);
    // Read for the child shown, as the school asks of every chat request:
    // an item about two children stays new for the other. On "All", none.
    final result = await _markRead(keys.toList(), studentId: studentId);
    result.when(
      success: (unread) => show(true, unread: unread),
      failure: (exception) {
        // New again, and tried again when they come on screen again.
        _marked.removeAll({for (final key in keys) (studentId, key)});
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
