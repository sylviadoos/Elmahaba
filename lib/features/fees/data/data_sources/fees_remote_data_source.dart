import 'package:al_mahhaba_school/features/fees/data/models/checkout_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/fee_statement_model.dart';
import 'package:al_mahhaba_school/features/fees/data/models/pay_online_request_model.dart';

/// Talks to the school system's fees endpoints (signed in). Throws an
/// `AppException` on failure.
abstract interface class FeesRemoteDataSource {
  /// The child's fee statement for the year: every fee, the totals and the
  /// installments. [childId] is the child's `student_id`.
  Future<FeeStatementModel> getFeeStatement(int childId);

  /// Starts an online payment of the installments in [request]; the
  /// returned page is where the parent pays.
  Future<CheckoutModel> payOnline(int childId, PayOnlineRequestModel request);

  /// Adds the optional fee [feeId] (a statement line's `fee_id`) to the
  /// child's fees, at once. Ask for the statement again after: the fee
  /// moves into the mandatory lines and the totals change.
  Future<void> confirmOptionalFee(int childId, int feeId);

  /// Drops the optional fee [feeId] from the child's fees again. The
  /// school refuses once anything is paid on it.
  Future<void> dropOptionalFee(int childId, int feeId);
}
