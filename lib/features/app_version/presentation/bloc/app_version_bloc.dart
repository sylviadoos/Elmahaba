import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/app_version/domain/use_cases/check_app_version_use_case.dart';
import 'package:al_mahhaba_school/features/app_version/domain/use_cases/get_saved_forced_update_use_case.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_intent.dart';
import 'package:al_mahhaba_school/features/app_version/presentation/bloc/app_version_state.dart';

/// Whether the app must, or can, be updated (MVI, with no effects): one
/// instance, above the router (see `app.dart`).
///
/// A forced update shows at once from what the phone kept, and stays until
/// the app is updated: the school not answering never lifts it — only the
/// school saying there's no forced update any more.
@injectable
class AppVersionBloc extends Bloc<AppVersionIntent, AppVersionState> {
  AppVersionBloc(this._checkAppVersion, this._getSavedForcedUpdate)
    : super(const NoUpdateState()) {
    on<CheckAppVersionIntent>(_onCheck);
    on<PostponeUpdateIntent>((_, emit) {
      if (state is! OptionalUpdateState) return;
      _postponed = true;
      emit(const NoUpdateState());
    });
  }

  final CheckAppVersionUseCase _checkAppVersion;
  final GetSavedForcedUpdateUseCase _getSavedForcedUpdate;

  /// "Later" this time the app is open.
  bool _postponed = false;

  /// What the phone kept was looked at (once, as the app opens).
  bool _savedLookedAt = false;

  Future<void> _onCheck(
    CheckAppVersionIntent intent,
    Emitter<AppVersionState> emit,
  ) async {
    if (!_savedLookedAt) {
      _savedLookedAt = true;
      final saved = await _getSavedForcedUpdate();
      if (saved != null) emit(ForcedUpdateState(saved));
    }
    final result = await _checkAppVersion();
    result.when(
      success: (update) {
        final next = switch (update) {
          _ when update.forceUpdate => ForcedUpdateState(update),
          _ when update.updateAvailable && !_postponed => OptionalUpdateState(
            update,
          ),
          _ => const NoUpdateState(),
        };
        if (next != state) emit(next);
      },
      // Unknown: what's shown stays — a forced update most of all.
      failure: (exception) => debugPrint('App version: $exception'),
    );
  }
}
