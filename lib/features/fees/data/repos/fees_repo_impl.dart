import 'package:injectable/injectable.dart';

import 'package:al_mahhaba_school/core/base/result.dart';
import 'package:al_mahhaba_school/features/fees/data/data_sources/fees_remote_data_source.dart';
import 'package:al_mahhaba_school/features/fees/data/models/pay_online_request_model.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/checkout_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/entities/fee_statement_entity.dart';
import 'package:al_mahhaba_school/features/fees/domain/repos/fees_repo.dart';

@LazySingleton(as: FeesRepo)
class FeesRepoImpl implements FeesRepo {
  FeesRepoImpl(this._remoteDataSource);

  final FeesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<FeeStatementEntity>> getFeeStatement(int childId) =>
      Result.guard(() => _remoteDataSource.getFeeStatement(childId));

  @override
  Future<Result<CheckoutEntity>> payOnline({
    required int childId,
    required List<String> payKeys,
  }) => Result.guard(
    () => _remoteDataSource.payOnline(
      childId,
      PayOnlineRequestModel(payKeys: payKeys),
    ),
  );
}
