import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/repos/fees_repo.dart';

/// Starts paying installments online:
/// `final result = await payOnline(childId: id, payKeys: keys);`
@lazySingleton
class PayOnlineUseCase {
  PayOnlineUseCase(this._repo);

  final FeesRepo _repo;

  Future<Result<CheckoutEntity>> call({
    required int childId,
    required List<String> payKeys,
  }) => _repo.payOnline(childId: childId, payKeys: payKeys);
}
