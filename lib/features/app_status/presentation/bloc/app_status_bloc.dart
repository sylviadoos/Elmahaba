import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/app_status/domain/use_cases/get_app_status_use_case.dart';
import 'package:al_mahhaba_school/features/app_status/presentation/bloc/app_status_intent.dart';

/// Whether parents can log in, as the school says (MVI, with no effects):
/// one instance, provided above the router and loaded at launch, then
/// asked again while the app runs (see `app.dart`). The state is whether
/// the visitor pages show "Log in": not until the school says yes.
@injectable
class AppStatusBloc extends Bloc<AppStatusIntent, bool> {
  AppStatusBloc(this._getAppStatus) : super(false) {
    on<LoadAppStatusIntent>(_onLoad);
  }

  final GetAppStatusUseCase _getAppStatus;

  Future<void> _onLoad(LoadAppStatusIntent intent, Emitter<bool> emit) async {
    final result = await _getAppStatus();
    result.when(
      success: (status) => emit(status.enabled),
      // Unknown: what was known stays (hidden at launch).
      failure: (exception) => debugPrint('App status: $exception'),
    );
  }
}
