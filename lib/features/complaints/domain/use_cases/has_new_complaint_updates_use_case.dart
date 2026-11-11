import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// Whether the school has changed a complaint since the parent last looked
/// — the dot on the Complaints button:
/// `final result = await hasNewComplaintUpdates();`
@lazySingleton
class HasNewComplaintUpdatesUseCase {
  HasNewComplaintUpdatesUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<Result<bool>> call() => _repo.hasNewComplaintUpdates();
}
