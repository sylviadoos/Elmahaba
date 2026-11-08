import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';

/// Never throws — errors come back as a `Failure`.
abstract interface class FeesRepo {
  /// The fee statement of the child with this `studentId`.
  Future<Result<FeeStatementEntity>> getFeeStatement(int childId);

  /// Starts paying [payKeys] (installments' `payKey`) online; open the
  /// returned page to pay.
  Future<Result<CheckoutEntity>> payOnline({
    required int childId,
    required List<String> payKeys,
  });
}
