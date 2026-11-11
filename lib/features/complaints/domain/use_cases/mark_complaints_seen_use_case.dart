import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/features/complaints/domain/entities/complaints_page_entity.dart';
import 'package:al_mahhaba_school/features/complaints/domain/repos/complaints_repo.dart';

/// Remembers the complaints the parent has just had on screen, so the dot
/// on Complaints goes: `await markComplaintsSeen(shown);`
@lazySingleton
class MarkComplaintsSeenUseCase {
  MarkComplaintsSeenUseCase(this._repo);

  final ComplaintsRepo _repo;

  Future<void> call(ComplaintsPageEntity shown) =>
      _repo.markComplaintsSeen(shown.newestUpdate);
}
