import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/repos/fees_repo.dart';

/// A child's fee statement:
/// `final result = await getFeeStatement(child.studentId);`
@lazySingleton
class GetFeeStatementUseCase {
  GetFeeStatementUseCase(this._repo);

  final FeesRepo _repo;

  Future<Result<FeeStatementEntity>> call(int childId) =>
      _repo.getFeeStatement(childId);
}
