import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/base_bloc.dart';
import 'package:al_mahhaba_school/core/base/base_state.dart';
import 'package:al_mahhaba_school/core/base/cancel_handle.dart';
import 'package:al_mahhaba_school/core/error/app_exception.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/download_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/mark_chat_read_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/preview_chat_attachment_use_case.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_image_loads.dart';
import 'package:al_mahhaba_school/features/children/domain/entities/child_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_filter.dart';
import 'package:al_mahhaba_school/features/homework/domain/entities/homework_page_entity.dart';
import 'package:al_mahhaba_school/features/homework/domain/use_cases/find_homework_use_case.dart';
import 'package:al_mahhaba_school/features/homework/domain/use_cases/get_homework_use_case.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_effect.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_intent.dart';
import 'package:al_mahhaba_school/features/homework/presentation/bloc/homework_state.dart';

/// Homework (MVI): a child's homework, filtered by due status and subject,
/// a page at a time as the list scrolls; each marked read (it's a chat
/// item) once it comes on screen; and its files. One per Homework page;
/// closing it stops what it was still loading.
@injectable
class HomeworkBloc
    extends BaseBloc<HomeworkIntent, HomeworkState, HomeworkEffect> {
  HomeworkBloc(
    this._getHomework,
    this._findHomework,
    this._markRead,
    this._downloadAttachment,
    this._previewAttachment,
  ) : super(const HomeworkState()) {
    on<HomeworkChildrenIntent>(_onChildren);
    on<ShowChildHomeworkIntent>((intent, emit) {
      emitEffect(HomeworkChildPickedEffect(intent.studentId));
      return _load(
        emit,
        studentId: intent.studentId,
        // Another child: their own subjects.
        subjectId: () => null,
      );
    });
    on<FilterHomeworkIntent>((intent, emit) {
      if (intent.filter == state.filter) return null;
      return _load(emit, filter: intent.filter);
    });
    on<PickHomeworkSubjectIntent>((intent, emit) {
      if (intent.subjectId == state.subjectId) return null;
      return _load(emit, subjectId: () => intent.subjectId);
    });
    on<ShowOneHomeworkIntent>(_onShowOne);
    on<ReloadHomeworkIntent>((_, emit) => _load(emit, refresh: true));
    on<LoadMoreHomeworkIntent>(_onLoadMore);
    on<HomeworkSeenIntent>(_onSeen);
    on<OpenHomeworkFileIntent>(_onOpenFile);
    on<LoadHomeworkImageIntent>(_onLoadImage);
  }

  final GetHomeworkUseCase _getHomework;
  final FindHomeworkUseCase _findHomework;
  final MarkChatReadUseCase _markRead;
  final DownloadChatAttachmentUseCase _downloadAttachment;
  final PreviewChatAttachmentUseCase _previewAttachment;

  /// How long homework seen is gathered, to mark it read in one request.
  static const Duration _markDelay = Duration(milliseconds: 400);

  /// Counts the lists asked for: an answer for an earlier one is dropped.
  int _loads = 0;

  /// What's on its way, to stop when it's no longer needed.
  CancelHandle? _loading;
  CancelHandle? _loadingMore;
  CancelHandle? _downloading;

  /// The photos shown in the homework, asked for the child shown.
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

  /// The children loaded or changed: the one shown was unlinked, or they're
  /// here at last.
  Future<void> _onChildren(
    HomeworkChildrenIntent intent,
    Emitter<HomeworkState> emit,
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
          homework: const BaseState.success(_none),
          subjects: const [],
        ),
      );
      return;
    }
    await _load(emit, studentId: pick, subjectId: () => null);
  }

  static const HomeworkPageEntity _none = HomeworkPageEntity(
    items: [],
    page: 1,
    lastPage: 1,
    total: 0,
    unread: 0,
  );

  /// Loads the first page again, for [studentId] (another child: their
  /// subjects), [filter] and [subjectId] when given. [refresh] keeps what's
  /// shown on screen meanwhile.
  Future<void> _load(
    Emitter<HomeworkState> emit, {
    int? studentId,
    HomeworkFilter? filter,
    int? Function()? subjectId,
    bool refresh = false,
  }) async {
    final load = ++_loads;
    _loading?.cancel();
    _loadingMore?.cancel();
    final childId = studentId ?? state.studentId;
    if (childId == null) {
      // No child: nothing to list.
      emit(
        state.copyWith(
          isRequested: true,
          filter: filter,
          subjectId: subjectId,
          homework: const BaseState.success(_none),
        ),
      );
      return;
    }
    final cancel = _loading = CancelHandle();
    final otherChild = studentId != null && studentId != state.studentId;
    final shown = refresh ? state.page : null;
    emit(
      state.copyWith(
        isRequested: true,
        studentId: studentId == null ? null : () => studentId,
        filter: filter,
        subjectId: subjectId,
        subjects: otherChild ? const [] : null,
        homework: shown == null
            ? const BaseState.loading()
            : BaseState.all(
                state: StateType.loading,
                data: shown,
                exception: null,
              ),
      ),
    );
    final result = await _getHomework(
      childId,
      filter: state.filter,
      subjectId: state.subjectId,
      cancel: cancel,
    );
    // Another child or filter picked meanwhile.
    if (load != _loads) return;
    result.when(
      success: (page) => emit(
        state.copyWith(
          homework: BaseState.success(page),
          subjects: page.subjects.isEmpty ? null : page.subjects,
        ),
      ),
      failure: (exception) {
        if (exception is CancelledException) return;
        if (shown != null) {
          // Still shown as it was: why it isn't new goes in a snack bar.
          emit(state.copyWith(homework: BaseState.success(shown)));
          emitEffect(ShowHomeworkErrorEffect(exception));
          return;
        }
        emit(state.copyWith(homework: BaseState.error(exception)));
      },
    );
  }

  /// One homework, for its own page: shown as Home holds it, or looked for
  /// (the chat only names it). Again on "Try again".
  Future<void> _onShowOne(
    ShowOneHomeworkIntent intent,
    Emitter<HomeworkState> emit,
  ) async {
    final studentId = intent.studentId;
    final held = intent.homework;
    emit(
      state.copyWith(
        studentId: () => studentId,
        one: held == null ? const BaseState.loading() : BaseState.success(held),
      ),
    );
    if (held != null) return;
    if (studentId == null) {
      emit(state.copyWith(one: const BaseState.success(null)));
      return;
    }
    _loading?.cancel();
    final cancel = _loading = CancelHandle();
    final result = await _findHomework(
      studentId,
      intent.homeworkId,
      cancel: cancel,
    );
    result.when(
      success: (homework) =>
          emit(state.copyWith(one: BaseState.success(homework))),
      failure: (exception) {
        if (exception is CancelledException) return;
        emit(state.copyWith(one: BaseState.error(exception)));
      },
    );
  }

  Future<void> _onLoadMore(
    LoadMoreHomeworkIntent intent,
    Emitter<HomeworkState> emit,
  ) async {
    final loaded = state.page;
    final childId = state.studentId;
    // Not while it loads (the first page, or this one), nor past the last.
    final settled = switch (state.homework.state) {
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
        homework: BaseState.all(
          state: StateType.moreLoading,
          data: loaded,
          exception: null,
        ),
      ),
    );
    final result = await _getHomework(
      childId,
      filter: state.filter,
      subjectId: state.subjectId,
      page: loaded.page + 1,
      cancel: cancel,
    );
    // Loaded again from the first page meanwhile.
    if (load != _loads) return;
    result.when(
      success: (next) => emit(
        state.copyWith(homework: BaseState.success(loaded.followedBy(next))),
      ),
      failure: (exception) {
        if (exception is CancelledException) return;
        emit(
          state.copyWith(
            homework: BaseState.all(
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
  void _onSeen(HomeworkSeenIntent intent, Emitter<HomeworkState> emit) {
    if (_marked.contains(intent.chatKey) || !_seen.add(intent.chatKey)) {
      return;
    }
    _markTimer?.cancel();
    _markTimer = Timer(_markDelay, _markSeen);
  }

  /// Tells the school the parent saw the homework gathered: what's still
  /// unread in the chat goes to its badge.
  Future<void> _markSeen() async {
    if (_seen.isEmpty) return;
    final keys = _seen.toList();
    _seen.clear();
    _marked.addAll(keys);
    // Whose homework it is: the same item can be about another child of
    // theirs, and that one's is still new.
    final result = await _markRead(keys, studentId: state.studentId);
    result.when(
      // The badge on Chat follows it by itself.
      success: (_) {},
      failure: (exception) {
        // Tried again when they come on screen again.
        _marked.removeAll(keys);
        debugPrint('Marking homework read: $exception');
      },
    );
  }

  Future<void> _onOpenFile(
    OpenHomeworkFileIntent intent,
    Emitter<HomeworkState> emit,
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
          emitEffect(OpenHomeworkFileEffect(path, intent.attachment)),
      failure: (exception) {
        if (exception is! CancelledException) {
          emitEffect(ShowHomeworkErrorEffect(exception));
        }
      },
    );
  }

  /// Saves a photo on the phone (once: it's kept there by its id), to show
  /// in the homework.
  Future<void> _onLoadImage(
    LoadHomeworkImageIntent intent,
    Emitter<HomeworkState> emit,
  ) => _imageLoads.load(
    intent.attachment,
    images: () => state.images,
    emit: (images) => emit(state.copyWith(images: images)),
    // The snack bar says so, and the page logs out.
    onSignedOut: (exception) => emitEffect(ShowHomeworkErrorEffect(exception)),
  );
}
