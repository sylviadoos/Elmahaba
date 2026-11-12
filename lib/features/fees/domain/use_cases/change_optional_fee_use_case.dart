import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/fees/domain/repos/fees_repo.dart';

/// Adds an optional fee to a child's fees, or drops it again:
/// `await changeOptionalFee(childId: id, feeId: fee.id!, add: true);`
///
/// The school does it at once, so ask for the statement again after: the
/// fee moves between the mandatory and optional lines and the totals
/// change. Dropping is refused once anything is paid on it.
@lazySingleton
class ChangeOptionalFeeUseCase {
  ChangeOptionalFeeUseCase(this._repo);

  final FeesRepo _repo;

  Future<Result<void>> call({
    required int childId,
    required int feeId,
    required bool add,
  }) => add
      ? _repo.confirmOptionalFee(childId: childId, feeId: feeId)
      : _repo.dropOptionalFee(childId: childId, feeId: feeId);
}
