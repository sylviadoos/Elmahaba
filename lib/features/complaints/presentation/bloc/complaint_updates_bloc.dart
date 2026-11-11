import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/use_cases/has_new_complaint_updates_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/domain/use_cases/mark_complaints_seen_use_case.dart';
import 'package:al_mahhaba_school/features/complaints/presentation/bloc/complaint_updates_intent.dart';

/// Whether a complaint has changed since the parent last looked, for the
/// dot on the Complaints button (MVI, with no effects): one instance,
/// provided above the router (see `app.dart`). The state is the dot.
///
/// The API counts no unread replies, so this compares what the school
/// sends with how far the parent had read; a reply arriving is a push, and
/// `BadgeRefresher` asks again then.
@injectable
class ComplaintUpdatesBloc extends Bloc<ComplaintUpdatesIntent, bool> {
  ComplaintUpdatesBloc(this._hasNewUpdates, this._markSeen) : super(false) {
    on<LoadComplaintUpdatesIntent>(_onLoad);
    on<ComplaintsSeenIntent>(_onSeen);
    on<ClearComplaintUpdatesIntent>((_, emit) => emit(false));
  }

  final HasNewComplaintUpdatesUseCase _hasNewUpdates;
  final MarkComplaintsSeenUseCase _markSeen;

  Future<void> _onLoad(
    LoadComplaintUpdatesIntent intent,
    Emitter<bool> emit,
  ) async {
    final result = await _hasNewUpdates();
    result.when(
      success: emit.call,
      // Only a dot: what it says now stays.
      failure: (exception) => debugPrint('Complaint updates: $exception'),
    );
  }

  Future<void> _onSeen(ComplaintsSeenIntent intent, Emitter<bool> emit) async {
    emit(false);
    await _markSeen(intent.shown);
  }
}
