import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/chat/domain/use_cases/get_chat_unread_count_use_case.dart';
import 'package:al_mahhaba_school/features/chat/domain/use_cases/watch_chat_reads_use_case.dart';
import 'package:al_mahhaba_school/features/chat/presentation/bloc/chat_unread_intent.dart';

/// How many chat items the parent hasn't read, for the badge on Chat (MVI,
/// with no effects): one instance, provided above the router (see
/// `app.dart`). The state is the count. Follows every read the school
/// confirms, even one sent as a page closed.
@injectable
class ChatUnreadBloc extends Bloc<ChatUnreadIntent, int> {
  ChatUnreadBloc(this._getUnreadCount, WatchChatReadsUseCase watchReads)
    : super(0) {
    on<LoadChatUnreadIntent>(_onLoad);
    on<SetChatUnreadIntent>((intent, emit) => emit(intent.count));
    on<ClearChatUnreadIntent>((_, emit) => emit(0));
    _reads = watchReads().listen((unread) => add(SetChatUnreadIntent(unread)));
  }

  final GetChatUnreadCountUseCase _getUnreadCount;
  late final StreamSubscription<int> _reads;

  @override
  Future<void> close() async {
    await _reads.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadChatUnreadIntent intent, Emitter<int> emit) async {
    final result = await _getUnreadCount();
    result.when(
      success: emit.call,
      // Only a badge: the last count stays.
      failure: (exception) => debugPrint('Chat unread count: $exception'),
    );
  }
}
