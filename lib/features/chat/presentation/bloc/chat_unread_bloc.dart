import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/entities/chat_read_entity.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/watch_chat_reads_use_case.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';
import 'package:al_mahhaba_school/features/home/domain/use_cases/get_new_messages_count_use_case.dart';

/// The badge on Chat (MVI, with no effects): what the School chat card on
/// Home says is new for the selected child — messages and notices — so the
/// two always match. One instance, provided above the router (see
/// `app.dart`). The state is the count.
///
/// Asked again after every read the school confirms (even one sent as a
/// page closed): what a read answers is the chat's own count, with its
/// events, not the card's.
@injectable
class ChatUnreadBloc extends Bloc<ChatUnreadIntent, int> {
  ChatUnreadBloc(this._getNewMessagesCount, WatchChatReadsUseCase watchReads)
    : super(0) {
    on<LoadChatUnreadIntent>(_onLoad);
    on<SetChatUnreadIntent>((intent, emit) {
      // What Home just loaded: a count asked for before is older.
      _loads++;
      emit(intent.count);
    });
    on<ClearChatUnreadIntent>((_, emit) {
      _studentId = null;
      _loads++;
      emit(0);
    });
    _reads = watchReads().listen(_onRead);
  }

  final GetNewMessagesCountUseCase _getNewMessagesCount;
  late final StreamSubscription<ChatReadEntity> _reads;

  /// The child the badge counts: the last one asked for.
  int? _studentId;

  @override
  Future<void> close() async {
    await _reads.cancel();
    return super.close();
  }

  void _onRead(ChatReadEntity _) {
    final counted = _studentId;
    if (counted != null) add(LoadChatUnreadIntent(counted));
  }

  /// Counts asked for: an answer for a child picked before (or older than
  /// what Home set) is dropped.
  int _loads = 0;

  Future<void> _onLoad(LoadChatUnreadIntent intent, Emitter<int> emit) async {
    _studentId = intent.studentId;
    final load = ++_loads;
    final result = await _getNewMessagesCount(intent.studentId);
    if (load != _loads) return;
    result.when(
      success: emit.call,
      // Only a badge: the last count stays.
      failure: (exception) => debugPrint('Chat badge: $exception'),
    );
  }
}
