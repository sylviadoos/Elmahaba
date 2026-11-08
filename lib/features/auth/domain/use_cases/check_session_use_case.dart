import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/auth/domain/entities/session_status.dart';
import 'package:al_mahhaba_school/features/auth/domain/repos/auth_repo.dart';

/// Checks the saved session when the app starts:
/// `switch (await checkSession()) { … }`
///
/// If the server can't be reached (offline, outside the school network…),
/// the session is kept — only the server saying it ended signs the parent
/// out.
@lazySingleton
class CheckSessionUseCase {
  CheckSessionUseCase(this._repo);

  final AuthRepo _repo;

  Future<SessionStatus> call() async => (await _repo.checkSession()).when(
    success: (status) => status,
    failure: (_) => SessionStatus.active,
  );
}
