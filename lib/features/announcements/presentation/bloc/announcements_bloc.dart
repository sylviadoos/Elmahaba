import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_bloc.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/announcements/domain/entities/announcements_page_entity.dart';
import 'package:al_mahhaba_school/features/announcements/domain/use_cases/get_announcements_use_case.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_effect.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_intent.dart';
import 'package:al_mahhaba_school/features/announcements/presentation/bloc/announcements_state.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';

/// Announcements (MVI): the school's announcements to a child's parents, a
/// page at a time as the list scrolls; each marked read (it's a chat item)
/// once it comes on screen; and their files. One per Announcements page;
/// closing it stops what it was still loading.
@injectable
class AnnouncementsBloc
    extends
        BaseBloc<AnnouncementsIntent, AnnouncementsState, AnnouncementsEffect> {
  AnnouncementsBloc(
    this._getAnnouncements,
    this._markRead,
    this._downloadAttachment,
    this._previewAttachment,
  ) : super(const AnnouncementsState()) {
    on<AnnouncementsChildrenIntent>(_onChildren);
    on<ShowChildAnnouncementsIntent>((intent, emit) {
      emitEffect(AnnouncementsChildPickedEffect(intent.studentId));
      return _load(emit, studentId: intent.studentId);
    });
    on<ReloadAnnouncementsIntent>((_, emit) => _load(emit, refresh: true));
    on<LoadMoreAnnouncementsIntent>(_onLoadMore);
    on<ShowOneAnnouncementIntent>(
      (intent, emit) => emit(state.copyWith(studentId: () => intent.studentId)),
    );
    on<AnnouncementSeenIntent>(_onSeen);
    on<OpenAnnouncementFileIntent>(_onOpenFile);
    on<LoadAnnouncementImageIntent>(_onLoadImage);
  }

  final GetAnnouncementsUseCase _getAnnouncements;
  final MarkChatReadUseCase _markRead;
  final DownloadChatAttachmentUseCase _downloadAttachment;
  final PreviewChatAttachmentUseCase _previewAttachment;

  /// How long announcements seen are gathered, to mark them read in one
  /// request.
  static const Duration _markDelay = Duration(milliseconds: 400);

  /// Counts the lists asked for: an answer for an earlier one is dropped.
  int _loads = 0;

  /// What's on its way, to stop when it's no longer needed.
  CancelHandle? _loading;
  CancelHandle? _loadingMore;
  CancelHandle? _downloading;

  /// The photos shown in the announcements, asked for the child shown.
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

  /// The chat items marked read, or being marked, so none is sent twice.
  final Set<String> _marked = {};

  /// Seen since the last request, marked read once [_markTimer] ends.
  final Set<String> _seen = {};
  Timer? _markTimer;

  @override
  Future<void> close() {
    _loading?.cancel();
    _loadingMore?.cancel();
    _downloading?.cancel();
    _imageLoads.cancelAll();
    // What was seen just before leaving is still marked read.
    _markTimer?.cancel();
    unawaited(_markSeen());
    return super.close();
  }

  static const AnnouncementsPageEntity _none = AnnouncementsPageEntity(
    items: [],
    page: 1,
    lastPage: 1,
    total: 0,
    unread: 0,
  );

  /// The children loaded or changed: the one shown was unlinked, or they're
  /// here at last.
  Future<void> _onChildren(
    AnnouncementsChildrenIntent intent,
    Emitter<AnnouncementsState> emit,
  ) async {
    final children = intent.children;
    if (children != null) emit(state.copyWith(children: children));
    // Still loading: shown once they're here.
    if (intent.isLoading && (state.isRequested || children == null)) return;
    final list = children ?? const <ChildEntity>[];
    bool linked(int? id) => list.any((child) => child.studentId == id);
    if (state.isRequested && linked(state.studentId)) return;
    final preferred = state.isRequested ? null : intent.preferredId;
    final pick = linked(preferred) ? preferred : list.firstOrNull?.studentId;
    if (state.isRequested && pick == state.studentId) return;
    if (pick == null) {
      // No child (any more): nothing to list.
      emit(
        state.copyWith(
          isRequested: true,
          studentId: () => null,
          announcements: const BaseState.success(_none),
        ),
      );
      return;
    }
    await _load(emit, studentId: pick);
  }

  /// Loads the first page again, for [studentId] when given. [refresh]
  /// keeps what's shown on screen meanwhile.
  Future<void> _load(
    Emitter<AnnouncementsState> emit, {
    int? studentId,
    bool refresh = false,
  }) async {
    final load = ++_loads;
    _loading?.cancel();
    _loadingMore?.cancel();
    final childId = studentId ?? state.studentId;
    if (childId == null) {
      emit(
        state.copyWith(
          isRequested: true,
          announcements: const BaseState.success(_none),
        ),
      );
      return;
    }
    final cancel = _loading = CancelHandle();
    final shown = refresh ? state.page : null;
    emit(
      state.copyWith(
        isRequested: true,
        studentId: studentId == null ? null : () => studentId,
        announcements: shown == null
            ? const BaseState.loading()
            : BaseState.all(
                state: StateType.loading,
                data: shown,
                exception: null,
              ),
      ),
    );
    final result = await _getAnnouncements(childId, cancel: cancel);
    // Another child picked meanwhile.
    if (load != _loads) return;
    result.when(
      success: (page) =>
          emit(state.copyWith(announcements: BaseState.success(page))),
      failure: (exception) {
        if (exception is CancelledException) return;
        if (shown != null) {
          // Still shown as it was: why it isn't new goes in a snack bar.
          emit(state.copyWith(announcements: BaseState.success(shown)));
          emitEffect(ShowAnnouncementsErrorEffect(exception));
          return;
        }
        emit(state.copyWith(announcements: BaseState.error(exception)));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreAnnouncementsIntent intent,
    Emitter<AnnouncementsState> emit,
  ) async {
    final loaded = state.page;
    final childId = state.studentId;
    // Not while it loads (the first page, or this one), nor past the last.
    final settled = switch (state.announcements.state) {
      StateType.success || StateType.error => true,
      _ => false,
    };
    if (loaded == null || childId == null || !loaded.hasMore || !settled) {
      return;
    }
    final load = _loads;
    final cancel = _loadingMore = CancelHandle();
    emit(
      state.copyWith(
        announcements: BaseState.all(
          state: StateType.moreLoading,
          data: loaded,
          exception: null,
        ),
      ),
    );
    final result = await _getAnnouncements(
      childId,
      page: loaded.page + 1,
      cancel: cancel,
    );
    // Loaded again from the first page meanwhile.
    if (load != _loads) return;
    result.when(
      success: (next) => emit(
        state.copyWith(
          announcements: BaseState.success(loaded.followedBy(next)),
        ),
      ),
      failure: (exception) {
        if (exception is CancelledException) return;
        emit(
          state.copyWith(
            announcements: BaseState.all(
              state: StateType.error,
              data: loaded,
              exception: exception,
            ),
          ),
        );
      },
    );
  }

  /// Gathered for a moment, then marked read together.
  void _onSeen(AnnouncementSeenIntent intent, Emitter<AnnouncementsState> _) {
    if (_marked.contains(intent.chatKey) || !_seen.add(intent.chatKey)) {
      return;
    }
    _markTimer?.cancel();
    _markTimer = Timer(_markDelay, _markSeen);
  }

  /// Tells the school the parent saw the announcements gathered: what's
  /// still unread in the chat goes to its badge.
  Future<void> _markSeen() async {
    if (_seen.isEmpty) return;
    final keys = _seen.toList();
    _seen.clear();
    _marked.addAll(keys);
    // Whose announcements they are: the same item can be about another
    // child of theirs, and that one's is still new.
    final result = await _markRead(keys, studentId: state.studentId);
    result.when(
      // The badge on Chat follows it by itself.
      success: (_) {},
      failure: (exception) {
        // Tried again when they come on screen again.
        _marked.removeAll(keys);
        debugPrint('Marking announcements read: $exception');
      },
    );
  }

  Future<void> _onOpenFile(
    OpenAnnouncementFileIntent intent,
    Emitter<AnnouncementsState> emit,
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
      success: (path) =>
          emitEffect(OpenAnnouncementFileEffect(path, intent.attachment)),
      failure: (exception) {
        if (exception is! CancelledException) {
          emitEffect(ShowAnnouncementsErrorEffect(exception));
        }
      },
    );
  }

  /// Saves a photo on the phone (once: it's kept there by its id), to show
  /// in the announcement.
  Future<void> _onLoadImage(
    LoadAnnouncementImageIntent intent,
    Emitter<AnnouncementsState> emit,
  ) => _imageLoads.load(
    intent.attachment,
    images: () => state.images,
    emit: (images) => emit(state.copyWith(images: images)),
    // The snack bar says so, and the page logs out.
    onSignedOut: (exception) =>
        emitEffect(ShowAnnouncementsErrorEffect(exception)),
  );
}
